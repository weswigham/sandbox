local sandbox = require('sandbox')

local unsafe_func = function()
  math.random = function() 
      return -1 --!!!
  end
  assert(math.random()==-1)
  return 'done'
end

assert(sandbox(unsafe_func)=='done') --calls the function in an isolated environment

assert(math.random()~=-1)