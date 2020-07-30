os.loadAPI("/p/modules/module.lua")
module.load("message")
module.load("bta")
local name = os.getComputerLabel() or ("Anonymous"..os.getComputerID())
local prot = message.protocol("Items", nil, name)

-- requests items and stores them in the next free slots, counting from the currently selected one or the given one
function request(item, quantity, slotIndex, partial, modemSide, completeCallback)
    modemSide = modemSide or "left"
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
    prot.send(server, {
        title = "retreived"
    })
    return response.succcess
end

function storeAll(modemSide)
    modemSide = modemSide or "left"
    prot.side = modemSide
    prot.send("Server", {
        title = "store"
    })
end