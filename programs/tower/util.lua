
function landmarks(...)
  local args = {...}
  
  local dist = 0
  if(args[1] ~= nil) then
  local arg = tonumber(args[1])
    dist = arg
  end
  
  function oneEighty()
    turtle.turnLeft()
    turtle.turnLeft()
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
  
  function placeLandmark()
    for i = 1, dist - 1 do
      turtle.dig()
      turtle.forward()
    end
    turtle.select(2)
    turtle.place()
    forwards(-1)
    turtle.select(1)
    turtle.place()
    oneEighty()
    forwards(dist - 2)
  end
  
  --------Main Program---------
    
  placeLandmark()
  turtle.turnRight()
  placeLandmark()
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function chestRefill(chestSlot, ...)

  arg = {...}
  local from, to = 0
  
  function detectSpace()
    if not turtle.detect() then return "front" end
    if not turtle.detectUp() then return "up" end
    if not turtle.detectDown() then return "down" end
    return "none"
  end
  
  function placeCommand(a)
    if a == "front" then return turtle.place end
    if a == "up" then return turtle.placeUp end
    if a == "down" then return turtle.placeDown end
    return turtle.place
  end
  
  function suckCommand(a)
    if a == "front" then return turtle.suck end
    if a == "up" then return turtle.suckUp end
    if a == "down" then return turtle.suckDown end
    return turtle.suck
  end
  
  function digCommand(a)
    if a == "front" then return turtle.dig end
    if a == "up" then return turtle.digUp end
    if a == "down" then return turtle.digDown end
    return turtle.dig
  end
  
  function dropCommand(a)
    if a == "front" then return turtle.drop end
    if a == "up" then return turtle.dropUp end
    if a == "down" then return turtle.dropDown end
    return turtle.drop
  end
  
  function getFreeSlot()
    for i = 1, 16 do
      if turtle.getItemCount(i) == 0 and (i < from or i > to) then
        return i
      end
    end
    return -1
  end
  
  ----------Main program-----------
  
  local refuel = false
  if arg[1] == "refuel" then
    refuel = true
    from = chestSlot
    to = chestSlot
  else
    from = tonumber(arg[1])
    to = tonumber(arg[2])
  end
  
  local originalSlot = turtle.getSelectedSlot()
  local block = detectSpace()
  local freeSlot = -1
  
  if block == "none" then 
    print("Could not find space to place chest, breaking things...")
    freeSlot = getFreeSlot() 
    if freeSlot < 0 then
      print("Could not find space to put broken things, loosing things...")
    end
    block = "front"
    turtle.select(math.max(freeSlot, 0))
    turtle.dig()
  end
  
  turtle.select(chestSlot)
  
  placeCommand(block)()
  
  for i = from, to do
    turtle.select(i)
    suckCommand(block)()
  end
  
  if refuel then
    turtle.select(chestSlot)
    turtle.refuel()
  end
  
  turtle.select(chestSlot)
  
  digCommand(block)()
  
  if freeSlot >= 0 then
    turtle.select(freeSlot)
    turtle.place()
  end
  
  turtle.select(originalSlot)
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

function hasItems(start, endslt)
  for i = start, endslt do
    if turtle.getItemCount(i) > 0 then
      return true
    end
  end
  return false
end

-----------------------------------------------------------------------------------------------------------------------------------------------------
  