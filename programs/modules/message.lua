-- Message api

function protocol(protName, side, name, handleMessageFunc)
    local prot
    local function ensureOpened()
        if not prot.opened then
            prot.open()
        end
    end
    side = side or "left"

    prot = {

        opened = false,
        messageHandler = handleMessageFunc or function() end,
        side = side,

        lookup = function(name)
            return rednet.lookup(protName, name)
        end,

        send = function(reciever, message)
            ensureOpened()
            if type(reciever) == "string" then
                reciever = rednet.lookup(protName, reciever)
            end
            --print("Sending message to id "..reciever..": "..textutils.serialize(message))
            rednet.send(reciever, message, protName)
        end,

        receive = function(timeout)
            ensureOpened()
            tiemout = timeout or 5
            local id, message, _ = rednet.receive(protName, timeout)
            --print("Received message from id "..id..": "..textutils.serialize(message))
            return id, message
        end,

        open = function()
            if prot.opened then return end
            rednet.open(prot.side)
            rednet.host(protName, name)
            prot.opened = true
        end,

        run = function()
            prot.open()
            while true do
                local id, message = prot.receive(10000000)
                prot.messageHandler(id, message)
            end
        end,

        receiveWithTitle = function(title, otherMessages, notReceivedFunc, timeout)
            local sender, message = prot.receive(timeout)
            notReceivedFunc = notReceivedFunc or function() print("Did not receive response with title "..title) end
            otherMessages = otherMessages or {}
            if message == nil then
                notReceivedFunc()
                return nil, nil
            end
            while message.title ~= title do
                --print("Got messsage "..textutils.serialize(message).." while waiting for message with title "..title)
                table.insert(otherMessages, {sender, message})
                sender, message = prot.receive(timeout)
                if message == nil then
                    return notReceivedFunc()
                end
            end
            return sender, message
        end,

        handleOtherMessages = function(otherMessages)
            for _, message in ipairs(otherMessages) do
                prot.messageHandler(message[1], message[2])
            end
        end,
    }
    return prot
end