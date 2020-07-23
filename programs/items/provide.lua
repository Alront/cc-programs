
local args = {...}

local item = args[1]
local side = args[2] or "top"

local string = "shell.run(\"/p/items/itemProvider.lua "..item.." "..side.."\")"
local file = fs.open("/startup.lua", "w")
file.write(string)
file.close()
os.setComputerLabel(item.." provider")
shell.run("reboot")

