local constants = require('erde.constants')

-- -----------------------------------------------------------------------------
-- Parse
-- -----------------------------------------------------------------------------

describe('Name.parse', function()
  spec('name rule', function()
    assert.are.equal('Name', parse.Name('a').rule)
  end)

  spec('name', function()
    assert.are.equal('x', parse.Name('x').value)
    assert.are.equal('hello', parse.Name('hello').value)
    assert.are.equal('hello_world', parse.Name('hello_world').value)
    assert.are.equal('h1', parse.Name('h1').value)
    assert.has_error(function()
      parse.Name('1h')
    end)
  end)

  spec('prevent keyword names', function()
    for _, keyword in pairs(constants.KEYWORDS) do
      assert.has_error(function()
        parse.Name(keyword)
      end)
    end
  end)
end)

-- -----------------------------------------------------------------------------
-- Compile
-- -----------------------------------------------------------------------------

describe('ArrowFunction.compile', function()
  -- TODO
end)
