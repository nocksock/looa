-- WIP: a naive signal implementation with lazy evaluation

local set = require 'std.lib.set'

local valueIndex = {}
local subscriberIndex = set()
local dirtySignals = set()

LazySignal = {}

setmetatable(LazySignal, {
  __tostring = function(t)
    return "Signal: " .. I(t)
  end,
  __call = function(_, value)
    local o = {}
    valueIndex[o] = value
    subscriberIndex[o] = {}
    dirtySignals = set()
    setmetatable(o, { __index = LazySignal })
    return o
  end
})

LazySignal_update   = function(self, newValue)
  local oldValue = valueIndex[self]
  valueIndex[self] = newValue
  P({ oldValue, newValue })
  if newValue ~= oldValue then
    for _, cb in pairs(subscriberIndex[self]) do
      cb(newValue, oldValue)
    end
  end
  return self
end

LazySignal.set      = function(self, value)
  valueIndex[self] = value
  dirtySignals:add(self)
  return self
end

LazySignal.get      = function(self)
  if dirtySignals:has(self) then
    LazySignal_update(self, valueIndex[self])
    dirtySignals:remove(self)
  end
  return valueIndex[self]
end

LazySignal.update   = function(self, fn, ...) return self:set(fn(self, ...)) end
LazySignal.call     = function(self, fn, ...) return fn(self:get(), ...) end

LazySignal.isSignal = function(unknown)
  return not not subscriberIndex[unknown]
end

LazySignal.isDirty  = function(self)
  return not not dirtySignals[self]
end

LazySignal.onChange = function(self, cb)
  subscriberIndex[self][cb] = cb
  return function() subscriberIndex[self][cb] = nil end
end

return LazySignal
