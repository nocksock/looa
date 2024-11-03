local tbl = require('std.lib.table')

local fns = {}

function fns.identity(i) return i end

local invoke = function(acc, f) return f(acc) end

function fns.compose(...)
  local funcs = { ... }
  return function(x, funcs)
    return tbl.reduceRight(funcs, invoke, x)
  end
end

return fns
