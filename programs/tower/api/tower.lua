
function buildLevels(...)
  --slot 1 to storagesize: blocks
  --slot storagesize + 1 to 2 * storagesize: stairs
  --build level arg1 to arg2
  --or expand tower by arg1 levels (middle must be free for measurements)
  
  local pausing = false
  local debugging = true
  
  local args = {...}
  
  local start, endlvl = 0
  
  local pillarHeight = 5
  local storageSize = 4
  local fuelChest = 14
  local stairsChest = 15
  local blockChest = 16
  local refueling = false
  local askIfOk = true
  
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
  
  function blockDown()
    checkMaterials(1, storageSize, blockChest)
    turtle.placeDown()
  end
  
  function blockFront()
    checkMaterials(1, storageSize, blockChest)
    turtle.place()
  end
  
  function blockUp()
    checkMaterial(1, storageSize, blockChest)
    turtle.placeUp()
  end
  
  function stairUp()
    checkMaterial(storageSize + 1, 2 * storageSize, stairsChest)
    turtle.placeUp()
  end
  
  function stairDown()
    checkMaterial(storageSize + 1, 2 * storageSize, stairsChest)
    turtle.placeDown()
  end
  
  function stairFront()
    checkMaterial(storageSize + 1, 2 * storageSize, stairsChest)
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
    while refueling and turtle.getFuelLevel() < abstand do
      util.chestRefill(fuelChest, "refuel")
    end
    for k = 1, abstand do
      turtle.forward()
    end
  end
  
  function downwards(height)
    while refueling and turtle.getFuelLevel() < height do
      util.chestRefill(fuelChest, "refuel")
    end
    for i = 1, height do
      turtle.down()
    end
  end
  
  function upwards(height)
    while refueling and turtle.getFuelLevel() < height do
      util.chestRefill(fuelChest, "refuel")
    end
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
    
    while refueling and turtle.getFuelLevel() < 10000 do
      util.chestRefill(fuelChest, "refuel")
    end
  end 
       
  ------Main Programm------
  
  if(args[2] ~= nil) then
    start = tonumber(args[1])
    endlvl = tonumber(args[2])
  else
    start = measure()
    endlvl = start + args[1] - 1
  end
  
  if args[3] ~= nil then
    pillarHeight = tonumber(args[3])
  end
  
  if args[4] ~= nil then
    refueling = true
  end
  
  if args[5] ~= nil then
    askIfOk = false
  end
  
  current = start
  
  if askIfOk then
    materials = computeTowerMaterials(start, endlvl, pillarHeight)
    print(materials.blocks.." blocks and "..materials.stairs.." stairs will be needed. OK? (y/n)")
    local key = os.pullEvent("char") 
    if key ~= 'y' then 
      printDebug("Aborting...")
      abort = true
    end
  end
  
  print("Building tower from level "..start.." to level "..endlvl)
  
  if(not abort) then
    if(current == 0) then
      prepareZero()
      current = 1
    else
      turtle.up()
      turtle.forward()
    end
    if endlvl > 0 then
      turtle.forward()
      downwards(3)
    end
    
    rightSide = (sidesDone % 2 == 1)
    
    while current <= endlvl and not abort do
      buildSide()
      wait()
    end
    
    if endlvl > 0 then
      turtle.turnRight()
      turtle.forward()
      turtle.turnRight()
      forwards(2)
      turtle.turnRight()
      turtle.forward()
      turtle.turnRight()
      while turtle.detect() do
        turtle.up()
      end
      turtle.down()
    end
  end
  
  print((start - endlvl + 1).." levels built")
  
  return endlvl
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function buildPlatform(...)
  local args = {...}
  
  local holeSize = 0
  
  local storageSize = 4
  local blockChest = 16
  local fuelChest = 14
  local refueling = false
  local debugging = true
  local pausing = false
  local askIfOk = true
  
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
  
  function blockDown()
    checkMaterial(1, storageSize, blockChest)
    turtle.placeDown()
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
    computeValues(width)
    debugInfo()
    wait()
  end
  
  function computeValues(width)
    current = (width - 5) / 2 + 1
    quarterWidth = math.ceil(width/2)
    n = getCurrentStep()
    cornerWidth = 5 + n
    restHole = math.max(math.ceil(holeSize / 2) - getDoubles() * 3, 0)
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
  
  if(args[1] ~= nil) then
    local arg = tonumber(args[1])
    holeSize = 2 * math.floor(arg / 2) + 1
  end
  
  if args[2] ~= nil then
    width = 2 * args[2] + 3
    computeValues(width)
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
  else
    measure()
  end  
  
  if args[3] ~= nil then 
    askIfOk = false
  end
  
  if args[4] ~= nil then 
    refueling = true
  end
  
  
  if askIfOk then
    materials = computePlatformMaterials(current, holeSize)
    print(materials.." blocks will be needed. OK? (y/n)")
    local event, key = os.pullEvent("char") 
    if key ~= 'y' then 
      printDebug("Aborting...")
      turtle.turnRight()
      turtle.forward()
      turtle.turnRight()
      return
    end
  end
  
  for i = 1, 4 do
    printDebug("Doing quarter "..i)
    debugInfo()
    wait()
    doQuarter()
    while refueling and turtle.getFuelLevel() < 10000 do
      util.chestRefill(fuelChest, "refuel")
    end
  end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function checkMaterial(startingSlot, endSlot, ...)
  local arg = {...}
  if(turtle.getSelectedSlot() >= endSlot or turtle.getSelectedSlot() < startingSlot) then
    turtle.select(startingSlot)
  end
  while (turtle.getItemCount() < 1) and not (turtle.getSelectedSlot() >= endSlot) do
    turtle.select(turtle.getSelectedSlot() + 1)
  end
  term.clearLine()
  if(turtle.getItemCount() < 1) then
    local refillChest = arg[1]
    if refillChest == nil then
      term.write("Please refill materials...")
      sleep(10)  
      checkMaterial(startingSlot, endSlot)
    else
      util.chestRefill(refillChest, startingSlot, endSlot)
    end
  end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function computeTowerMaterials(start, endlvl, pillarHeight)
  local result = {blocks = 0, stairs = 0}
  local startlvl = math.max(start - 1, 0)
  local h = pillarHeight - 2
  if(start == 0) then
    result.stairs = result.stairs + 12
  end
  
  if(start <= 3) then
    local times = math.min(endlvl, 3) - startlvl
    result.blocks = result.blocks+  16 * h * times
    result.stairs = result.stairs+  times * 32
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
     
    result.blocks = result.blocks+  standartBlocks * nStandarts * 8 + specialBlocks * nSpecials * 8 + doubles * 2 * h * 8
    result.stairs = result.stairs+  standartStairs * nStandarts * 8 + specialStairs * nSpecials * 8 + doubles * 4 * 8
  end
  return result
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function computePlatformMaterials(level, holeSize)
  local doubles = math.floor((level - 4) / 5)
  local halfWidth = level + 2
  local step = ((level - 4) % 5) + 1
  
  local bpq = 0
  for i = 1, doubles do
    bpq = bpq + 2 * ((halfWidth * 3 - i * 2) + 2)
  end
  
  if step == 1 then bpq = bpq + 31
  elseif step == 2 then bpq = bpq + 41
  elseif step == 3 then bpq = bpq + 52
  elseif step == 4 then bpq = bpq + 64
  elseif step == 5 then bpq = bpq + 75 end
  
  bpq = bpq - (doubles * 3) * (doubles * 3)
  
  local blocks = bpq * 4
  blocks = blocks - 4 * halfWidth + 3 - holeSize * holeSize
  return blocks
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function buildFloors(floors, start, ...)
  --args: floors, startLevel[, floorFrequency, pillarHeight, holeSize, changes]
  --changes in the fromat: floor, newPillarHeight, floor, newPillarHeight, ...
