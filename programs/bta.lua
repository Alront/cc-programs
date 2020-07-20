fuelSlots = {16}

function foreach(list, consumerFunc)
    local i = 1
    while list[i] ~= nil do
        if consumerFunc(list[i]) then break end
        i = i+1
    end
end

function refuel()
    local lastIndex = turtle.getSelectedSlot()
    foreach(fuelSlots, function(slot) 
        turtle.select(slot)
        if turtle.refuel() then return true end
    end)
    turtle.select(lastIndex)
end

function place(placeFunc)
    placeFunc = placeFunc or turtle.place()
    while turtle.getItemCount() == 0 do
        local isFuelSlot = false
        foreach(fuelSlots, function(slot) 
            if fuelSlots[slot] == turtle.getSelectedSlot() then
                isFuelSlot = true
                return true
            end
        end)
        if ~isFuelSlot then
            turtle.select((turtle.getSelectedSlot() + 1) % 16 + 1)
        end
    end
    placeFunc()
end

function placeDown()
    place(turtle.placeDown)
end

function placeUp()
    place(turtle.buildUp)
end

function move(movementFunc, length)
    length = length or 1
    for i = 1, length do 
        while(turtle.getFuelLevel() == 0) do refuel() end
        while not movementFunc() do end
    end
end

function forward(length)
    move(turtle.forawrd, length)
end

function up(length)
    move(turtle.up, length)
end

function down(length)
    move(turtle.down, length)
end

function buildMany(moveFunc, placeFunc, length)
    for i = 1, length - 1 do
        placeFunc()
        moveFunc()
    end
    placeFunc()
end

function buildRow(rowLength)
    buildMany(forward, placeDown, rowLength)
end

function buildPlatform(width, depth)
    local builtRows = 0
    while true do
        buildRow(depth)
        builtRows = builtRows + 1
        if(builtRows == width) then break end
        if(builtRows % 2 == 0) then
            turtle.turnRight()
            forward()
            turtle.turnRight()
        else 
            turtle.turnLeft()
            forward()
            turtle.turnLeft()
        end
    end
end

function buildPillarUp(height)
    buildMany(up, placeDown, height + 1)
end
