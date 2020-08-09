os.loadAPI("/p/modules/module.lua")

module.load("bta")
module.load("multiblock")


local casing = "reactorCasing"
local controlRod = "controlRod"
local resonantEnder = "resonantEnder"
local fuelRod = "fuelRod"

local size = tonumber(args[1]) or 7
local height = tonumber(args[2]) or 7

-- -1 because coordinates start at 0
size = size  -1
height  = height  -1

local function isFuelRod(x, y)
    if x < 2 or x > size - 2 or y < 2 or y > size - 2 then
        return false
    end
    if (x + y) % 2 == 0 then
        return true
    else
        return false
    end
end

local p = bta.makePos
local b = multiblock.layoutBuilder()

b.addCube(p(0, 0, 0), p(size, size, 0), casing) -- floor

b.addCube(p(0, 0, 1), p(size, 0, height - 1), casing) -- wall
b.addCube(p(size, 0, 1, 3), p(size, size, height - 1, 3), casing) --wall
b.addCube(p(size, size, 1, 2), p(0, size, height - 1, 2), casing) --wall
b.addCube(p(0, size, 1, 1), p(0, 0, height - 1, 1), casing) --wall

b.addCube(p(1, 1, 1), p(size - 1, size - 1, height - 1), function(x, y) -- inside
    if isFuelRod(x, y) then
        return fuelRod
    else
        return { resonantEnder }
    end
end)

b.addCube(p(0, 0, height), p(size, size, height), function(x, y) -- ceiling
    if isFuelRod(x, y) then
        return controlRod
    else
        return casing
    end
end)

multiblock.build(b.finalize())