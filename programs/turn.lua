os.loadAPI("/p/bta.lua")

args = {...}
bta.storeAsLastPosition()
if args[1] == nil then
    bta.left()
    bta.left()
elseif args[1] == "left" then
    bta.left()
elseif args[1] == "right" then
    bta.right()
end