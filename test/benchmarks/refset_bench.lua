-- NOTE: outdated and broken. doesn't use the benchmark util
local tu = require 'std.test.utils'
local RefSet = require 'std.lib.set'

local a
local b
local c

local function setup()
  a = RefSet(1, 2, 3, 4, 5, 6, 7, 8, 9)
  b = RefSet(11, 12, 13, 14, 15, 16, 17, 18, 99)
  c = RefSet(6, 12, 18)
end

local function evenNumber(v) return v % 2 == 0 end

collectgarbage("collect")
collectgarbage("stop")
local function benchmark_a()
  setup()
  local result
  for _ = 1, 500, 1 do
    result = a:union(b):filter(evenNumber):intersection(c)
  end
  P(result:entries())
end

local function benchmark_b()
  setup()
  local result
  a:add(42)
  for _ = 1, 100, 1 do
    c:add(42)
    result = a:union(b):filter(evenNumber):intersection(c)
  end
  P(result:entries())
end

print("skipCache = false")
RefSet.skipCache = false
tu.bench("skipCache = false", function()
  tu.trackTime("a", 1, benchmark_a)
  tu.trackTime("b", 1, benchmark_b)
end)

print("")
print("")

collectgarbage("collect")
print("skipCache = true")
RefSet.skipCache = true
tu.trackTime("a", 1, benchmark_a)
print(collectgarbage("count"))
tu.trackTime("b", 1, benchmark_b)
print(collectgarbage("count"))
