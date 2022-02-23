-- -----------------------------------------------------------------------------
-- OptChain
-- -----------------------------------------------------------------------------

local OptChain = { ruleName = 'OptChain' }

-- -----------------------------------------------------------------------------
-- Parse
-- -----------------------------------------------------------------------------

function OptChain.parse(ctx)
  local node = {}

  if ctx.token == '(' then
    node.base = ctx:Surround('(', ')', ctx.Expr)
    if type(node.base) == 'table' then
      node.base.parens = true
    end
  elseif ctx.token == '$' then
    node.base = ctx:Self()
  else
    node.base = ctx:Name()
  end

  while true do
    local backup = ctx:backup()
    local chain = { optional = ctx:branch('?') }

    if ctx:branch('.') then
      local name = ctx:Try(ctx.Name)

      if name then
        chain.variant = 'dotIndex'
        chain.value = name
      else
        -- Do not throw error here, as '.' may be from an operator! Simply
        -- revert consumptions and break
        ctx:restore(backup)
        break
      end
    elseif ctx.token == '[' then
      chain.variant = 'bracketIndex'
      chain.value = ctx:Surround('[', ']', ctx.Expr)
    elseif ctx.token == '(' then
      chain.variant = 'functionCall'
      chain.value = ctx:Parens({
        demand = true,
        rule = function()
          return ctx:List({
            allowEmpty = true,
            allowTrailingComma = true,
            rule = function()
              return ctx:Switch({
                -- Spread must be before Expr, otherwise we will parse the
                -- spread as varargs!
                ctx.Spread,
                ctx.Expr,
              })
            end,
          })
        end,
      })
    elseif ctx:branch(':') then
      local methodName = ctx:Try(ctx.Name)

      if methodName and ctx.token == '(' then
        chain.variant = 'method'
        chain.value = methodName
      elseif ctx.isTernaryExpr then
        -- Do not throw error here, instead assume ':' is from ternary
        -- operator. Simply revert consumptions and break
        ctx:restore(backup)
        break
      else
        error('Missing parentheses for method call')
      end
    else
      ctx:restore(backup) -- revert consumption from ctx:branch('?')
      break
    end

    table.insert(node, chain)
  end

  if #node == 0 then
    -- unpack trivial OptChain
    node = node.base

    if type(node) == 'string' then
      if not node:match('^[_a-zA-Z][_a-zA-Z0-9]*$') then
        error('Arbitrary expressions not allowed as OptChains')
      end
    elseif node.ruleName ~= 'Self' and node.ruleName ~= 'OptChain' then
      error('Arbitrary expressions not allowed as OptChains')
    end
  end

  return node
end

-- -----------------------------------------------------------------------------
-- Compile
-- -----------------------------------------------------------------------------

function OptChain.compile(ctx, node)
  local optChain = ctx:compileOptChain(node)

  if #optChain.optSubChains == 0 then
    return optChain.chain
  end

  local optChecks = {}
  for i, optSubChain in ipairs(optChain.optSubChains) do
    optChecks[i] = 'if ' .. optSubChain .. ' == nil then return end'
  end

  return table.concat({
    '(function()',
    table.concat(optChecks, '\n'),
    'return ' .. optChain.chain,
    'end)()',
  }, '\n')
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return OptChain
