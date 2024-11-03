-- a generator to create incrementing IDs

local createGenerator = function()
  local nextID = 1
  return function()
    local id = nextID
    nextID = nextID + 1
    return id
  end
end

return createGenerator