--  local fuelChest = 14
--  local stairsChest = 15
--  local blockChest = 16
  
  local askIfOk = true
  
  local arg = {...}
  local floorFrequency = 4
  local pillarHeight = 5
  local holeSize = 3
  local changes = {}
  local change = 1
  
  function nextChange()
    if changes[change] ~= nil then
      pillarHeight = changes[change + 1]
      change = change + 2
    end
  end
  
  if arg[1] ~= nil then
    floorFrequency = arg[1]
  end
  
  if arg[2] ~= nil then
    pillarHeight = arg[2] + 2
  end
  
  if arg[3] ~= nil then
    holeSize = arg[3]
  end
  
  if arg ~= nil and #arg > 3 then
    for i = 4, #arg + 3 do
      changes[i - 3] = arg[i]
    end
  end
  
  --local start = measure()
  local level = start
  print("Start: "..start)
  --os.pullEvent("char")
  
  function computeMaterials()
    materials = computeTowerMaterials(start, start + floorFrequency * floors, pillarHeight)
    for i = 1, floors do
      materials.blocks = materials.blocks + computePlatformMaterials(start + i * floorFrequency, holeSize)
    end
    return materials
  end
  
  if askIfOk then
    materials = computeMaterials()
    print(materials.blocks.." blocks and "..materials.stairs.." stairs will be needed. (Computation does not take into account changes)")
    print("OK? (y/n)")
    local event, key = os.pullEvent("char") 
    if key ~= 'y' then 
      return false
    end
  end
    
  if start == 0 then
    buildLevels(0, 0, 0, true, true)
    level = 1
    turtle.turnRight()
    turtle.turnRight()
    turtle.forward()
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
  end
  
  for i = 1, floors do
    if changes[change] ~= nil and changes[change] == i then
      nextChange()
    end
    buildLevels(level, level + floorFrequency - 1, pillarHeight, true, true)
    level = level + floorFrequency
    if level - 1 >= 4 then
      buildPlatform(holeSize, level - 1, true, true)
    else
      print("Not doing a platform before level 4. Because fuck you is why.")
    end
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
  end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function measure()
  if turtle.detectDown() and not turtle.detect() then
    print("assuming level 0")
    return 0
  end

  print("Measuring level...")
  turtle.turnLeft()
  turtle.turnLeft()
  local width = 1
  while turtle.forward() do
    width = width + 1
  end
  turtle.turnLeft()
  turtle.turnLeft()
  for i = 1, width - 1 do
    turtle.forward()
  end
  return (width - 5) / 2 + 2
end
  