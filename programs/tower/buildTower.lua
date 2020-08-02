--slot 1 to storagesize: blocks
--slot storagesize + 1 to 2 * storagesize: stairs
--build level arg1 to arg2
--or expand tower by arg1 levels (middle must be free for measurements)

local pausing = false
local debugging = true

local args = {...}

local start, endlvl = 0

local pillarHeight = 5
local storageSize = 8

local rightSide = false
local sidesDone = 0
local abort = false
local current = 0

function wait()
  if debugging then
    debugInfo()
    print("Press any key...")
    if pausing then
      os.pullEvent("char")
    end
  end
end

function debugInfo()
  if(debugging) then
    print("Current: "..current)
    print("CurrentStep:"..getCurrentStep())
    print("RightSide: "..tostring(rightSide))
    print("Sides done: "..sidesDone)
  end
end

function printDebug(str)
  if(debugging) then
    print(str)
  end
end
  
--actual functions---------

function computeMaterials()
  local blocks = 0
  local stairs = 0
  local startlvl = math.max(start - 1, 0)
  local h = pillarHeight - 2
  if(start == 0) then
    stairs = stairs + 12
  end
  
  if(start <= 3) then
    local times = math.min(endlvl, 3) - startlvl
    blocks = blocks+  16 * h * times
    stairs = stairs+  times * 32
  end
  startlvl = math.max(3, start - 1)
  local lvls = endlvl  - startlvl
  if(lvls > 0) then
    local standartStairs = 6
    local standartBlocks = 3 * h
    local specialStairs = 10
    local specialBlocks = 5 * h
    local nSpecials = math.floor(((startlvl - 3) % 5 + lvls) / 5)
    local nStandarts = lvls - nSpecials
    
    local a = math.max(startlvl - 4, 0)
    local b = endlvl - 4
    local wb = math.floor(b / 5)
    local wa = math.floor(a / 5)
    local doubles = ((wb * (b - (5 - ((b % 5) % 5)))) / 2) - ((wa * (a - (5 - ((a % 5) % 5)))) / 2)
    
    blocks = blocks+  standartBlocks * nStandarts * 8 + specialBlocks * nSpecials * 8 + doubles * 2 * h * 8
    stairs = stairs+  standartStairs * nStandarts * 8 + specialStairs * nSpecials * 8 + doubles * 4 * 8
  end
  print(blocks.." blocks and "..stairs.." stairs will be needed. OK? (y/n)")
  local event, key = os.pullEvent("char") 
  if key ~= 'y' then 
    printDebug("Aborting...")
    abort = true
  end
end

function measure()
  printDebug("Measuring level...")
  oneEighty()
  local width = 1
  while turtle.forward() do
    width = width + 1
  end
  oneEighty()
  forwards(width - 1)
  start = (width - 5) / 2 + 2
  endlvl = start + args[1] - 1
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
  checkMaterials(1, storageSize)
  turtle.placeDown()
end

function blockFront()
  checkMaterials(1, storageSize)
  turtle.place()
end

function blockUp()
  checkMaterial(1, storageSize)
  turtle.placeUp()
end

function stairUp()
  checkMaterial(storageSize + 1, 2 * storageSize)
  turtle.placeUp()
end

function stairDown()
  checkMaterial(storageSize + 1, 2 * storageSize)
  turtle.placeDown()
end

function stairFront()
  checkMaterial(storageSize + 1, 2 * storageSize)
  turtle.placeFront()
end  

function oneEighty()
  turtle.turnLeft()
  turtle.turnLeft()
end

function pillarDown(height, type)
  printDebug("Making pillar with height "..height.." of type "..type)
  if(height < 2) then
    height = 2
  end
  
  if(type == 1) then turnRight() end
  stairUp()
  if(type == 1) then turnLeft() end
  
  for i = 1, height-2 do
    turtle.down()
    blockUp()
  end
  
  turtle.down()
  oneEighty()
  
  if(type == 2) then turnRight() end
  stairUp()
  if(type == 2) then turnLeft() end
end

function forwards(abstand)
  for k = 1, abstand do
    turtle.forward()
  end
end

function downwards(height)
  for i = 1, height do
    turtle.down()
  end
end

function upwards(height)
  for i = 1, height do
    turtle.up()
  end
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
  

function buildDouble()
  buildSingle(0)
  turnLeft()
  turtle.forward()
  turnLeft()
  buildSingle(0)  
end

function buildSingle(type)
  upwards(pillarHeight - 1)
  pillarDown(pillarHeight, type)
end

function stair()
  turtle.turnLeft()
  stairDown()
  turtle.turnRight()
end

function zeroLine()
  stair()
  turtle.forward()
  turtle.forward()
  stair()
  turtle.forward()
  stair()
end

