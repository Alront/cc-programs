os.loadAPI("/p/modules/module.lua")
module.load("bta")

local args = {...}
local size = tonumber(args[1])
bta.storeAsLastPosition()
bta.up()
bta.buildRow(size)
bta.right()
bta.buildRow(size)
bta.right()
bta.buildRow(size)
bta.right()
bta.buildRow(size)
