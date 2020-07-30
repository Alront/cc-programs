local posFile = "_bta_position"
local prevPosFile = "_bta_lastPosition"
p = {
    x = 0,
    y = 0,
    z = 0,
    d = 0
}

-- returns a position that is the addtion of the coordinate vectors and the orientation of the first
function addPos(p1, p2)
    return makePos(p1.x + p2.x, p1.y + p2.y, p1.z+ p2.z, p1.d)
end

dir = {
    plusX = 0,
    minusY = 1,
    minusX = 2,
    plusY = 3
}

local function orDefault(value, default)
    if value == nil then
        return default
    else
        return value
    end
end

function makePos(x, y, z, d)
    x = orDefault(x, 0)
    y = orDefault(y, 0)
    z = orDefault(z, 0)
    d = orDefault(d, 0)
    return {
        x = x,
        y = y,
        z = z,
        d = d
    }
end

function posString(pos)
    if pos == nil then
        return "[nil position]"
    end
    local x, y, z, d
    x = orDefault(pos.x, "nil")
    y = orDefault(pos.y, "nil")
    z = orDefault(pos.z, "nil")
    d = orDefault(pos.d, "nil")
    return "[ "..x..", "..y..", "..z..", "..d.." ]"
end

-- returns orientation, "up/down/front"
function getOrientationFromSide(side)
    local front = "front"
    local up = "up"
    local down = "down"
    if side == "front" then
        return 0, front
    elseif side == "back" then
        return 2, front
    elseif side == "left" then
        return 1, front
    elseif side == "right" then
        return 3, front
    elseif side == "top" or side == "up" then
        return 0, up
    elseif side == "bottom" or side == "down" then
        return 0, down
    end
end

function getDropFromSide(side)
    local _, upDown = getOrientationFromSide(side)
    if upDown == "front" then return turtle.drop
    elseif upDown == "up" then return turtle.dropUp
    else return turtle.dropDown end
end

function getSuckFromSide(side)
    local _, upDown = getOrientationFromSide(side)
    if upDown == "front" then return turtle.suck
    elseif upDown == "up" then return turtle.suckUp
    else return turtle.suckDown end
end

function getDigFromSide(side)
    local _, upDown = getOrientationFromSide(side)
    if upDown == "front" then return turtle.dig
    elseif upDown == "up" then return turtle.digUp
    else return turtle.digDown end
end

function getMoveFromSide(side)
    local _, upDown = getOrientationFromSide(side)
    if upDown == "front" then return forward
    elseif upDown == "up" then return up
    else return down end
end

-- turn to a side, where the side is absolute to the 0 (front) direction of the coord grid
function turnToSide(side)
    local d, _ = getOrientationFromSide(side)
    d = (p.d + d) % 4
    turnTo(d)
end

function loadPosition(fileName)
    module.load("file")
    fileName = fileName or posFile
    if file.exists(fileName) then
        return file.loadFromFile(fileName, { "x", "y", "z", "d" }, tonumber)
    else
        --print("No position file present: assuming 0, 0, 0, 0")
        return makePos(0, 0, 0, 0)
    end
end

p = loadPosition()
--print("Loaded position "..posString(p))

function recordPosition(fileName, pos)
    pos = pos or p
    fileName = fileName or posFile
    module.load("file")
    file.setFileContent(fileName, { pos.x, pos.y, pos.z, pos.d}, true)
end

function resetCoordinates()
    p = makePos(0, 0, 0, 0)
    recordPosition()
end

function storeAsLastPosition(pos)
    pos = pos or p
    recordPosition(prevPosFile, pos)
end

function loadLastPosition()
    return loadPosition(prevPosFile)
end

function waitCantMove()
    print("Cannot move, path obstructed")
    sleep(3)
end


local function move(movementFunc, posUpdateFunc, length, failureFunc)
    length = orDefault(length, 1)
    failureFunc = failureFunc or waitCantMove
    if length <= 0 then return end
    for i = 1, length do
        while(turtle.getFuelLevel() == 0) do refuel() end
        while not movementFunc() do
            failureFunc()
        end
        posUpdateFunc()
        recordPosition()
    end
end

function forward(length, failureFunc)
    if failureFunc ~= nil and type(failureFunc) ~= "function" then
        failureFunc = turtle.dig
    end
    local updateFunc = function()
        if p.d == 0 then
            p.x = p.x + 1
        elseif p.d == 1 then
            p.y = p.y - 1
        elseif p.d == 2 then
            p.x = p.x - 1
        elseif p.d == 3 then
            p.y = p.y + 1
        end
    end
    move(turtle.forward, updateFunc, length, failureFunc)
end

function up(length, failureFunc)
    if failureFunc ~= nil and type(failureFunc) ~= "function" then
        failureFunc = turtle.digUp
    end
    move(turtle.up, function() p.z = p.z + 1 end, length, failureFunc)
end

function down(length, failureFunc)
    if failureFunc ~= nil and type(failureFunc) ~= "function" then
        failureFunc = turtle.digDown
    end
    move(turtle.down, function() p.z = p.z - 1 end, length, failureFunc)
end

function left()
    turtle.turnLeft()
    p.d = (p.d + 1) % 4
    recordPosition()
end

function right()
    turtle.turnRight()
    p.d = (p.d + 3) % 4
    recordPosition()
end

math.sign = function(v)
    if v >= 0 then
        return 1
    elseif v < 0 then
        return -1
    end
end

