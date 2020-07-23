os.loadAPI("/p/modules/module.lua")
module.load("bta")

bta.recordPosition("home")
print("Set home location to "..bta.posString(bta.p))