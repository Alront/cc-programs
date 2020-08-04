os.loadAPI("/p/modules/module.lua")

module.load("bta")
module.load("multiblock")

p = bta.makePos

local b = multiblock.layoutBuilder()

b.add(p(1, 1, 0), "glass")
b.addCube(p(0, 0, 1), p(2, 2, 3), function(x, y, z)
    local ret
    if (x + y + z) % 2 == 0 then
        ret = "glass"
    else
        ret = {"water"}
    end
    --print(x.." "..y.." "..z.." "..ret)
    return ret
end)

--b.finalize()
multiblock.build(b.finalize())
