RenderSystem = System.create({
  layers = {}, -- Store render commands by layer

  commandPool = {
    text = {},  -- Pool of text commands
    sprite = {} -- Pool for other types
  },

  addTextCommand = function(self, layer, text, x, y)
    local cmd = table.remove(self.commandPool.text) or {
      type = "text",
      text = "",
      x = 0,
      y = 0
    }
    -- Reuse command object by updating its values
    cmd.text = text
    cmd.x = x
    cmd.y = y

    self.layers[layer] = self.layers[layer] or {}
    table.insert(self.layers[layer], cmd)
  end,

  draw = function(self)
    for layer, commands in ipairs(self.layers) do
      for _, cmd in ipairs(commands) do
        if cmd.type == "text" then
          love.graphics.print(cmd.text, cmd.x, cmd.y)
        end
        -- Return command to pool
        table.insert(self.commandPool[cmd.type], cmd)
      end
      self.layers[layer] = {}
    end
  end
})
