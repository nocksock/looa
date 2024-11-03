local benchmark = require 'test.utils'.benchmark
local variation = require 'test.utils'.variation

benchmark("a demo for benchmarks", function()
  local iterations = 1000;

  variation("integer index", function(done)
    local thing = {}
    for i = 1, iterations, 1 do
      thing[i] = { i = i }
    end
    done(thing)
  end)

  variation("string index", function(done)
    local thing = {}
    for i = 1, iterations, 1 do
      thing["" .. i] = { i = i }
    end
    done(thing)
  end)
end)
