os.loadAPI("/p/modules/module.lua")
module.load("bta")
local args = {...}
local layers = tonumber(args[1]) or 1
local height = tonumber(args[2]) or 6
local size = tonumber(args[3]) or 11
print("Building Tower with layer height "..height.." and "..layers.." layers and "..size.." size.")

bta.storeAsLastPosition()
for i = 1, layers do
    bta.buildPlatform(size)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(size - 1)
    bta.down(height)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(size - 1)
    bta.down(height)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(size - 1)
    bta.down(height)
    bta.buildPillarUp(height)

    bta.left()
    bta.left()
    bta.forward(size - 1)
    bta.right()
end