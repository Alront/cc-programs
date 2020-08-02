local x, y, rot, time = 0

function pickUp()
  turtle.select(1)
  turtle.suckDown()
end

function unload()
  turtle.select(2)
  turtle.dropDown()
end

function put()
  turtle.select(1)
  turtle.placeDown()
end

function take()
  turtle.select(2)
  turtle.digDown()
end

function updateFile()
  local file = fs.open("progress", "w")
  file.writeLine(x)
  file.writeLine(y)
  file.writeLine(rot)
  file.writeLine(time)
  file.close()
end

function loadProgress()
  local file = fs.open("progress", "r")
  x = tonumber(file.readLine())
  y = tonumber(file.readLine())
  rot = tonumber(file.readLine())
  time = tonumber(file.readLine())
  file.close()
end

function forward(...)
  local dist = 1
  local arg = {...}
  if arg[1] ~= nil then
    dist = arg[1]
  end
  while turtle.getFuelLevel() < dist do
    print("Please insert fuel to slot 16 and press any key")
    os.pullEvent("key")
    local slot = turtle.getSelectedSlot()
    turtle.select(16)
    turtle.refuel()
    turtle.select(slot)
  end
  for i = 1, dist do
    if rot == 0 then
      x = x + 1
    elseif rot == 1 then
      y = y + 1
    elseif rot == 2 then
      x = x - 1
    else
      y = y - 1
    end
    updateFile()
    while not turtle.forward() do turtle.dig() end
  end
end

function left()
  rot = (rot - 1) % 4
  updateFile()
  turtle.turnLeft()
end

function right()
  rot = (rot + 1) % 4
  updateFile()
  turtle.turnRight()
end

function turnTo(r)
  r = r % 4
  while rot ~= r do
    right()
  end
end

---------Main Program------------

loadProgress()
turtle.select(2)
if x ~= 0 then 
  if x > 0 then
    turnTo(2)
    forward(x)
  else
    turnTo(0)
    forward(-x)
  end
end

if y ~= 0 then 
  if y > 0 then
    turnTo(3)
    forward(y)
  else
    turnTo(1)
    forward(-y)
  end
end

turtle.select(1)
if turtle.getItemCount() > 0 then
  turtle.dropDown()
end
turtle.select(2)
if turtle.getItemCount() > 0 then
  turnTo(1)
  forward(2)
  turtle.dropDown()
  turnTo(3)
  forward(2)
end
turnTo(0)

while true do
  for i = time, 1 do
    sleep(1)
    time = time + 1
    updateFile()
  end
  time = 0
  updateFile()
  pickUp()
  if turtle.getItemCount() > 0 then
    
    forward()
    
    for i = 1, 24 do
      take()
      put()
      forward()
    end
    
    right()
    forward()
    right()
    forward()
    
    for i = 1, 24 do
      if (i + 1) % 3 ~= 0 then
        take()
        put()
      end
      forward()
    end
    
    left()
    forward()
    left()
    forward()
    
    for i = 1, 24 do
      take()
      put()
      forward()
    end
    
    left()
    left()
    
    forward(25)
    
    unload()
    
    right()
    forward(2)
    right()
  else
    print("No more stone to make...")
    sleep(20)
  end
end
