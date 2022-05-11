spec('break / continue', function()
  assert.formatted(' break ', 'break')
  assert.formatted(' continue ', 'continue')
end)

spec('goto', function()
  assert.formatted(' goto   blah ', 'goto blah')
  assert.formatted('::   blah ::', ' ::blah:: ')
end)

spec('try catch', function()
  assert.formatted(
    [[
  try 
  {} 

  catch    {}
]],
    [[
try {

} catch {

}
]]
  )
  assert.formatted(
    [[
  try 
  {} 

  catch  x   {}
]],
    [[
try {

} catch x {

}
]]
  )
end)

spec('if', function()
  assert.formatted(
    [[
   if test 
   { 
}
]],
    [[
if test {

}
]]
  )
end)

spec('if-elseif', function()
  assert.formatted(
    [[
 if test1
 { 
} elseif test2 {}
]],
    [[
if test1 {

} elseif test2 {

}
]]
  )
  assert.formatted(
    [[
 if test1
 { 
} elseif test2 {} elseif
test3{}
]],
    [[
if test1 {

} elseif test2 {

} elseif test3 {

}
]]
  )
end)

spec('if-else', function()
  assert.formatted(
    [[
 if test 
 { }
else{}
]],
    [[
if test {

} else {

}
]]
  )
end)

spec('if-elseif-else', function()
  assert.formatted(
    [[
 if test 
 { 
} elseif test {}
else{}
]],
    [[
if test {

} elseif test {

} else {

}
]]
  )
end)
