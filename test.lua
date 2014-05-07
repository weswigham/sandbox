local sandbox = require('sandbox')

local blacklist = {
    debug = true,
    getfenv = true,
    print = true,
    require = true,
    dofile = true,
    loadfile = true,
    table = {
        deepcopy = true,
    }
}

local testfunc = function()
    assert(not debug)
    assert(not getfenv)
    assert(not print)
    assert(table)
    assert(not table.deepcopy)

    GLOBAL = true
    table.GLOBAL = true
    setmetatable(table, {meta = true})
    return GLOBAL
end

assert(sandbox(testfunc, blacklist))

assert(not GLOBAL)
assert(not table.GLOBAL)
assert(not getmetatable(table))
