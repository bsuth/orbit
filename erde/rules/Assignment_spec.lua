-- -----------------------------------------------------------------------------
-- Parse
-- -----------------------------------------------------------------------------

describe('Assignment.parse', function()
  spec('name assignment', function()
    assert.has_subtable({
      idList = { { value = 'a' } },
      exprList = { { value = '3' } },
    }, parse.Assignment(
      'a = 3'
    ))
  end)

  spec('optchain assignment', function()
    assert.has_subtable({
      idList = { { ruleName = 'OptChain' } },
      exprList = { { value = '3' } },
    }, parse.Assignment(
      'a.b = 3'
    ))
    assert.has_subtable({
      idList = { { ruleName = 'OptChain' } },
      exprList = { { value = '3' } },
    }, parse.Assignment(
      'a?.b = 3'
    ))
  end)

  spec('multiple name assignment', function()
    assert.has_subtable({
      idList = {
        { value = 'a' },
        { value = 'b' },
      },
      exprList = {
        { value = '1' },
        { value = '2' },
      },
    }, parse.Assignment(
      'a, b = 1, 2'
    ))
  end)

  spec('multiple optchain assignment', function()
    assert.has_subtable({
      idList = {
        { ruleName = 'OptChain' },
        { ruleName = 'OptChain' },
      },
      exprList = {
        { value = '1' },
        { value = '2' },
      },
    }, parse.Assignment(
      'a?.b, x?.y = 1, 2'
    ))
  end)

  spec('binop assignments', function()
    assert.has_subtable({
      op = { token = '+' },
      idList = { { value = 'a' } },
      exprList = { { value = '1' } },
    }, parse.Assignment(
      'a += 1'
    ))
    assert.has_subtable({
      op = { token = '+' },
    }, parse.Assignment(
      'a, b += 1, 2'
    ))
    assert.has_subtable({
      op = { token = '+' },
    }, parse.Assignment(
      'a?.b, x?.y += 1, 2'
    ))

    assert.are.equal('nc', parse.Assignment('a ??= 1').op.tag)
    assert.are.equal('or', parse.Assignment('a |= 1').op.tag)
    assert.are.equal('and', parse.Assignment('a &= 1').op.tag)
    assert.are.equal('bor', parse.Assignment('a .|= 1').op.tag)
    assert.are.equal('bxor', parse.Assignment('a .~= 1').op.tag)
    assert.are.equal('band', parse.Assignment('a .&= 1').op.tag)
    assert.are.equal('lshift', parse.Assignment('a .<<= 1').op.tag)
    assert.are.equal('rshift', parse.Assignment('a .>>= 1').op.tag)
    assert.are.equal('concat', parse.Assignment('a ..= 1').op.tag)
    assert.are.equal('add', parse.Assignment('a += 1').op.tag)
    assert.are.equal('sub', parse.Assignment('a -= 1').op.tag)
    assert.are.equal('mult', parse.Assignment('a *= 1').op.tag)
    assert.are.equal('div', parse.Assignment('a /= 1').op.tag)
    assert.are.equal('intdiv', parse.Assignment('a //= 1').op.tag)
    assert.are.equal('mod', parse.Assignment('a %= 1').op.tag)
    assert.are.equal('exp', parse.Assignment('a ^= 1').op.tag)
  end)

  spec('binop blacklist', function()
    assert.has_error(function()
      parse.Assignment('a >>= 1')
    end)
    assert.has_error(function()
      parse.Assignment('a ?= 1')
    end)
    assert.has_error(function()
      parse.Assignment('a === 1')
    end)
    assert.has_error(function()
      parse.Assignment('a ~== 1')
    end)
    assert.has_error(function()
      parse.Assignment('a <== 1')
    end)
    assert.has_error(function()
      parse.Assignment('a >== 1')
    end)
    assert.has_error(function()
      parse.Assignment('a <= 1')
    end)
    assert.has_error(function()
      parse.Assignment('a >= 1')
    end)
  end)
end)

-- -----------------------------------------------------------------------------
-- Compile
-- -----------------------------------------------------------------------------

describe('Assignment.compile', function()
  spec('name assignment', function()
    assert.run(
      1,
      compile.Block([[
        local a
        a = 1
        return a
      ]])
    )
  end)

  spec('optchain assignment', function()
    assert.run(
      1,
      compile.Block([[
        local a = {}
        a.b = 1
        return a.b
      ]])
    )
    assert.run(
      nil,
      compile.Block([[
        local a
        a?.b = 1
        return a?.b
      ]])
    )
  end)

  spec('multiple name assignment', function()
    assert.run(
      3,
      compile.Block([[
        local a, b
        a, b = 1, 2
        return a + b
      ]])
    )
  end)

  spec('multiple optchain assignment', function()
    assert.run(
      3,
      compile.Block([[
        local a, b = {}, {}
        a.c, b.d = 1, 2
        return a.c + b.d
      ]])
    )
    assert.run(
      -1,
      compile.Block([[
        local a, b
        a?.c, b?.d = 1, 2
        return a?.c ?? b?.d ?? -1
      ]])
    )
  end)

  spec('binop assignment', function()
    assert.run(
      3,
      compile.Block([[
        local a = 1
        a += 2
        return a
      ]])
    )
    assert.run(
      4,
      compile.Block([[
        local a = 5
        a .&= 6
        return a
      ]])
    )
    assert.run(
      8,
      compile.Block([[
        local a, b = 1, 2
        a, b += 2, 3
        return a + b
      ]])
    )
  end)
end)
