rednet = {}
function rednet.open(side) end
function rednet.close(side) end
function rednet.send(receiverID, message, protocol) end
function rednet.broadcast(message, protocol) end
function rednet.receive(protocolFilter, timeout) end
function rednet.isOpen(side) end
function rednet.host(protocol, hostname) end
function rednet.unhost(protocol, hostname) end
function rednet.lookup(protocol, hostname) end