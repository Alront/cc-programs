os.loadAPI("/p/bta.lua")
local args = {...}
local height = args[1] or 6
local layers = args[2] or 1
print("Building Tower with layer height "..height.." and "..layers.." layers.")

for i = 1, layers do
    bta.buildPlatform(11)
    bta.buildPillarUp(height)
    turtle.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)
    turtle.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)
    turtle.left()
    bta.forward(10)
    bta.down(height)
    bta.buildPillarUp(height)

    turtle.turnLeft()
    turtle.turnLeft()
    bta.forward(10)
    turtle.turnRight()
end