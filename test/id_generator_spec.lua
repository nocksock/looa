require 'lib.id_generator'
describe('IDGenerator', function()
  it('returns ids', function()
    local a = IDGenerator()
    local b = IDGenerator()
    assert.same(1, a())
    assert.same(2, a())
    assert.same(3, a())

    assert.same(1, b())
    assert.same(2, b())
  end)
end)
