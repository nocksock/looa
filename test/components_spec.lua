local Entity = require 'std.ecs.entities'
local Component = require 'std.ecs.components'

describe('Components', function()
  describe('create', function()
    it('returns a factory', function()
      local Position = Component:create("position", function(x, y)
        return { x, y }
      end)

      assert.same({ "position", { 10, 20 } }, Position(10, 20))
    end)

    it('turns args to list if no fn given', function()
      local C = Component:create('foo')
      assert.same({ "foo", { 10, 20 } }, C(10, 20))
      assert.same({ "foo", { 10 } }, C(10))
    end)
  end)

  describe("add", function()
    it('adds a component to an entity', function()
      local player = Entity()
      local enemy = Entity()

      local Position = Component:create("pos", function(x, y)
        return { x = x, y = y }
      end)

      local Velocity = Component:create("vel", function(x, y)
        return { x = x, y = y }
      end)

      local RedTeam = Component:create("redTeam")
      local BlueTeam = Component:create("blueTeam")

      Component:add(player, Position(10, 10), Velocity(10, 10), BlueTeam())
      Component:add(enemy, Position(10, 10), RedTeam())

      assert.same({ x = 10, y = 10 }, Component:get(player, Position))
    end)
  end)
end)
