os.loadAPI("/p/modules/module.lua")
module.load("bta")

local args = {...}
if args[1] == nil or args[2] == nil then
    print("usage: moveTo x y [z] [d] [dig] [extraHeight]")
    print("z and d can be set as \"nil\" to use the current position value")
    return
end
local x = tonumber(args[1])
local y = tonumber(args[2])
local z
if args[3] == nil or args[3] == "nil" then
    z = bta.p.z
else
    z = tonumber(args[3])
end
local d
if args[4] == nil or args[4] == "nil" then
    d = bta.p.d
else
    d = tonumber(args[4])
end
local dig = true
if args[5] == nil or args[5] == "false" or args[5] == "nil" then
    dig = false
end
local extraHeight = 0
if args[6]  and args[6] ~= "nil" then
    extraHeight = tonumber(args[6])
end
local target = bta.makePos(x, y, z, d)
print("Moving from "..bta.posString(bta.p).." to "..bta.posString(target).." with extra height "..extraHeight..". Digging through obstacles: "..tostring(dig))

bta.storeAsLastPosition()
bta.up(extraHeight)
bta.moveTo(target, dig)