PhysicsSystem = System.create({
  requires = { "position", "velocity" },
  update = function(self, dt)
    local validEntities = Components.entitySets[self.setKey]
    for entityId in pairs(validEntities) do
      local pos = Components.position[entityId]
      local vel = Components.velocity[entityId]
      pos.x = pos.x + vel.x * dt
      pos.y = pos.y + vel.y * dt
    end
  end
})

