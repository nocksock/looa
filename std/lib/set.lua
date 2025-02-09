-- reference set implementation with read cache
--
-- TODO: lazy evaluation

if not table.unpack then table.unpack = unpack end

local setIndex = {}
local sizeIndex = {} -- FIXME: I think I no longer need to track it this way with the current way of doing things.
local cachedOps = {}
local dirtyOps = {}

---@class Set
local Set = { skipCache = false }

local hash = function(...)
  local p = {}
  for index, value in ipairs({ ... }) do table.insert(p, tostring(value)) end
  return table.concat(p, " :: ")
end


Set.of = function(...)
  local o = {}
  setIndex[o] = {}
  sizeIndex[o] = 0
  setmetatable(o, {
    __index = Set
  })
  o:add(...)
  return o
end

local function check(method, ...)
  local key = hash(method, ...)

  if not Set.skipCache and cachedOps[key] and not dirtyOps[key] then
    return cachedOps[key]
  end

  return nil, key
end

local function cache(key, value)
  cachedOps[key] = value
  dirtyOps[key] = nil
  return value
end


local invalidate = function(set)
  local key = tostring(set)

  for cacheKey, _ in pairs(cachedOps) do
    if cacheKey:find(key) then
      dirtyOps[cacheKey] = true
    end
  end

  return set
end

setmetatable(Set, {
  __call = function(_, ...)
    return Set.of(...)
  end
})

Set.add = function(self, ...)
  for _, item in ipairs({ ... }) do
    if not setIndex[self][item] then
      setIndex[self][item] = item
      sizeIndex[self] = sizeIndex[self] + 1
    end
  end

  return invalidate(self)
end

Set.has = function(self, item, ...)
  local cached, key = check("has", self, item, ...)
  if cached then return cached end
  local more = { ... }

  if #more == 0 then
    return not not setIndex[self][item]
  end

  for _, k in ipairs(more) do
    if self:has(k) then return cache(key, true) end
  end

  return cache(key, false)
end

---alias of RefSet.has
Set.member = Set.has

Set.clear = function(self)
  for index, _ in ipairs(setIndex[self]) do
    setIndex[self][index] = nil
  end
  sizeIndex[self] = 0
  return invalidate(self)
end

Set.set = function(self, ...)
  self:clear()
  self:add(...)
  return invalidate(self)
end

Set.hasSome = function(self, ...)
  local cached, key = check("hasSome", self, ...)
  if cached then return cached end
  local more = { ... }

  if #more == 0 then
    error("hasSome() not yet supported. unsure if it should be true or false for all sets")
  end

  for _, k in ipairs(more) do
    if self:has(k) then return cache(key, true) end
  end

  return cache(key, false)
end

Set.remove = function(self, ...)
  for _, item in ipairs({ ... }) do
    if setIndex[self][item] then
      sizeIndex[self] = sizeIndex[self] - 1
      setIndex[self][item] = nil
    end
  end

  return invalidate(self)
end

Set.toggle = function(self, ...)
  for _, item in ipairs({ ... }) do
    if setIndex[self][item] then
      self:remove(item)
    else
      self:add(item)
    end
  end

  return invalidate(self)
end

---returns a table with entries. *DO NOT MUTATE ENTRIES* return value is cached
---use :copy():entries() instead.
Set.entries = function(self)
  local cached, key = check("entries", self)
  if cached then return cached end

  local entries = {}
  for _, v in pairs(setIndex[self]) do
    table.insert(entries, v)
  end

  return cache(key, entries)
end

Set.copy = function(self)
  return Set(table.unpack(self:entries()))
end

Set.equals = function(self, otherset)
  local cached, key = check("equals", self, otherset)
  if cached then return cached end

  if otherset:size() ~= self:size() then return cache(key, false) end
  for _, k in ipairs(setIndex[self]) do
    if not otherset:has(k) then return cache(key, false) end
  end

  return cache(key, true)
end

Set.union = function(self, ...)
  local cached, key = check("union", self, ...)
  if cached then return cached end

  local result = self:copy()
  for _, set in ipairs({ ... }) do
    for _, item in ipairs(set:entries()) do
      result:add(item)
    end
  end

  return cache(key, result)
end

Set.contains = function(self, ...)
  local cached, key = check("contains", self, ...)
  if cached then return cached end

  local sets = { ... }
  for _, other in ipairs(sets) do
    for _, item in ipairs(other:entries()) do
      if not self:has(item) then return cache(key, false) end
    end
  end

  return cache(key, true)
end

Set.intersection = function(self, ...)
  local cached, key = check("intersection", self, ...)
  if cached then return cached end

  local sets = { ... }
  if #sets == 0 then return cache(key, self:copy()) end

  -- not caching these, as creating an empty refset is probably faster than
  -- hash+lookup
  -- TODO: verify this assumption
  if self:size() == 0 then return Set() end
  for _, set in ipairs(sets) do
    if set:size() == 0 then return Set() end
  end

  if #sets == 1 then
    local result = Set()
    local other = sets[1]
    for _, item in ipairs(self:entries()) do
      if other:has(item) then
        result:add(item)
      end
    end
    return cache(key, result)
  end

  local smallest = self
  local smallest_len = self:size()
  for _, set in ipairs(sets) do
    if set:size() < smallest_len then
      smallest = set
      smallest_len = set:size()
    end
  end

  local result = Set()
  for _, item in ipairs(smallest:entries()) do
    local in_all = true
    for _, set in ipairs(sets) do
      if not set:has(item) then
        in_all = false
        break
      end
    end
    if in_all and (smallest == self or self:has(item)) then
      result:add(item)
    end
  end

  return cache(key, result)
end

Set.isSubsetOf = function(self, other)
  return other:contains(self)
end

Set.isSupersetOf = function(self, other)
  return self:contains(other)
end

-- using a method instead of a field to keep the interface consistent
Set.size = function(self)
  return sizeIndex[self]
end

Set.each = function(self, fn)
  -- :entries is already cached()
  for _, item in ipairs(self:entries()) do
    fn(item)
  end
  return self
end


Set.flatMap = function(self, fn)
  local cached, key = check("flatMap", self, fn)
  if cached then return cached end

  local result = Set()
  self:each(function(entry)
    local mapped = fn(entry)
    if not mapped then return end
    mapped:each(function(item)
      result:add(item)
    end)
  end)

  return cache(key, result)
end

Set.map = function(self, fn)
  local cached, key = check("map", self, fn)
  if cached then return cached end

  local entries = self:entries()
  local results = {}
  for i = 1, #entries do
    results[i] = fn(entries[i])
  end

  return cache(key, Set(table.unpack(results)))
end

Set.filter = function(self, fn)
  local cached, key = check("filter", self, fn)
  if cached then return cached end

  local entries = self:entries()
  local filtered = {}
  local count = 0
  for i = 1, #entries do
    if fn(entries[i]) then
      count = count + 1
      filtered[count] = entries[i]
    end
  end
  return cache(key, Set(table.unpack(filtered)))
end

return Set
