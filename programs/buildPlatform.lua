local args = {...}
local width = args[1]
local depth
if args[2] == nil then
    depth = width
else
    depth = args[2]
end

local function buildDown()
    while turtle.getItemCount() == 0 do
        turtle.select(turtle.getSelectedSlot() + 1)
    end
    turtle.placeDown()
end

local function forward(length)
    for i = 1, length do 
        while(turtle.getFuelLevel() == 0) do turtle.refual() end
        turtle.forward()
    end
end

local function buildRow(rowLength)
    for i = 1, rowLength do
        buildDown()
        forward(1)
    end
end

local builtRows = 0
while builtRows < width do
    buildRow(depth)
    if(builtRows % 2 == 0) then
        turtle.turnRight()
        forward(1)
        turtle.turnRight()
    else 
        turtle.turnLeft()
        forward(1)
        turtle.turnLeft()
    end
    builtRows = builtRows + 1
end