InputSystem = System.create({
  requires = { "input", "velocity" },
  update = function(self, dt)
    local validEntities = Components.entitySets[self.setKey]
    for entityId in pairs(validEntities) do
      local vel = Components.velocity[entityId]
      local input = Components.input[entityId]

      if input.type == "player" then
          vel.x = 0
          vel.y = 0
          if input.pressed["left"] then vel.x = -10 end
          if input.pressed["right"] then vel.x = 10 end
          if input.pressed["up"] then vel.y = -10 end
          if input.pressed["down"] then vel.y = 10 end
      end
    end
  end
})
