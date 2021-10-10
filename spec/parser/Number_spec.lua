local parser = require('erde.parser.number')

spec('valid integer', function()
  assert.are.equal('9', parser.unit('9'))
  assert.are.equal('43', parser.unit('43'))
end)

spec('invalid integer', function()
  assert.has_error(function()
    parser.unit('')
  end)
end)

spec('valid hex', function()
  assert.are.equal('0x4', parser.unit('0x4'))
  assert.are.equal('0xd', parser.unit('0xd'))
  assert.are.equal('0Xf', parser.unit('0Xf'))
  assert.are.equal('0xa8F', parser.unit('0xa8F'))
end)

spec('invalid hex', function()
  assert.has_error(function()
    parser.unit('x3')
  end)
  assert.has_error(function()
    parser.unit('0x')
  end)
  assert.has_error(function()
    parser.unit('0xg')
  end)
  assert.has_error(function()
    parser.unit('4xg')
  end)
end)

spec('valid integer exponent', function()
  assert.are.equal('9e2', parser.unit('9e2'))
  assert.are.equal('9E21', parser.unit('9E21'))
  assert.are.equal('9e+2', parser.unit('9e+2'))
  assert.are.equal('9e-2', parser.unit('9e-2'))
end)

spec('invalid integer exponent', function()
  assert.has_error(function()
    parser.unit('9e')
  end)
  assert.has_error(function()
    parser.unit('9e+')
  end)
  assert.has_error(function()
    parser.unit('9e-')
  end)
  assert.has_error(function()
    parser.unit('e2')
  end)
end)

spec('valid float', function()
  assert.are.equal('.34', parser.unit('.34'))
  assert.are.equal('0.3', parser.unit('0.3'))
  assert.are.equal('10.33', parser.unit('10.33'))
end)

spec('invalid float', function()
  assert.has_error(function()
    parser.unit('4.')
  end)
end)

spec('valid float exponent', function()
  assert.are.equal('9.2e2', parser.unit('9.2e2'))
  assert.are.equal('9.01E21', parser.unit('9.01E21'))
  assert.are.equal('0.1e+2', parser.unit('0.1e+2'))
  assert.are.equal('.8e-2', parser.unit('.8e-2'))
end)

spec('invalid float exponent', function()
  assert.has_error(function()
    parser.unit('9.1e')
  end)
  assert.has_error(function()
    parser.unit('9.1e+')
  end)
  assert.has_error(function()
    parser.unit('9.1e-')
  end)
end)
