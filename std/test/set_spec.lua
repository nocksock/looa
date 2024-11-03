---@diagnostic disable: unused-local
local spy = require 'luassert.spy'
local set = require 'std.lib.set'
local tbl = require 'std.lib.tbl'

local dbg = require 'std.lib.dbg'

describe('RefSet<Element>', function()
  it('works for functions and tables', function()
    local t = {}
    local f = function() end
    local s = set(t, f)
    assert(s:has(t))
    assert(s:has(f))
  end)

  describe(':set(...Element) -> RefSet', function()
    it("sets the set's value", function()
      local s = set("foo", "FOO", "bar", "BAR")
      s:set(1, 2, 3)
      assert(set(1, 2, 3):equals(s))
    end)
  end)

  describe(":has(Element) -> Boolean", function()
    it('checks if set has element', function()
      local s = set("foo", "bar")
      local b = set("baz", "bier")
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
    local a = set(1)
    local b = set(4)
    local c = set(1, 4)
    local endresult = set(1, 4, 7, 8)
    local add = spy.new(set.add)
    ---@diagnostic disable-next-line: assign-type-mismatch
    set.add = add
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
      local s = set("foo", "bar", "baz")
      assert(s:hasSome("foo", "baz"))
      assert(not s:hasSome("nope"))
    end)
  end)

  describe(':add(...Element)', function()
    -- also ensuring that instances don't leak
    it('adds an element', function()
      local s = set()
      assert(not s:has("foo"))
      assert(not s:has("baz"))
    end)

    it('doesnt add the same element twice', function()
      local s = set("foo", "bar")
      s:add("foo")
      assert.equal(2, s:size())
      assert(s:has("foo"))
      assert(s:has("bar"))
    end)
  end)

  describe(':remove(Element) -> RefSet', function()
    it('removes an element and updates size', function()
      local s = set("foo", "bar")
      s:remove("foo")
      assert.equal(1, s:size())
      assert(not s:has("foo"))
    end)

    it('does nothing when removing a non-existing element', function()
      local s = set("foo", "bar")
      s:remove("baz")
      assert.equal(2, s:size())
      assert(s:has("bar"))
    end)
  end)

  describe(':toggle(Element) -> RefSet', function()
    it('removes or adds an item depending on its existence', function()
      local s = set("foo", "bar")
      s:toggle("bar")
      assert(not s:has("bar"))
      s:toggle("bar")
      assert(s:has("bar"))
    end)

    it('can take multiple', function()
      local s = set("foo", "bar", "baz")
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
      local s = set("foo", "bar")
      assert.equal(2, s:size())
    end)
  end)

  describe(':entries() -> Element[]', function()
    it('returns the entries', function()
      local t = {}
      local s = set("foo", "bar", t)
      local e = s:entries()
      assert(tbl.has(e, "foo"))
      assert(tbl.has(e, "bar"))
      assert(tbl.has(e, t))
      -- changes to the returned table don't affect the set
      table.insert(e, "baz")
      assert(not s:has("baz"))
    end)
  end)

  describe(':copy() -> RefSet', function()
    it('duplicates a set', function()
      local a = set("foo", "bar")
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
      local a = set("foo", "bar", t)
      local b = set(t, "bar", "foo")
      assert(a:equals(b))
      -- assert(a == b) -- TODO: do I want this? Postponing until I tried the bookkeeping version
    end)
  end)

  describe(':union(...RefSet) -> RefSet', function()
    it('creates a new set contain all elements of both', function()
      local a = set("foo", "bar") -- note: same strings are referentially equal in lua
      local b = set("foo", "baz")
      local c = a:union(b)

      assert.equal(3, c:size())
      assert(c:has("foo"))
      assert(c:has("bar"))
      assert(c:has("baz"))
    end)
  end)

  describe(':contains(...RefSet) -> RefSet', function()
    it('checks if one set contains another', function()
      local a = set("foo", "bar", "baz")
      local b = set("foo", "bar")
      local c = set("nope")

      assert(a:contains(b), "a contains b")
      assert(not b:contains(a), "b does not contain a")
      assert(not a:contains(c), "a does not conain c")
    end)
  end)

  describe(':isSubsetOf(RefSet) -> Boolean)', function()
    it('checks if a set is a subset of another', function()
      local a = set("foo", "bar", "baz")
      local b = set("foo", "bar")
      local c = set("nope")

      assert(b:isSubsetOf(a), "b is subset of a")
      assert(not a:isSubsetOf(b), "a is not subset of b")
      assert(not c:isSubsetOf(a), "c is not subset of a")
    end)
  end)

  describe(':isSupersetOf(RefSet) -> Boolean)', function()
    it('checks if a set is a superset of another', function()
      local a = set("foo", "bar", "baz")
      local b = set("foo", "bar")
      local c = set("nope")

      assert(a:isSupersetOf(b), "a is superset of b")
      assert(not b:isSupersetOf(a), "b is not superset of a")
      assert(not a:isSupersetOf(c), "a is not superset of c")
    end)
  end)

  describe(':intersection(...Element) -> RefSet', function()
    it('returns a set of elements common to other sets', function()
      local a = set("foo", "bar", "baz")
      local b = set("foo", "bar", "qux")
      local c = set("foo", "qux")
      local result = a:intersection(b, c)
      assert.equal(1, result:size())
      assert(result:has("foo"))
    end)
  end)

  describe(':clear() -> RefSet', function()
    it('removes all the items from a set', function()
      local s = set(1, 2, 3)
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
      local s = set("foo", "bar", "baz")
      local seen = set()
      local r = s:each(function(x) seen:add(x) end)
      assert(seen:equals(s))
      -- doesn't modify theset
      assert(s:equals(set("foo", "bar", "baz")))
      -- returns the initial set
      assert(s == r)
    end)
  end)

  describe(':map(Element -> *) -> RefSet<*>', function()
    it('calls fn for each element in the set', function()
      local s = set("foo", "FOO", "bar", "BAR")
      local result = s:map(function(v) return string.lower(v) end)
      assert(set("foo", "bar"):equals(result))
    end)
  end)

  describe(':filter', function()
    it('returns a new filtered set', function()
      local s = set(1, 2, 3, 4, 5, 6)
      local result = s:filter(function(v) return v % 2 == 0 end)
      assert(set(2, 4, 6):equals(result))
    end)
  end)

  describe(':flatMap(fn: Element -> RefSet) -> RefSet', function()
    it('flatMaps into a single RefSet', function()
      local numbers = set(1, 2)
      local multiples = function(n)
        return set(n, n * 2)
      end
      local result = numbers:flatMap(multiples)
      assert(result:equals(set(1, 2, 4)))
    end)

    it('handles empty sets', function()
      local empty = set()
      local result = empty:flatMap(function(x) return set(x * 2) end)
      assert.equal(0, result:size())
    end)
  end)

  -- TODO
  -- describe(':difference(...RefSet) -> RefSet', function() end)
end)
