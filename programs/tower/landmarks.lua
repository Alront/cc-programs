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
    while not turtle.forward() do turtle.dig() end
  end
  if turn then oneEighty() end
end

function placeLandmark()
  for i = 1, dist - 1 do
    while not turtle.forward() do
      turtle.dig()
    end
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