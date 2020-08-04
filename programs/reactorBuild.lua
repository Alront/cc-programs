os.loadAPI("/p/modules/module.lua")

module.load("bta")
module.load("multiblock")

p = bta.makePos

local glass = "glass"
local dirt = "dirt"
local stone = "stone"
local water = "water"

local b = multiblock.layoutBuilder()

b.add(p(1, 1, 0), stone)
b.addCube(p(0, 0, 1), p(2, 2, 3), function(x, y, z)
    local ret
    if (x + y + z) % 2 == 0 then
        ret = "stone"
    else
        ret = "stone"
    end
    --print(x.." "..y.." "..z.." "..ret)
    return ret
end)

--b.finalize()
multiblock.build(b.finalize())
