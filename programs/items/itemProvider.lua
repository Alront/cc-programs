os.loadAPI("/p/modules/module.lua")
module.load("message")
module.load("bta")

local prot
local orientation
local sendFunc
local item

local function handleMessage(sender, m)
    if m ~= nil and m.title == "provide" then
        response = {
            title = "provided"
        }
        turtle.suck(m.quantity)
        response.quantity = turtle.getItemCount()
        response.success = m.quantity == response.quantity or m.partial
        if not response.success then
            turtle.drop()
            print("Failed to provide "..m.quantity.." "..item.."(s), only "..response.quantity.." were available :'(")
        else
            bta.moveTo(bta.makePos(0, 0, 0, orientation))
            sendFunc()
            bta.moveTo(bta.makePos(0, 0, 0, 0))
            print("Provided "..response.quantity.." "..item.."(s)")
        end
        prot.send(sender, response)
        return
    end
    m = m or "nil"
    print("Unknown message: "..tostring(m))
end

-- takes as arguments the item name and optionally the side of the send chest
local args = {...}
item = args[1]
local side = args[2] or "top"
sendFunc = bta.getDropFromSide(side)

-- Reset in case something happened and turtle got stuck last time
bta.moveTo(bta.makePos(0, 0, 0, 0))
turtle.drop()

print("Waiting to provide "..item.." and sending into inventory on side "..side)
prot = message.protocol("Items", "left", item, handleMessage)
prot.run()
