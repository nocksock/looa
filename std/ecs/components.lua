-- Component storage
local Component = {
  components = {},

  -- set of  ftin
  -- "a,b,c" = { 1, 33, 51},
  -- "a,b" = { 12, 41, 55},
  -- "a" = { 1, 33, 51},

  entitySets = {},
  __MARKER = {},
  refs = {}
}

local nextComponentID = 1
local createComponent = function()
  local id = nextComponentID
  nextComponentID = id + 1
  return id
end

---create a new component
---@param self table
---@param name string
---@param fn? function
---@return string | function
function Component.create(self, name, fn)
  local id = createComponent()
  ---@diagnostic disable-next-line: cast-local-type
  name = name == nil and id or name

  self[name] = {}

  if fn == nil then
    return function(...)
      return { name, { ... } }
    end
  end

  local cfn = function(...)
    return { name, fn(...) }
  end

  self.refs[cfn] = name

  return cfn
end

function Component.add(self, entityId, ...)
  local comps = { ... }
  for _, component in ipairs(comps) do
    local name, data = component[1], component[2]

    if not self[name] then
      self[name] = {}
    end

    self[name][entityId] = data
  end
end

function Component.get(self, entityId, componentType)
  local name
  if type(componentType) == "function" then
    if not self.refs[componentType] then
      error("Attempting to get non-existent component type: " .. I(componentType))
    end

    name = self.refs[componentType]
  end

  if not self[name] then
    error("Attempting to get non-existent component type: " .. name)
  end

  return self[name][entityId]
end

return Component
