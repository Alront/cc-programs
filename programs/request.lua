os.loadAPI("/p/modules/module.lua")
module.load("item")
module.load("file")

-- Usage request item quantity [partial] [modemside]

function processInput(t)
    local success = (
            t == "thanks" or 
            t == "t_hanks" or 
            t == "t hanks" or 
            t == "thx" or 
            t == "ty" or 
            t == "thank you" or
            t == "thx dude"
    )
    if not success then
        if (
            t == "fuck you" or
            t == "fu" or
            t == "no"
        ) then
            print("That was pretty mean, please don't be mean :'(")
        end
    end
    return success
end


local sideFile = "modemSide"

local args = {...}

if args[1] == nil then
    print("Usage: request item quantity [partial] [modemside]")
    return
end

args[2] = args[2] or 1

local modemSide = file.loadValue(sideFile, args[4])

if modemSide == nil then
    if pocket then
        modemSide = "back"
    else
        modemSide = "left"
    end
end

file.storeValue(modemSide, sideFile)

print("Requested items.")
item.request(args[1], tonumber(args[2]), nil, args[3], modemSide, function()
    print("Write \"thanks\" to contiunue once the items have been retreived form the ender chest.")
    local input = read()
    while not processInput(input) do
        print("Write \"thanks\" to contiunue once the items have been retreived form the ender chest.")
        input = read()
    end
    return true
end)

