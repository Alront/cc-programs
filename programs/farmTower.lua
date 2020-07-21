os.loadAPI("/p/bta.lua")
local args = {...}
local height = args[1] or 6
local layers = args[2] or 1
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