os.loadAPI("/p/bta.lua")
args = {...}
local fileName = args[1]
if fileName == "dig" and args[2] == nil then
    fileName = nil
end
local dig = args[2]
if fileName then
    bta.moveTo(bta.loadPosition(fileName), dig)
else
    bta.moveTo(bta.loadLastPosition(), dig)
end