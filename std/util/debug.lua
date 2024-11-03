local inspect = require 'std.util.inspect'

local dbg = {}

function dbg.dbg(thing, opts)
  print(I(thing, opts))
  return thing
end

return dbg
