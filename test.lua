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

local testfunc = function(str)
    assert(not debug)
    assert(not getfenv)
    assert(not setfenv)
    assert(table)
    assert(not table.deepcopy)

    GLOBAL = true
    table.GLOBAL = true
    setmetatable(_G, {meta = true})
    setmetatable(table, {meta = true})
    
    assert(getmetatable(_G).meta)
    assert(getmetatable(table).meta)
    
    assert(GLOBAL)
    assert(table.GLOBAL)
    
    assert(KEYS)
    assert(KEYS[1] == "key1") --never forget, 1-indexing
    assert(KEYS[2] == "key2")
    assert(ARGV)
    assert(ARGV[1] == "value1")
    assert(ARGV[2] == "value2")
    
    assert(print("This shouldn't print")=='Overriden!')
    return str..' and returned from it!'
end

print("Starting tests...")

assert(sandbox(testfunc, {'This was passed to the fucntion'}, blacklist, additions)=='This was passed to the fucntion and returned from it!')

assert(not GLOBAL)
assert(not table.GLOBAL)
assert(not getmetatable(_G))
assert(not getmetatable(table))

print("Tests passed.")
