os.loadAPI("/p/modules/module.lua")
module.load("bta")

args = {...}
bta.resetCoordinates()
shell.run("moveTo "
    ..tostring(args[1]).." "
    ..tostring(args[2]).." "
    ..tostring(args[3]).." "
    ..tostring(args[4]).." "
    ..tostring(args[5]).." "
    ..tostring(args[6]).." "
)
