local Components = require 'lib.component'

local System = {
  systems = {}
}

function System.create(config)
  local system = {
    requires = config.requires or {}, -- Component requirements

    init = function(self)
      -- Register component requirements
      local setKey = Components:makeSetKey(self.requires)
      Components.entitySets[setKey] = Components.entitySets[setKey] or {}
      self.setKey = setKey
    end,

    update = function(self, dt)
      -- Default update that can be overridden
      if config.update then
        local validEntities = Components.entitySets[self.setKey]
        for entityId in pairs(validEntities) do
          config.update(self, entityId, dt)
        end
      end
    end
  }

  for k, v in pairs(config) do
    if k ~= "init" and k ~= "update" then
      system[k] = v
    end
  end

  table.insert(System.systems, system)

  return system
end

return System