function prepareZero()
  turtle.up()
  turtle.turnRight()  
  zeroLine()
  turtle.turnRight()
  turtle.forward()
  zeroLine()
  turtle.turnRight()
  turtle.forward()
  zeroLine()
  turtle.turnRight()
  turtle.forward()
  zeroLine()
  turtle.turnRight()
  turtle.forward()
  
  turtle.turnLeft()
end

function step(n)
  if(n <= 1) then stepA(2)
  elseif(n <= 2) then stepA(1)
  elseif(n <= 3) then stepB(2)
  elseif(n <= 4) then stepB(1)
  elseif(n <= 5) then stepC()
  end
end

function stepA(type)
  buildDouble()
  turnLeft()
  turtle.forward()
  turnRight()
  turtle.forward()
  oneEighty()
  buildSingle(type)
end

function stepB(type)
  buildDouble()
  turnLeft()
  turtle.forward()
  turtle.forward()
  turnRight()
  turtle.forward()
  turtle.forward()
  oneEighty()
  buildSingle(type)
end

function stepC()
  buildDouble()
  turnLeft()
  turtle.forward()
  turtle.forward()
  turnRight()
  turtle.forward()
  turtle.forward()
  oneEighty()
  buildDouble()
  turtle.forward()
  turnLeft()
  buildSingle(0)
  turnLeft()
end

function nextSide(n)
  sidesDone = sidesDone + 1
  if(n < 0) then
    if(sidesDone < 8) then
      if(not rightSide) then
        turtle.turnLeft()
        forwards(3)
        turtle.turnLeft()
      else
        turtle.turnLeft()
        forwards(-n)
        turtle.turnRight()
        forwards(-n + 1)
        turtle.turnLeft()
      end
    else
      printDebug("Level "..current.." done, moving on to next level")
      wait()
      sidesDone = 0
      turtle.turnRight()
      forwards(3)
      turtle.turnRight()
      turtle.forward()
      upwards(pillarHeight-2)
      current = current+1
    end
  else
    local doubles = getDoubles()
    local offset = 0
    if(n == 2 or n == 4) then
      offset = 1
    end
    if(sidesDone < 8) then
      local distance = 1
      if(n >= 3) then
        distance = distance+1
      end
      if(n >= 5) then
        distance = distance+1
      end
          
      if(rightSide == false) then  
        oneEighty()
        forwards(distance +  2 * doubles)
        turtle.turnRight()
        forwards(distance)
        forwards(3 + doubles*3)
        turtle.turnLeft()
      else
        turtle.turnLeft()
        forwards(current - distance - 3 * doubles)
        turtle.turnRight()
        forwards(current - 2 * doubles - distance + 1)
        turtle.turnLeft()
      end
    else
      turtle.turnLeft()
      if(n == 1 or n == 3) then
        turtle.turnLeft()
      end
      turtle.forward()
      if(n == 5) then
        turtle.turnLeft()
        turtle.forward()
        oneEighty()
      elseif(n == 1 or n == 3) then
        oneEighty()
      else
        turtle.turnRight()
      end
      upwards(pillarHeight-2)
      current = current + 1
      sidesDone = 0
      nextSide((n % 5) + 1)
      sidesDone = 0
      rightSide = not rightSide
    end
  end  
  rightSide = not rightSide
end

function getDoubles()
  return math.floor((current-4)/5)  
end

function getCurrentStep()
  return ((current - 4) % 5) + 1
end

function buildSide()
  if(current == 1 ) then
    buildDouble()
    nextSide(-1)
  elseif(current == 2) then
    buildDouble()
    nextSide(-2)
  elseif(current == 3) then 
    buildSingle(0)
    turnLeft()
    turtle.forward()
    turnLeft()
    buildSingle(1)
    nextSide(-3)
  else
    local doubles = getDoubles()
    local stepNumber = getCurrentStep()
    for i = 1, doubles do
      buildDouble()
      turnLeft()
      turtle.forward()
      turnRight()
      turtle.forward()
      turtle.forward()
      turnLeft()
      turtle.forward()
      turnLeft()
    end
    step(stepNumber)
    nextSide(stepNumber)
  end
end 
     
------Main Programm------

if(args[2] ~= nil) then
  start = tonumber(args[1])
  endlvl = tonumber(args[2])
else
  measure()
end

current = start

--if(args[3] ~= nil) then
--  sidesDone = tonumber(args[3])
--end
--
--if(args[4] ~= nil) then
--  debugging = args[4]
--end

print("Building tower from level "..start.." to level "..endlvl)

computeMaterials()

if(not abort) then
  if(current == 0) then
    prepareZero()
    current = 1
  else
    turtle.up()
    turtle.forward()
  end
  turtle.forward()
  downwards(3)
  
  rightSide = (sidesDone % 2 == 1)
  
  while current <= endlvl and not abort do
    buildSide()
    wait()
  end
  print("Done, moving in...")
  turtle.turnRight()
  turtle.forward()
  turtle.turnRight()
  forwards(endlvl - start + 1)
  --turtle.down()
end

print("Program ended")

