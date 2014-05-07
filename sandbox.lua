require('deepcopy')
local copy = table.deepcopy
local pairs = pairs
local typeof = type

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
    takes in a table and locks the metatable of all children in that table
]]
local function freezeMetatables(table)
    for k,v in pairs(table) do
        if typeof(v)==table and ((not getmetatable(v)) or (not (getmetatable(v).__metatable))) then
            local tbl = getmetatable(v) or {};
            tbl.__metatable = {__metatable = true}; --Only expose the information that the metatable is locked to viewing/editing
            setmetatable(v, tbl);
        end
    end
    for k,v in pairs(table) do
        if typeof(v)==table then
            freezeMetatables(v)
        end
    end
end

--[[
    func is the function to sandbox
    blacklist is the list of sensitive functions we know 
    we need to remove from the global environment
]]
local function sandbox(func, blacklist)
    local _Gcopy = copy(_G)
    removeViaHash(_Gcopy, blacklist)
    freezeMetatables(_Gcopy)
    local fcopy = loadstring(string.dump(func), nil, nil, _Gcopy) --Copy the function and reload it to pickle upvalues
    
    setfenv(fcopy, _Gcopy)
    return fcopy()
end


return sandbox
