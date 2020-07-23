os.loadAPI("/p/modules/module.lua")
module.load("message")
module.load("bta")

-- requests items and stores them in the next free slots, counting from the currently selected one or the given one
function request(item, quantity, slotIndex, partial, modemSide, completeCallback)
    modemSide = modemSide or "left"
    if slotIndex ~= nil then
        turtle.select(slotIndex)
    end
    if partial == nil then
        partial = true
    end

    local prot

    prot = message.protocol("Items", modemSide, os.getComputerLabel() or ("Anonymous"..os.getComputerID()))
    local request = {
        title = "request",
        partial = partial,
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
            bta.pull(bta.inv.items)
        end
    end
    prot.send(server, {
        title = "retreived"
    })
    return response.succcess
end