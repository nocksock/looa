require 'globals'
local spy = require 'luassert.spy'
local RefSet = require 'std.lib.ref_set'

local function table_has(self, item)
  for i, v in ipairs(self) do
    if v == item then
      return true
    end
  end
  return false
end

describe('RefSet<Element>', function()
  it('works for functions and tables', function()
    local t = {}
    local f = function() end
    local s = RefSet(t, f)
    assert(s:has(t))
    assert(s:has(f))
  end)

  describe(':set(...Element) -> RefSet', function()
    it("sets the set's value", function()
      local s = RefSet("foo", "FOO", "bar", "BAR")
      s:set(1, 2, 3)
      assert(RefSet(1, 2, 3):equals(s))
    end)
  end)

  describe(":has(Element) -> Boolean", function()
    it('checks if set has element', function()
      local s = RefSet("foo", "bar")
      local b = RefSet("baz", "bier")
      assert(not s:has("union"))
      assert(not s:has("baz"))
      assert(not s:has("union"))
      assert(not s:has("copy"))
    end)

    it('checks for mutliple', function()
      -- local s = RefSet("foo", "bar")
      -- assert(s:has("union", "bar", "union"))
    end)
  end)

  it('caches set operations', function()
    local a = RefSet(1)
    local b = RefSet(4)
    local c = RefSet(1, 4)
    local endresult = RefSet(1, 4, 7, 8)
    local add = spy.new(RefSet.add)
    ---@diagnostic disable-next-line: assign-type-mismatch
    RefSet.add = add
    a:union(b)
    a:union(b)
    for _ = 1, 100, 1 do
      assert(a:union(b):equals(c))
    end
    assert.spy(add).was.called(2) -- union uses :add internally
    a:add(7)
    a:add(8)
    assert.spy(add).was.called(4)
    for _ = 1, 100, 1 do
      assert(a:union(b):equals(endresult))
    end
    assert.spy(add).was.called(6)
  end)

  describe(":hasSome(...Element) -> Boolean", function()
    it('checks if a set has some of the elements', function()
      local s = RefSet("foo", "bar", "baz")
      assert(s:hasSome("foo", "baz"))
      assert(not s:hasSome("nope"))
    end)
  end)

  describe(':add(...Element)', function()
    -- also ensuring that instances don't leak
    it('adds an element', function()
      local s = RefSet()
      assert(not s:has("foo"))
      assert(not s:has("baz"))
    end)

    it('doesnt add the same element twice', function()
      local s = RefSet("foo", "bar")
      s:add("foo")
      assert.equal(2, s:size())
      assert(s:has("foo"))
      assert(s:has("bar"))
    end)
  end)

  describe(':remove(Element) -> RefSet', function()
    it('removes an element and updates size', function()
      local s = RefSet("foo", "bar")
      s:remove("foo")
      assert.equal(1, s:size())
      assert(not s:has("foo"))
    end)

    it('does nothing when removing a non-existing element', function()
      local s = RefSet("foo", "bar")
      s:remove("baz")
      assert.equal(2, s:size())
      assert(s:has("bar"))
    end)
  end)

  describe(':toggle(Element) -> RefSet', function()
    it('removes or adds an item depending on its existence', function()
      local s = RefSet("foo", "bar")
      s:toggle("bar")
      assert(not s:has("bar"))
      s:toggle("bar")
      assert(s:has("bar"))
    end)

    it('can take multiple', function()
      local s = RefSet("foo", "bar", "baz")
      s:toggle("bar", "baz")
      assert(not s:has("bar"))
      assert(not s:has("baz"))
      s:toggle("bar", "baz")
      assert(s:has("bar"))
      assert(s:has("baz"))
    end)
  end)

  -- Löve and Neovim use lua 5.1 which doesn't support the __len metatable
  describe(':size() -> Int', function()
    it('returns the size of the set', function()
      local s = RefSet("foo", "bar")
      assert.equal(2, s:size())
    end)
  end)

  describe(':entries() -> Element[]', function()
    it('returns the entries', function()
      local t = {}
      local s = RefSet("foo", "bar", t)
      local e = s:entries()
      assert(table_has(e, "foo"))
      assert(table_has(e, "bar"))
      assert(table_has(e, t))
      -- changes to the returned table don't affect the set
      table.insert(e, "baz")
      assert(not s:has("baz"))
    end)
  end)

  describe(':copy() -> RefSet', function()
    it('duplicates a set', function()
      local a = RefSet("foo", "bar")
      local b = a:copy()
      for _, t in ipairs({ a, b }) do
        assert(t:has("foo"), "has foo")
        assert(t:has("bar"), "has bar")
        assert.equal(2, t:size(), "size 2")
      end
    end)
  end)

  describe(':equals(RefSet) -> Boolean', function()
    it("checks if one set's values is equal to another", function()
      local t = {}
      local a = RefSet("foo", "bar", t)
      local b = RefSet(t, "bar", "foo")
      assert(a:equals(b))
      -- assert(a == b) -- TODO: do I want this? Postponing until I tried the bookkeeping version
    end)
  end)

  describe(':union(...RefSet) -> RefSet', function()
    it('creates a new set contain all elements of both', function()
      local a = RefSet("foo", "bar") -- note: same strings are referentially equal in lua
      local b = RefSet("foo", "baz")
      local c = a:union(b)

      assert.equal(3, c:size())
      assert(c:has("foo"))
      assert(c:has("bar"))
      assert(c:has("baz"))
    end)
  end)

  describe(':contains(...RefSet) -> RefSet', function()
    it('checks if one set contains another', function()
      local a = RefSet("foo", "bar", "baz")
      local b = RefSet("foo", "bar")
      local c = RefSet("nope")

      assert(a:contains(b), "a contains b")
      assert(not b:contains(a), "b does not contain a")
      assert(not a:contains(c), "a does not conain c")
    end)
  end)

  describe(':isSubsetOf(RefSet) -> Boolean)', function()
    it('checks if a set is a subset of another', function()
      local a = RefSet("foo", "bar", "baz")
      local b = RefSet("foo", "bar")
      local c = RefSet("nope")

      assert(b:isSubsetOf(a), "b is subset of a")
      assert(not a:isSubsetOf(b), "a is not subset of b")
      assert(not c:isSubsetOf(a), "c is not subset of a")
    end)
  end)

  describe(':isSupersetOf(RefSet) -> Boolean)', function()
    it('checks if a set is a superset of another', function()
      local a = RefSet("foo", "bar", "baz")
      local b = RefSet("foo", "bar")
      local c = RefSet("nope")

      assert(a:isSupersetOf(b), "a is superset of b")
      assert(not b:isSupersetOf(a), "b is not superset of a")
      assert(not a:isSupersetOf(c), "a is not superset of c")
    end)
  end)

  describe(':intersection(...Element) -> RefSet', function()
    it('returns a set of elements common to other sets', function()
      local a = RefSet("foo", "bar", "baz")
      local b = RefSet("foo", "bar", "qux")
      local c = RefSet("foo", "qux")
      local result = a:intersection(b, c)
      assert.equal(1, result:size())
      assert(result:has("foo"))
    end)
  end)

  describe(':clear() -> RefSet', function()
    it('removes all the items from a set', function()
      local s = RefSet(1, 2, 3)
      assert.same(3, s:size())
      s:clear()
      assert.no(s:has(1))
      assert.no(s:has(2))
      assert.no(s:has(3))
      assert.same(0, s:size())
    end)
  end)

  describe(':each(Element -> void) -> RefSet', function()
    it('calls fn for each element', function()
      local s = RefSet("foo", "bar", "baz")
      local seen = RefSet()
      local r = s:each(function(x) seen:add(x) end)
      assert(seen:equals(s))
      -- doesn't modify theset
      assert(s:equals(RefSet("foo", "bar", "baz")))
      -- returns the initial set
      assert(s == r)
    end)
  end)

  describe(':map(Element -> *) -> RefSet<*>', function()
    it('calls fn for each element in the set', function()
      local s = RefSet("foo", "FOO", "bar", "BAR")
      local result = s:map(function(v) return string.lower(v) end)
      assert(RefSet("foo", "bar"):equals(result))
    end)
  end)

  describe(':filter', function()
    it('returns a new filtered set', function()
      local s = RefSet(1, 2, 3, 4, 5, 6)
      local result = s:filter(function(v) return v % 2 == 0 end)
      assert(RefSet(2, 4, 6):equals(result))
    end)
  end)

  describe(':flatMap(fn: Element -> RefSet) -> RefSet', function()
    it('flatMaps into a single RefSet', function()
      local numbers = RefSet(1, 2)
      local multiples = function(n)
        return RefSet(n, n * 2)
      end
      local result = numbers:flatMap(multiples)
      assert(result:equals(RefSet(1, 2, 4)))
    end)

    it('handles empty sets', function()
      local empty = RefSet()
      local result = empty:flatMap(function(x) return RefSet(x * 2) end)
      assert.equal(0, result:size())
    end)
  end)

  -- TODO
  -- describe(':difference(...RefSet) -> RefSet', function() end)
end)
