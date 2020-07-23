os.loadAPI("/p/modules/module.lua")
module.load("bta")
local args = {...}
local layers = tonumber(args[1]) or 1
local height = tonumber(args[2]) or 6
print("Building Tower with layer height "..height.." and "..layers.." layers.")

bta.storeAsLastPosition()
for i = 1, layers do
    bta.buildPlatform(11)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)
    bta.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)

    bta.left()
    bta.left()
    bta.forward(10)
    bta.right()
end