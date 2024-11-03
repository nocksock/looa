local b = require 'std.util.benchmark'

-- ## table insert vs set index
--
-- ### Variation: table_insert
-- Duration:       1.398966 seconds
-- Memory:         512109.5625 kilobytes
--
-- ### Variation: set_index
-- Duration:       0.787523 seconds
-- Memory:         512110.4375 kilobytes
--
-- ### Total
-- Duration:        4.332979 seconds
-- Memory:          258.0859375 kilobytes

local function identity(v)
  return v
end

local table_insert_map = function(t, fn)
  local r = {}
  for k, value in ipairs(t) do
    table.insert(r, fn(value, k))
  end
  return r
end

local set_index_map = function(tbl, f)
  local t = {}
  for k, v in ipairs(tbl) do
    t[k] = f(v, k)
  end
  return t
end

local iterations = 2000
local testing_table = {}
for i = 1, 10000 do
  testing_table[i] = { i }
end

b.benchmark("table insert vs set index", function()
  b.variation("table_insert", function()
    for i = 1, iterations do
      table_insert_map(testing_table, identity)
    end
  end)

  b.variation("set_index", function()
    for i = 1, iterations do
      set_index_map(testing_table, identity)
    end
  end)

  b.variation("set_index", function()
    for i = 1, iterations do
      set_index_map(testing_table, identity)
    end
  end)
end)
