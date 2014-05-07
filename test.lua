local sandbox = require('sandbox')

local blacklist = {
    debug = true,
    getfenv = true,
    setfenv = true,
    require = true,
    dofile = true,
    loadfile = true,
    table = {
        deepcopy = true,
    }
}

local additions = {
    ['ARGV'] = {
        "value1",
        "value2"
    },
    ['KEYS'] = {
        "key1",
        "key2"
    },
    print = function(...)
        return 'Overriden!'
    end
}

local testfunc = function()
    assert(not debug)
    assert(not getfenv)
    assert(not setfenv)
    assert(table)
    assert(not table.deepcopy)

    GLOBAL = true
    table.GLOBAL = true
    setmetatable(table, {meta = true})
    
    assert(KEYS)
    assert(KEYS[1] == "key1") --never forget, 1-indexing
    assert(KEYS[2] == "key2")
    assert(ARGV)
    assert(ARGV[1] == "value1")
    assert(ARGV[2] == "value2")
    
    assert(print("This shouldn't print")=='Overriden!')
    return GLOBAL
end

print("Starting tests...")

assert(sandbox(testfunc, blacklist, additions))

assert(not GLOBAL)
assert(not table.GLOBAL)
assert(not getmetatable(table))

print("Tests passed.")
