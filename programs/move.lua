os.loadAPI("/p/modules/module.lua")
module.load("bta")

local args = {...}
local distance = 1
if args[1] then
    distance = tonumber(args[1])
end
bta.storeAsLastPosition()
bta.forward(distance, args[2])