local loaded = {}
local modulePath = "/p/modules/"

function load(name)
    if not loaded[name] then
        os.loadAPI(modulePath..name..".lua")
        loaded[name] = true
    end
end

function unload(name)
    if loaded[name] then
        os.unloadAPI(modulePath..name..".lua")
        loaded[name] = false
    end
end