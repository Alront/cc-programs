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
        local pulle = 0
        turtle.select(1)
        turtle.suck(math.min(m.quantity, 64))
        local pulled = turtle.getItemCount()
        while pulled < m.quantity and turtle.getItemCount() > 0 do
            bta.inv.nextSlot()
            while turtle.getItemCount() > 0 do
                pulled = pulled + turtle.getItemCount()
                bta.inv.nextSlot()
            end
            turtle.suck(math.max(m.quantity - pulled, 0))
            pulled = pulled + turtle.getItemCount()
        end
        response.quantity = pulled
        response.success = m.quantity == response.quantity or m.partial
        if not response.success then
            for i = 1, 16 do
                turtle.select(i)
                if turtle.getItemCount() == 0 then
                    break
                end
                turtle.drop()
            end
            print("Failed to provide "..m.quantity.." "..item.."(s), only "..response.quantity.." were available :'(")
        else
            bta.moveTo(bta.makePos(0, 0, 0, orientation))
            for i = 1, 16 do
                turtle.select(i)
                if turtle.getItemCount() == 0 then
                    break
                end
                sendFunc()
            end
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
orientation = bta.getOrientationFromSide(side)

-- Make the eintire inventory available to cycle through
for i = 1, 16 do
    bta.inv[i] = bta.inv.slots.normal
end

print("Waiting to provide "..item.." and sending into inventory on side "..side)
prot = message.protocol("Items", "left", item, handleMessage)
prot.run()
