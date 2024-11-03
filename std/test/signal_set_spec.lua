-- WIP

local signal = require 'std.lib.signal'
local set = require 'std.lib.set'
local spy = require 'luassert.spy'

-- NOTE: all write operations on the Set have to happen with signal:map, to retain reactivity

local valueIndex = {}
local signalIndex = {}
SetSignal = {}

setmetatable(SetSignal, {
  __call = function(_, ...)
    local o = {}
    valueIndex[o] = set(...)
    signalIndex[o] = signal(valueIndex[o])
    setmetatable(o, { __index = SetSignal, __tostring = function(t) return "SetSignal: " .. I(t) end })
    return o
  end
})

function SetSignal.get(self)
  return valueIndex[self]
end

function SetSignal.has(self, item)
  return valueIndex[self]:has(item)
end

function SetSignal.onChange(self, fn)
  return signalIndex[self]:onChange(fn)
end

function SetSignal.add(self, item)
  if not self:has(item) then
    signalIndex[self]:map(function(set) return set:add(item) end)
  end
  return self
end

function SetSignal.remove(self, item)
  if self:has(item) then
    signalIndex[self]:map(function(set) return set:remove(item) end)
  end
  return self
end

function SetSignal.set(self, ...)
  signal[self]:set(...)
end

function SetSignal.derive(source, cb)
  local value = SetSignal(cb(valueIndex[source]))
  source:onChange(function(v) end)
  value.set = function(self, _) error("cannot write to a derived signal") end
  return value
end

function SetSignal.filter(source, cb)
  -- TODO: implement filter so that relationships aren't lost.
  local sourceset = source._signal:get()
  local value = SetSignal(sourceset:filter(cb))
  source:onChange(function(v) signal.set(value, cb(v)) end)
  value.add = function(self, _) error("cannot write to a derived signal") end
  return value
end

-- function SignalSet.add(self, ...)
-- end

describe('Signal Set', function()
  describe('idea', function()
    it('is a Signal containing a Set: Signal(Set)', function()
      local x1 = { x = 1 }
      local x2 = { x = 2 }
      local x3 = { x = 3 }
      local a = signal(set(x1, x2))
      a:map(function(s) return s:add(x3) end)
      assert(a:get():equals(set(x1, x2, x3)))
    end)
  end)
end)

describe('SetSignal', function()
  it('is a set that implements the signal interface and then some', function()
    local set = SetSignal(1, 2, 3)
    local s = spy.new(function() end)
    assert(set:has(2))
    set:onChange(s)
    set:add(4)
    assert.spy(s).was.called(1)
    set:add(2)
    assert.spy(s).was.called(1)
    set:remove(2)
    assert.spy(s).was.called(2)
  end)

  describe(':get', function()
    it('returns the contained set', function()
      local a = SetSignal(1, 2, 3)
      assert.same(3, a:get():length())
    end)
  end)

  describe(':set', function()
    it('sets the internal value', function()
      local a = SetSignal(1, 2, 3)
      a:set(4, 5, 6)
      assert(a:get():equals(set(4, 5, 6)))
    end)
  end)

  -- describe(':derive', function ()
  --   it('', function()
  --     local a = SetSignal(1, 2, 3)
  --     local b = a:derive(function(value)
  --       return value:add(4) -- TODO: filter/map
  --     end)
  --     assert(b:has(4))
  --     a:add(5)
  --     assert(b:has(5))
  --     assert(b:has(4))
  --   end)
  -- end)
end)
