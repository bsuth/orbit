local _ = require('erde.rules.helpers')

return {
  UnaryOp = {
    pattern = _.PadC(_.S('~-#')) * _.CsV('Expr'),
    compiler = function(op, expr)
      return op == '~'
        and ('not %s'):format(expr)
        or op .. expr
    end,
  },
  TernaryOp = {
    pattern = _.V('SubExpr') * _.Pad('?') * _.V('Expr') * _.Pad(':') * _.V('Expr'),
    compiler = _.iife('if %1 then return %2 else return %3 end'),
  },
  BinaryOp = {
    pattern = _.V('SubExpr') * _.Product({
      _.PadC(_.Sum({
        '+', _.P('-') - _.P('--'), '*', '//', '/', '^', '%', -- arithmetic
        '.|', '.&', '.~', '.>>', '.<<',     -- bitwise
        '==', '~=', '<=', '>=', '<', '>',   -- relational
        '&', '|', '..', '??',               -- misc
      })),
      _.V('Expr'),
    }),
    compiler = function(lhs, op, rhs)
      if op == '??' then
        return _.iife('local %1 = %2 if %1 ~= nil then return %1 else return %3 end')(_.newtmpname(), lhs, rhs)
      elseif op == '&' then
        return ('%s and %s'):format(lhs, rhs)
      elseif op == '|' then
        return ('%s or %s'):format(lhs, rhs)
      else
        return lhs .. op .. rhs
      end
    end,
  },
  AssignOp = {
    pattern = _.Product({
      _.V('Id'),
      _.Pad(_.C(_.Sum({
        '+', '-', '*', '//', '/', '^', '%', -- arithmetic
        '.|', '.&', '.~', '.>>', '.<<',     -- bitwise
        '&', '|', '..', '??',               -- misc
      })) * _.P('=')),
      _.V('Expr'),
    }),
    compiler = function(id, op, expr)
      if op == '??' then
        -- TODO: consider optional assign
        return 
      elseif op == '&' then
        return _.template('%1 = %1 and %2')(id, expr)
      elseif op == '|' then
        return _.template('%1 = %1 or %2')(id, expr)
      else
        return _.template('%1 = %1 %2 %3')(id, op, expr)
      end
    end,
  },
  Operation = {
    pattern = _.Sum({
      _.V('UnaryOp'),
      _.V('TernaryOp'),
      _.V('BinaryOp'),
      _.V('AssignOp'),
    }),
    compiler = _.echo,
  },
}
