os.loadAPI("/p/modules/module.lua")
module.load("file")
module.load("message")
module.load("bta")


local flushTo
local flushFrom
local modemSide

local function takeItems()
    bta.turnToSide(flushFrom)
    local suck = bta.getSuckFromSide(flushFrom)
    local tookAny = false
    for i = 1, 16 do
        turtle.select(i)
        suck()
        if turtle.getItemCount() > 0 then
            tookAny = true
        else
            break;
        end
    end
    return tookAny
end

local function dumpItems()
    bta.turnToSide(flushTo)
    local drop = bta.getDropFromSide(flushTo)
    for i = 1, 16 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            drop()
        else
            break;
        end
    end
end

function flushChest()
    local more = takeItems()
    while more do
        dumpItems()
        more = takeItems()
    end
end

local prot

--[[
    message layouts:

    Item request:
    {
        title: "request"
        partial: bool
        1: {item = ..., quantity = ...}
        2: {item = ..., quantity = ...}
        ...
        12: {item = ..., quantity = ...}
    }

    Item response:
    {
        title: request_processed
        success: [bool]
        message: error or something
        1: {item = ..., quantity = ...}
        ...
        12: {item = ..., quantity = ...}
    }

    Items retrieved:
    {
        title: retreived
    }

    Provision request:
    {
        title: "provide"
        partial: bool
        quantity: ...
    }

    Provision reply [in case of insuficient items available, store the items back to the inventory]
    {
        title: "provided"
        success: bool
        quantity: ...
    }

    Storage request
    {
        title: "store"
    }
]]

function handleItemRequest(sender, m)
    local insufficient = {}
    local response = {
        title = "request_processed"
    }
    local otherMessage = {}

    for i, request in ipairs(m) do
        prot.send(request.item, {
            title = "provide",
            quantity = request.quantity
        })
        local provider, reply = prot.receiveWithTitle("provided", otherMessage,
            function()
                response.success = false
                response.message = "Unable to locate provider for "..request.item
                prot.send(sender, response)
                return
            end
        )

        if not reply.succcess then
            insufficient[request.item] = "Only had "..reply.quantity.." "..request.item.." while needing "..request.quantity
        end
        response[i] = {
            item = request.item,
            quantity = reply.quantity
        }
    end
    if #insufficient > 0 then
        response.success = false
        response.message = "Could not aquire sufficient items:"
        for item, message in insufficient do
            response.message = response.message.."\n"..message
        end
        prot.send(sender, response)
        print(response.message)
    else
        response.success = true
        response.message = "Request sucessfully provisioned!"
        prot.send(sender, response)
        local message
        for i = 1, 3 do
            _, message = prot.receiveWithTitle("retreived", otherMessage, function()
                print("Requester has not yet confirmed that items have been received, retrying...")
            end, 60)
            if message ~= nil then break end
        end
        if message == nil then
            print("Did not receive retreival acknowledgement, flushing chest")
        else
            print("Request successfully completed!")
        end
    end
    flushChest()
    prot.handleOtherMessages(otherMessage)
end

function handleMessage(sender, m)
    if type(m) == "table" then
        if m.title == "request" then
            handleItemRequest(sender, m)
        else
            print("Unknown message title: "..m.title)
        end
    else
        print("Unsupported message type: "..m)
    end
end

local args = {...}
flushTo = args[1] or "front"
flushFrom = args[2] or "top"
modemSide = args[3] or "left"

print("Running Item server and listening to item requests...")
prot = message.protocol("Items", modemSide, "Server", handleMessage)
prot.run()

