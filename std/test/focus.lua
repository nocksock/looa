require 'globals'
local spy = require 'luassert.spy'
local RefSet = require 'std.lib.ref_set'

describe('fokus', function()
  it('caches set operations', function()
    local a = RefSet(1, 2, 3)
    local b = RefSet(4, 5, 6)
    local union = spy.new(RefSet.union)
    ---@diagnostic disable-next-line: assign-type-mismatch
    RefSet.union = union
    assert.spy(union).was.called(0)
    assert(a:union(b):equals(RefSet(1, 2, 3, 4, 5, 6)))
    assert.spy(union).was.called(1)
    assert(a:union(b):equals(RefSet(1, 2, 3, 4, 5, 6)))
    assert.spy(union).was.called(1)
    a:add(7)
    a:add(7)
    assert(a:union(b):equals(RefSet(1, 2, 3, 4, 5, 6, 7)))
    assert.spy(union).was.called(2)
  end)
end)
