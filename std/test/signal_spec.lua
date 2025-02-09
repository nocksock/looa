local signal = require 'std.lib.signal'
local spy = require 'luassert.spy'

describe('Signal<Value>', function()
  describe(':set(Value) -> Signal', function()
    it('sets the value', function()
      local value = signal(10)
      assert.same(10, value:get())
      value:set(20)
      assert.same(20, value:get())
    end)
  end)

  describe(':is(*) -> Boolean', function()
    it('checks if the parameter is a Signal', function()
      local s = signal(10)
      assert(signal.isSignal(s))
      assert(not signal.isSignal({}))
    end)
  end)

  describe(':update', function()
    it('sets the value by function', function()
      local value = signal(20)
      local add = function(signal, b) return signal:get() + b end
      local s = spy.new(function() end)
      value:onChange(s)
      value:update(add, 10)
      assert.same(30, value:get())
      signal.update(value, add, 10) -- naturally can also be called like this
      assert.same(40, value:get())
      assert.spy(s).was.called(2)
    end)
  end)

  describe(':onChange(cb)', function()
    it("calls cb whenever the signal's value changes", function()
      local value = signal(10)
      local s = spy.new(function() end)
      local unsub = value:onChange(s)
      assert.spy(s).was.called(0)
      value:set(20)
      assert.spy(s).was.called(1)
      assert.spy(s).was.called_with(20, 10)
      unsub()
      value:set(30)
      assert.spy(s).was.called(1)
    end)
  end)

  describe('.derive(Signal | Signal[], fn: (Signal -> *)) -> Signal<*>', function()
    it('derives a signal', function()
      local a = signal(10)
      local b = signal.derive(a, function(v) return v * 2 end)

      assert.same(20, b:get())
      a:set(20)
      assert.same(40, b:get())
    end)

    it('can be derived again', function()
      local a = signal(20)
      local b = signal.derive(a, function(v) return v * 2 end)
      local c = signal.derive(b, function(v) return v - 10 end)

      assert.same(30, c:get())
      a:set(30)
      assert.same(50, c:get())
    end)

    it('can derive from multiple signals', function()
      local a = signal(10)
      local b = signal(20)
      local s = spy.new(function() end)
      local c = signal.derive({ a, b }, s)
      assert.spy(s).called(1)
      assert.spy(s).called_with(a:get(), b:get())

      a:set(10)
    end)
  end)


  describe(':call(fn, ...args)', function()
    it('calls a function with the internval value and returns the result', function()
      local value = signal(20)
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
      local celsius = signal(20)
      local convertFn = signal(function(c) return c * 9 / 5 + 32 end)

      local fahrenheit = celsius:ap(convertFn)
      assert.equal(68, fahrenheit:get()) -- 20°C = 68°F

      celsius:set(30)
      assert.equal(86, fahrenheit:get()) -- 30°C = 86°F

      convertFn:set(function(c) return c + 273.15 end)
      assert.equal(303.15, fahrenheit:get()) -- 30°C = 303.15K
    end)
  end)
end)
