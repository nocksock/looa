local b = require 'std.util.benchmark'

b.benchmark("template", function()
  local iterations = 1000;

  b.variation("A", function(done)
    for i = 1, iterations, 1 do
      -- ...
    end
  end)

  b.variation("B", function(done)
    for i = 1, iterations, 1 do
      -- ...
    end
  end)
end)
