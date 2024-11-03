-- a naive signal implementation with eager evaluation

local valueIndex = {}
local subscriberIndex = {}

local Signal = {}

setmetatable(Signal, {
  __tostring = function(t)
    return "Signal: " .. I(t)
  end,
  __call = function(_, value)
    local o = {}
    valueIndex[o] = value
    subscriberIndex[o] = {}
    setmetatable(o, { __index = Signal })
    return o
  end
})

Signal.get      = function(self) return valueIndex[self] end
Signal.update   = function(self, fn, ...) return self:set(fn(self, ...)) end
Signal.call     = function(self, fn, ...) return fn(self, ...) end

Signal.set      = function(self, newValue)
  local oldValue = valueIndex[self]
  valueIndex[self] = newValue
  for _, cb in pairs(subscriberIndex[self]) do
    cb(newValue, oldValue)
  end
  return self
end

Signal.isSignal = function(unknown)
  -- using subscriberIndex since valueIndex might hold falsy value
  return not not subscriberIndex[unknown]
end

Signal.derive   = function(signals, fn)
  assert(type(signals) == "table", "bad argument #1 to Signal.derive. Expected a table, got " .. type(signals))

  if Signal.isSignal(signals) then
    local o = Signal(fn(signals:get()))
    signals:onChange(function(value)
      o:set(fn(value))
    end)
    return o
  else
    for _, sig in ipairs(signals) do
      if not Signal.isSignal(sig) then
        error("bad argument #1 to Signal.derive (expected table of signals, got " .. I(sig) .. ")")
      end
    end
  end

  local values = {}

  for i, signal in ipairs(signals) do
    values[i] = signal:get()
  end

  local o = Signal(fn(unpack(values)))

  for i, signal in ipairs(signals) do
    signal:onChange(function(newValue)
      values[i] = newValue -- Update the value at the correct index
      o:set(fn(unpack(values)))
    end)
  end

  return o
end

Signal.onChange = function(self, cb)
  subscriberIndex[self][cb] = cb
  return function() subscriberIndex[self][cb] = nil end
end

function Signal.ap(self, fnSignal)
  return Signal.derive({ self, fnSignal }, function(a, fn)
    return fn(a)
  end)
end

function Signal.flatMap(self, fn)
  local derived = self:derive(fn)
  return Signal.derive(derived:get(), function(val)
    return val:get()
  end)
end

return Signal
