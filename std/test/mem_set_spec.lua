local RefSet = require('std.lib.ref_set')
local MemSet = require('std.lib.mem_set')
local spy = require 'luassert.spy'

describe('MemSet', function()
  it('is a Proxy for RefSet that caches set operations and invalidates automatically', function()
    local a = MemSet(1, 2, 3)
    local b = MemSet(4, 5, 6)
    local union = spy.new(RefSet.union)
    ---@diagnostic disable-next-line: assign-type-mismatch
    RefSet.union = union
    assert(a:union(b):equals(MemSet(1, 2, 3, 4, 5, 6)))
    assert.spy(union).was.called(1)
    assert(a:union(b):equals(MemSet(1, 2, 3, 4, 5, 6)))
    assert.spy(union).was.called(1)
    a:add(7)
    b:add(8)
    assert(a:union(b):equals(MemSet(1, 2, 3, 4, 5, 6, 7, 8)))
    assert.spy(union).was.called(2)
  end)
end)
