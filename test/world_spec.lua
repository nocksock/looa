local Entity = require 'std.ecs.entities'
local World = require 'std.ecs.world'

describe('World', function()
  it('', function()
    local entity = Entity()
    local world = World()
    world:add(entity)
    assert(world:size() == 1)
  end)
end)
