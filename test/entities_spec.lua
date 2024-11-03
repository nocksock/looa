-- WIP: this is in an outdated state
require 'lib.entities'

describe('Entities', function()
  it('can create named entities', function()
    assert.equal(1, Entity:create("player"))
    assert.equal(2, Entity:create("ball"))
    assert.equal(1, Entity:get("player"))
    assert.equal(2, Entity:get("ball"))
  end)

  -- TODO: implement a Entity:destroyAll()
  -- needs to clean up components as well.
  it('returns an increasing index', function()
    assert.equal(3, Entity:create())
    assert.equal(4, Entity:create())
  end)
end)
