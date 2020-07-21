local btaDir = "/bta/"
local btaPath = "/bta"
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
    return "[ "..pos.x..", "..pos.y..", "..pos.z..", "..pos.d.." ]"
end

function ensureBtaDir()
    if not fs.exists(btaPath) and fs.isDir(btaPath) then
        fs.makeDir(btaPath)
    end
end

function loadPosition(fileName)
    ensureBtaDir()
    fileName = fileName or posFile
    local filePath = btaDir..fileName
    if fs.exists(filePath) then
        local file = fs.open(filePath, "r")
        local pos = {}
        pos.x = tonumber(file.readLine())
        pos.y = tonumber(file.readLine())
        pos.z = tonumber(file.readLine())
        pos.d = tonumber(file.readLine())
        file.close()
        return pos
    else
        print("No position file present: assuming 0, 0, 0, 0")
        return makePos(0, 0, 0, 0)
    end
end
p = loadPosition()
print("Loaded position "..posString(p))

function recordPosition(fileName, pos)
    pos = pos or p
    fileName = fileName or posFile
    ensureBtaDir()
    local file = fs.open(btaDir..fileName, "w")
    file.writeLine(tostring(pos.x))
    file.writeLine(tostring(pos.y))
    file.writeLine(tostring(pos.z))
    file.writeLine(tostring(pos.d))
    file.close()
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
    move(turtle.up, function() p.z = p.z + 1 end, length, failureFunc)
end

function down(length, failureFunc)
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
    local x = pos.x
    local y = pos.y
    local z = pos.z
    local d = pos.d
    local failureFuncStraigth
    local failureFuncUp
    local failureFuncDown
    if dig then
        failureFuncStright = turtle.dig
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
    forward(movement.length, failureFuncStright)
    
    movement = closestLineMove(p, makePos(x, y))
    turnTo(movement.direction)
    forward(movement.length, failureFuncStright)

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
    normal = "normal", fuel = "fuel", building = "building", temp = "temp",
}

local inv = {}

local function initInv()
    inv.size = 16
    for i = 1, 13 do
        inv[i] = slots.normal
    end
    inv[14] = slots.temp
    inv[15] = slots.building
    inv[16] = slots.fuel

    for i, name in pairs(inv) do
        if inv[name] == nil then
            inv[name] = i
        end
    end
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

function clearTemp()
    if turtle.getItemCount(inv.temp) > 0 then
        while not turtle.drop(inv.temp) do end
    end
end

function refuel()
    print("refueling...")
    local originalSlot = turtle.getSelectedSlot()
    -- Make space
    clearTemp()
    turtle.select(inv.temp)
    turtle.dig()
    -- Place chest
    turtle.select(inv.fuel)
    turtle.place()
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
    turtle.dig()
    turtle.select(inv.temp)
    turtle.place()
    turtle.select(originalSlot)
end

function restock()
    print("refueling...")
    -- Make space
    clearTemp()
    turtle.select(inv.temp)
    turtle.dig()
    -- Place chest
    turtle.select(inv.building)
    turtle.place()
    -- Restock
    for i, slot in pairs(inv) do
        if slot == slots.normal then
            turtle.select(i)
            turtle.suck()
        end
    end
    -- Restore state
    turtle.select(inv.building)
    turtle.dig()
    turtle.select(inv.temp)
    turtle.place()
    inv.select(slots.normal)
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
    if not hasMaterial then restock() end
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
