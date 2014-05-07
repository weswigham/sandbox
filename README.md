sandbox
=======

A lua library aimed at making sandboxed calls to untrusted functions simple.

Here's a simple example:
```lua
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
```

`sandbox` takes three arguments -
```
sandbox(function [, blacklist, additions])
```
The function is the function that needs ot be sandboxed (note: we can't sandbox a C function, only lua ones).
The blacklist is an object containing a set of keys that aught not to be copied from `_G` into the fake environment.
The additions table is an object that is merged with the _G copy, so you are able to make things appear in scope to the function to the sandbox, if you need to.


