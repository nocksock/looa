local RefSet = require 'std.lib.ref_set'

local QuerySystem = {}
local queryResults = {}       -- Cache for query results
local dirtyQueries = RefSet() -- Track which queries need updating
local queryDependencies = {}  -- Track which queries depend on which component types

-- Create a new query that finds entities matching all component types
function QuerySystem.all(...)
  local query = {
    componentTypes = { ... },
    mode = "all"
  }

  -- Register dependencies
  for _, componentType in ipairs(query.componentTypes) do
    queryDependencies[componentType] = queryDependencies[componentType] or RefSet()
    queryDependencies[componentType]:add(query)
  end

  -- Initialize empty result
  queryResults[query] = RefSet()

  return setmetatable(query, { __index = QuerySystem })
end

-- Create a query that finds entities matching any component type
function QuerySystem.any(...)
  local query = {
    componentTypes = { ... },
    mode = "any"
  }

  for _, componentType in ipairs(query.componentTypes) do
    queryDependencies[componentType] = queryDependencies[componentType] or RefSet()
    queryDependencies[componentType]:add(query)
  end

  queryResults[query] = RefSet()

  return setmetatable(query, { __index = QuerySystem })
end

-- Mark queries as dirty when components change
function QuerySystem.markDirty(componentType)
  if queryDependencies[componentType] then
    queryDependencies[componentType]:each(function(query)
      dirtyQueries:add(query)
    end)
  end
end

-- Get current results, updating if dirty
function QuerySystem:get(world)
  if dirtyQueries:has(self) then
    self:update(world)
    dirtyQueries:remove(self)
  end
  return queryResults[self]
end

-- Update query results
function QuerySystem:update(world)
  if self.mode == "all" then
    -- Entity must have ALL component types
    local result = nil
    for _, componentType in ipairs(self.componentTypes) do
      local components = world.components[componentType] or RefSet()
      if result == nil then
        result = components:copy()
      else
        result = result:intersection(components)
      end
    end
    queryResults[self] = result or RefSet()
  else
    -- Entity must have ANY component type
    local result = RefSet()
    for _, componentType in ipairs(self.componentTypes) do
      local components = world.components[componentType] or RefSet()
      result = result:union(components)
    end
    queryResults[self] = result
  end
end

-- Add support for NOT queries
function QuerySystem.none(...)
  local query = {
    componentTypes = { ... },
    mode = "none"
  }
  -- Similar setup...
  return setmetatable(query, { __index = QuerySystem })
end

-- Add support for combining queries
function QuerySystem.intersection(self, other)
  return self:get():intersection(other:get())
end

function QuerySystem.union(self, other)
  return self:get():union(other:get())
end

-- Add support for query modifiers
function QuerySystem.filter(self, predicate)
  return self:get():filter(predicate)
end

-- Add support for sorting
function QuerySystem.sort(self, comparator)
  local results = self:get():entries()
  table.sort(results, comparator)
  return results
end
