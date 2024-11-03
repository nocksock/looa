local Set = require 'std.lib.set'

---@class World
---@field entities Set
---@field systems Set
local World = {}

World.create = function()
  local o = {
    entities = Set(),
    systems = Set()
  }

  setmetatable(o, { __index = World })
  return o
end

setmetatable(World, {
  __call = function(_)
    return World.create()
  end
})

---@param self World
function World.add(self, ...)
  for _, v in ipairs({ ... }) do
    if type(v) == "number" then
      self.entities:add(v)
    else
      self.systems:add(v)
    end
  end

  return self
end

function World.size(self)
  return self.entities:size() + self.systems:size()
end

return World
