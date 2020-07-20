os.loadAPI("/p/bta.lua")

local args = {...}
local width = tonumber(args[1])
local depth
if args[2] == nil then
    depth = width
else
    depth = tonumber(args[2])
end

bta.buildPlatform(width, depth)