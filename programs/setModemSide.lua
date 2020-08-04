os.loadAPI("/p/modules/module.lua")

module.load("file")

local sideFile = "modemSide"

args = {...}
if not args[1] then
    print("Usage: setModemSide side_string")
    return
end 

file.storeValue(args[1], sideFile)