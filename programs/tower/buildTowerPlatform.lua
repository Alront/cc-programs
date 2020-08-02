local args = {...}

local holeSize = 0
if(args[1] ~= nil) then
local arg = tonumber(args[1])
  holeSize = 2 * math.floor(arg / 2) + 1
end

local storageSize = 16
local debugging = true
local pausing = false

local rightSide = false

--measurement dependant
local n, cornerWidth, restHole, width, quarterWidth, current = 0


---debuggings
function wait()
  if debugging then
    if pausing then
      print("Press any key...")
      os.pullEvent("char")
    end
  end
end

function debugInfo()
  if(debugging) then
    print("Width: "..width)
    print("CornerWidth: "..cornerWidth)
    print("QuarterWidth: "..quarterWidth)
    print("RestHole: "..restHole)
    print("Current: "..current)
    print("CurrentStep: "..n)
    print("RightSide: "..tostring(rightSide))
    print("Doubles: "..getDoubles())
  end
end

function printDebug(str)
  if(debugging) then
    print(str)
  end
end


function oneEighty()
	turtle.turnLeft()
	turtle.turnLeft()
end

function turnRight()
  if(rightSide == true) then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

function turnLeft()
  if(rightSide == true) then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
end

function checkMaterial(startingSlot, endSlot)
  if(turtle.getSelectedSlot() >= endSlot or turtle.getSelectedSlot() < startingSlot) then
    turtle.select(startingSlot)
  end
  while (turtle.getItemCount() < 1) and not (turtle.getSelectedSlot() >= endSlot) do
    turtle.select(turtle.getSelectedSlot() + 1)
  end
  term.clearLine()
  if(turtle.getItemCount() < 1) then
    term.write("Please refill materials...")
    sleep(10)  
    checkMaterial(startingSlot, endSlot)
  end
end

function blockDown()
  checkMaterial(1, storageSize)
  return turtle.placeDown()
end

function forwards(abstand)
  local turn = false
  if abstand < 0 then
    abstand = -abstand
    oneEighty()
    turn = true
  end
  for k = 1, abstand do
    turtle.forward()
  end
  if turn then oneEighty() end
end

function buildLine(distance)
  blockDown()
  for i = 1, distance-1 do
    turtle.forward()
    blockDown()
  end
end

function measure()
  if(not turtle.down()) then
    oneEighty()
    turtle.forward()
    turtle.down()
    oneEighty()
  end
  oneEighty()
  width = 1
  while turtle.forward() do
    width = width + 1
  end
  turtle.up()
  turtle.turnLeft()
  turtle.forward()
  turtle.turnLeft()
  current = (width - 5) / 2 + 1
  quarterWidth = math.ceil(width/2)
  n = getCurrentStep()
  cornerWidth = 5 + n
  restHole = math.max(math.ceil(holeSize / 2) - getDoubles() * 3, 0)
  debugInfo()
  wait()
end

function curve(right)
  if right then 
    turnRight()
  else 
    turnLeft() 
  end
  turtle.forward()
  if right then 
    turnRight()
  else 
    turnLeft() 
  end
end

function doQuarter(level)
  rightSide = true
  
  local doubles = getDoubles()
  printDebug("Doing doubles before corner. Doubles: "..doubles)
  local i = 0
  while i < doubles do
    doDouble(i)
    i = i + 1
  end
  
  doCorner()
  
  printDebug("Did corner, doing doubles. Doubles: "..doubles)
  wait()
  
  forwards(doubles * 3)  
  turtle.turnLeft()
  forwards(quarterWidth - cornerWidth - doubles * 3)
  oneEighty()
  
  rightSide = false
  i = 0
  while i < doubles do
    doDouble(i)
    i = i + 1
  end
  turtle.turnLeft()
  
  printDebug("Did doubles, assuming starting position")
  wait()
  
  forwards(doubles * 3)  
  turtle.turnLeft()
  forwards(quarterWidth - cornerWidth - doubles * 3)
  oneEighty()  
end

function doDouble(rank)
  printDebug("Doing double...")
  local right = false
  local change = false
  local dist = quarterWidth - rank * 2 - math.ceil(holeSize / 2)
  for i = 1, 3 do
    if (not change and not (rank * 3 + i <= math.ceil(holeSize / 2))) then
      dist = quarterWidth - rank * 2
      change = true
    end
    buildLine(dist)
    curve(right)
    right = not right
  end
  forwards(dist-1)
  oneEighty()
  buildLine(2)
  turtle.forward()
end

function doCorner()
  printDebug("Doing corner...")
  local dist = cornerWidth - restHole
  local i = 0
  local found = false
  
  
  function addI()
    i = i + 1
    printDebug("i: "..i)
    if not found and i > restHole then
      printDebug("Ended Resthole!")
      found = true
      dist = dist + restHole
      printDebug("Dist before: "..(dist - restHole)..", Dist now: "..dist)
    end
  end
  
  function lineAndBack()
    printDebug("Doing lineAndBack")
    addI()
    buildLine(dist)
    oneEighty()
    forwards(math.max(0, dist - 1))
  end
  
  function roundCorner()
    turtle.forward()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
  end
  
  lineAndBack()
  curve(true)
  lineAndBack()
  curve(true)
  lineAndBack()
  
  if(n >= 3) then
    curve(true)
    lineAndBack()
    oneEighty()
    turtle.forward()
    dist = dist - 2
  else
    oneEighty()
    dist = dist - 1
  end
  
  roundCorner()
  lineAndBack()

  if(n == 5) then
    oneEighty()
    roundCorner()
    dist = dist - 1
  else
    curve(true)
  end
  
  lineAndBack()
  
  if(n == 5) then
    curve(true)
  elseif(n == 2 or n == 4) then
    oneEighty()
    roundCorner()
    dist = dist - 1
  end
  
  if(n == 2 or n == 4 or n == 5) then
    lineAndBack()
  end
  
  oneEighty()
  turtle.forward()
  roundCorner()
  dist = dist - 2
  lineAndBack()
  
  if(n == 5) then
    oneEighty()
    roundCorner()
    dist = dist - 1
    lineAndBack()
  end
  
  if(n >= 3) then
    curve(true)
    lineAndBack()
  end
  
  oneEighty()
  forwards(dist - 1)
end

function getDoubles()
  return math.floor((current - 4)/5)  
end

function getCurrentStep()
  return ((current - 4) % 5) + 1
end
    
-------------Main Program--------------

measure()

for i = 1, 4 do
  printDebug("Doing quarter "..i)
  debugInfo()
  wait()
  doQuarter()
end