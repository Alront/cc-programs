-- Message api

function protocol(protocol, side, name, handleMessageFunc)
    local prot
    local function ensureOpened()
        if not prot.opened then
            prot.open()
        end
    end

    prot = {

        opened = false,
        protocol = name,
        messageHandler = handleMessageFunc or function() end,

        send = function(reciever, message)
            ensureOpened()
            if type(reciever) == "string" then
                reciever = rednet.lookup(name, reciever)
            end
            rednet.send(reciever, message, name)
        end,

        receive = function(timeout)
            ensureOpened()
            tiemout = timeout or 5
            id, message, _ = rednet.receive(name, timeout)
            return id, message
        end,

        open = function()
            if prot.opened then return end
            rednet.open(side)
            rednet.host(protocol, name)
            prot.opened = true
        end,

        run = function()
            prot.open()
            while true do
                prot.messageHandler(prot.receive(10000000))
            end
        end,

        receiveWithTitle = function(title, otherMessages, notReceivedFunc, timeout)
            local provider, reply = prot.receive(timeout)
            notReceivedFunc = notReceivedFunc or function() print("Did not receive response with title "..title) end
            otherMessages = otherMessages or {}
            if reply == nil then
                notReceivedFunc()
                return nil, nil
            end
            while reply.title ~= title do
                table.insert(otherMessages, {provider, reply})
                provider, reply = prot.recveive()
                if reply == nil then
                    return notReceivedFunc()
                end
            end
            return provider, reply
        end,

        handleOtherMessage = function(otherMessages)
            for _, message in ipairs(otherMessages) do
                prot.messageHandler(message[1], message[2])
            end
        end,
    }
    return prot
end