require('deepcopy')
local copy = table.deepcopy
local pairs = pairs
local typeof = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local unpack = unpack
local setfenv = setfenv
local loadstring = loadstring
local dump = string.dump

--[[
    Removes elements arbitrarily deep in a hash
]]
local function removeViaHash(table, toRemove)
    for k,v in pairs(toRemove) do
        if table[k] and v==true then
            table[k] = nil
        elseif typeof(table[k])=='table' then
            removeViaHash(table[k], v)
        end
    end
    return table
end

--[[
    merges table b into a, overriding values in a
]]
local function merge(a, b)
    for k,v in pairs(b) do
        if typeof(v)=='table' then
            a[k] = merge(a[k] or {}, b[k] or {})
        else
            a[k] = b[k]
        end
    end
    return a
end

--[[
    func is the function to sandbox
    blacklist is the list of sensitive functions we know 
    we need to remove from the global environment
    additions are anything we want to inject into the global environment for this call
]]
local function sandbox(func, args, blacklist, additions)
    local _Acopy = copy(additions) or {}
    local _Gcopy = copy(_G)
    removeViaHash(_Gcopy, blacklist or {})
    local _env = merge(_Gcopy, _Acopy)
    
    local fcopy = loadstring(dump(func), nil, nil, _env) --Copy the function and reload it to pickle upvalues
    
    setfenv(fcopy, _env)
    return fcopy(unpack(args or {}))
end


return sandbox
