os.loadAPI("/p/modules/module.lua")
module.load("bta")
bta.resetCoordinates()
print("Reset coords to "..bta.posString(bta.p))