require 'globals'
local Signal = require 'std.lib.lazy_signal'
local spy = require 'luassert.spy'

-- NOTE: this is a the exact same spec as signal_spec.lua since they should
--  behave the exact same way.

describe('Signal<Value>', function()
  describe(':set(Value) -> Signal', function()
    it('sets the value', function()
      local value = Signal(10)
      assert.same(10, value:get())
      value:set(20) -- this won't trigger an update
      value:set(40)
      assert.same(40, value:get())
    end)
  end)

  describe('.isSignal(*) -> Boolean', function()
    it('checks if the parameter is a Signal', function()
      local s = Signal(10)
      assert(Signal.isSignal(s))
      assert(not Signal.isSignal({}))
    end)
  end)

  describe(':onChange(cb)', function()
    it("calls cb when the signal's value updated", function()
      local value = Signal(10)
      local s = spy.new(function() end)
      local unsub = value:onChange(s)
      assert.spy(s).was.called(0)
      value:set(20)
      assert.spy(s).was.called(0) -- onChange is in sync with the value, lazy
      value:get()
      assert.spy(s).was.called(1)
      assert.spy(s).was.called_with(20, 10)
      unsub()
      value:set(30)
      assert.spy(s).was.called(1)
    end)
  end)

  describe('.derive(Signal | Signal[], fn: (Signal -> *)) -> Signal<*>', function()
    it('derives a signal', function()
      local a = Signal(10)
      local b = Signal.derive(a, function(v) return v * 2 end)

      assert.same(20, b:get())
      a:set(20)
      assert.same(40, b:get())
    end)

    it('can be derived again', function()
      local a = Signal(20)
      local b = Signal.derive(a, function(v) return v * 2 end)
      local c = Signal.derive(b, function(v) return v - 10 end)

      assert.same(30, c:get())
      a:set(30)
      assert.same(50, c:get())
    end)

    it('can derive from multiple signals', function()
      local a = Signal(10)
      local b = Signal(20)
      local s = spy.new(function() end)
      local c = Signal.derive({a, b}, s)
      assert.spy(s).called(1)
      assert.spy(s).called_with(a:get(),b:get())

      a:set(10)
    end)
  end)


  describe(':update', function()
    it('sets the value by function', function()
      local value = Signal(20)
      local add = function(signal, b) return signal:get() + b end
      local s = spy.new(function() end)
      value:onChange(s)
      value:update(add, 10)
      assert.same(30, value:get())
      Signal.update(value, add, 10) -- naturally can also be called like this
      assert.same(40, value:get())
      assert.spy(s).was.called(2)
    end)
  end)


  describe(':call(fn, ...args)', function()
    it('calls a function with the internval value and returns the result', function()
      local value = Signal(20)
      local op = function(signal, operator, operand)
        if operator == "add" then
          return signal:get() + operand
        end
      end

      local result = value:call(op, "add", 10)
      assert.same(30, result)
    end)
  end)

  describe(":ap(Signal<Function>) -> Signal", function()
    it("applies the Signal<fn> to a Signal<value>", function()
      local celsius = Signal(20)
      local convertFn = Signal(function(c) return c * 9 / 5 + 32 end)

      local fahrenheit = celsius:ap(convertFn)
      assert.equal(68, fahrenheit:get()) -- 20°C = 68°F

      celsius:set(30)
      assert.equal(86, fahrenheit:get()) -- 30°C = 86°F

      convertFn:set(function(c) return c + 273.15 end)
      assert.equal(303.15, fahrenheit:get()) -- 30°C = 303.15K
    end)
  end)
end)
