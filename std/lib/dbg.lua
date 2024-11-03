-- debug helpers

local inspect = require 'ext.inspect'
local dbg = {}

setmetatable(dbg, {
  __call = function(_, ...) return dbg.dbg(...) end
})

function dbg.dbg(thing, opts)
  print(inspect(thing, opts))
  return thing
end

return dbg
