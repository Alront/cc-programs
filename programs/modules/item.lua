os.loadAPI("/p/modules/module.lua")
module.load("message")
module.load("bta")
module.load("file")

local name = os.getComputerLabel() or ("Anonymous"..os.getComputerID())
local prot = message.protocol("Items", nil, name)
local sideFile = "modemSide"

-- requests items and stores them in the next free slots, counting from the currently selected one or the given one
-- completeCallback is an optional the function that gets called to check if the items have been retreived, 
--  if unspecified the items are simply pulled out of the ender chest in the turtles "items" slot
-- returns if the request was successful (always true in case of a partial request where a provider exists)
function request(item, quantity, slotIndex, partial, modemSide, completeCallback)
    --print("Requesting...")

    if modemSide == nil then
        modemSide = file.loadValue(sideFile, "left")
    else
        file.storeValue(modemSide, sideFile)
    end

    prot.side = modemSide
    if slotIndex ~= nil then
        turtle.select(slotIndex)
    end
    if partial == nil then
        partial = true
    end
    
    local request = {
        title = "request",
        partial = partial,
        name = name
    }
    if type(item) == "string" then
        assert(type(quantity) == "number")
        request[1] = {item = item, quantity = quantity}
    else
        assert(type(item) == "table")
        assert(type(quantity) == "table")
        for i, requestedItem in ipairs(item) do
            request[i] = {requestedItem, quantity[i]}
        end
    end
    print("Sending request for "..item)
    prot.send("Server", request)
    local server, response = prot.receiveWithTitle("request_processed")
    print(response.message)
    if response.success then
        if completeCallback then
            while not completeCallback() do sleep(1) end
        else
            bta.inv.pull(bta.inv.items)
        end
    end
    if slotIndex ~= nil then
        turtle.select(slotIndex)
    end
    prot.send(server, {
        title = "retreived"
    })
    --print("Returning from request function: "..tostring(response.success))
    return response.success
end

-- sends a request to store all items currently in the items ender chest
function storeAll(modemSide)
    modemSide = modemSide or "left"
    prot.side = modemSide
    prot.send("Server", {
        title = "store"
    })
end

function dumpInv()
    bta.inv.placeChest()
    bta.inv.select(bta.inv.slots.normal)
    for i = 1, 16 do
        bta.inv.nextSlot()
        bta.drop(nil, "up")
    end
    bta.inv.removeChest()
    storeAll()
    sleep(5)
end
