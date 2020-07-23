bta = {}

message = {}
message.protocol = (protocol, side, name, handleMessageFunc) end

module = {}

item = {}
item.request = function(item, quantity, slotIndex, partial, modemSide) end

file = {
    function loadFromFile(fileName, keys, stringConversion) end
    function exists(name) end
    function setFileContent(name, content, wipe) end
    function loadValue(fileName, default) end
    function storeValue(value, fileName) end
}

shell = {}
shell.run = function(command) end

function sleep(seconds) end

peripheral = {}

textutils = {}