function turnTo(d)
    d = d % 4
    if d == p.d then
        return
    end
    if math.abs(d - p.d) == 2 then
        left()
        left()
    else
        if (p.d + 1) % 4 == d then
            left()
        else
            right()
        end
    end
end


-- returns an with a direction and a length
local function closestLineMove(from, to)
    if from.x == to.x and from.y == to.y then
        return { direction = from.d, length = 0 }
    end

    if math.abs(from.x - to.x) > math.abs(from.y - to.y) then
        return { direction = -math.sign(to.x - from.x) + 1, length = math.abs(from.x - to.x) }
    else
        return { direction = math.sign(to.y - from.y) + 2, length = math.abs(from.y - to.y) }
    end
end

function moveTo(pos, dig)
    --print("Moving to "..posString(pos))
    local x = pos.x
    local y = pos.y
    local z = pos.z
    local d = pos.d
    local failureFuncStraigth
    local failureFuncUp
    local failureFuncDown
    if dig then
        failureFuncStraigth = turtle.dig
        failureFuncUp = turtle.digUp
        failureFuncDown = turtle.digDown
    else
        failureFuncStraigth = waitCantMove
        failureFuncUp = waitCantMove
        failureFuncDown = waitCantMove
    end
    
    if z > p.z then
        up(z - p.z, failureFuncUp)
    end
    local movement = closestLineMove(p, makePos(x, y))
    turnTo(movement.direction)
    forward(movement.length, failureFuncStraigth)
    
    movement = closestLineMove(p, makePos(x, y))
    turnTo(movement.direction)
    forward(movement.length, failureFuncStraigth)

    if z < p.z then
        down(p.z - z, failureFuncDown)
    end

    turnTo(d)
end

-- can be used as moveToRelative(x, y, z, d, dig) or moveToRelative(pos, dig)
function moveToRelative(x, y, z, d, dig)
    local pos
    if type(x) == "number" then
        pos = makePos(x, y, z, d)
    else
        pos = x
        dig = y
    end
    moveTo(addPos(pos, p), dig)
end

local slots = {
    normal = "normal", fuel = "fuel", building = "building", temp = "temp", items = "items"
}

inv = {
    slots = slots
}

local function initInv()
    inv.size = 16
    for i = 1, 16 do
        inv[i] = slots.normal
    end
    inv[13] = slots.items
    inv[14] = slots.temp
    inv[15] = slots.building
    inv[16] = slots.fuel

    for i, name in pairs(inv) do
        if inv[name] == nil then
            inv[name] = i
            inv.size = inv.size - 1
        end
    end
    inv.size = inv.size + 1 -- the first normal slot was subtracted as well
end
initInv()



function inv.nextSlot()
    turtle.select(turtle.getSelectedSlot() % inv.size + 1)
    return turtle.getSelectedSlot()
end

function inv.slotName(index)
    index = orDefault(index, turtle.getSelectedSlot())
    return inv[index]
end

function inv.select(name)
    turtle.select(inv[name])
end

local lastSlot

local function clearTemp()
    if turtle.getItemCount(inv.temp) > 0 then
        while not turtle.drop(inv.temp) do end
    end
end

function inv.placeChest(chestSlot)
    lastSlot = turtle.getSelectedSlot()
    -- Make space
    clearTemp()
    turtle.select(inv.temp)
    turtle.digUp()
    -- Place chest
    turtle.select(chestSlot)
    turtle.placeUp()
end

function inv.removeChest(chestSlot)
    inv.select(chestSlot)
    turtle.digUp()
    turtle.select(inv.temp)
    turtle.placeUp()
    turtle.select(lastSlot)
end

function inv.pull(chestSlot, quantity)
    quantity = orDefault(quantity, 64)
    local pulled = 0
    inv.placeChest(chestSlot)
    while quantity > pulled do
        while turtle.getItemCount() > 0 do
            inv.nextSlot()
        end
        turtle.suckUp(quantity)
        pulled = pulled + turtle.getItemCount()
        if turtle.getItemCount() == 0 then -- there are no more items to be pulled
            break
        end
    end
    inv.removeChest(chestSlot)
end

function refuel()
    print("refueling...")
    inv.placeChest(slots.fuel)
    -- Refuel
    local function isFullyFueled() return turtle.getFuelLevel() < turtle.getFuelLimit() - 4000 end
    while not isFullyFueled() do
        turtle.suck(1)
        while not turtle.refuel() do
            print("Can't use item as fuel!")
            sleep(5)
        end
    end
    -- Restore state
    inv.removeChest(slots.fuel)
end

function restock()
    print("restocking...")
    inv.placeChest(slots.building)
    -- Restock
    for i, slot in ipairs(inv) do
        if slot == slots.normal then
            turtle.select(i)
            turtle.suck()
        end
    end
    -- Restore state
    inv.removeChest(slots.building)
end

function place(placeFunc)
    placeFunc = placeFunc or turtle.place
    local hasMaterial = false
    for i = 1, inv.size do
        if(inv.slotName() ~= slots.normal or turtle.getItemCount() == 0) then
            inv.nextSlot()
        else
            hasMaterial = true
            break
        end
    end
    if not hasMaterial then
        while turtle.getItemCount() == 0 do
            restock()
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
    depth = depth or width
    local builtRows = 0
    while true do
        buildRow(depth)
        builtRows = builtRows + 1
        if(builtRows == width) then break end
        if(builtRows % 2 == 1) then
            right()
            forward()
            right()
        else
            left()
            forward()
            left()
        end
    end
end

function buildPillarUp(height)
    buildMany(up, placeDown, height + 1)
end
