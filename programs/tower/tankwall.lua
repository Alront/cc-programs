--slot 1-8: tanks
--slot 9-12: stone
--slot 14: stone refillchest
--slot 15: junkchest
--slot 16: junk

function placeTank()
  digUp()
  tower.checkMaterial(1, 8)
  turtle.placeUp()
end

function placeStone()
  digUp()
  tower.checkMaterial(9, 12, 14)
  turtle.placeUp()
end
  
  
function digUp()
  local slot = turtle.getSelectedSlot()
  local dig = turtle.digUp
  local place = turtle.placeUp
  local drop = turtle.dropUp
  turtle.select(16)
  dig()
  turtle.select(15)
  place()
  turtle.select(16)
  drop()
  turtle.select(15)
  dig()
  turtle.select(slot)
end

function dig()
  local slot = turtle.getSelectedSlot()
  local dig = turtle.dig
  local place = turtle.place
  local drop = turtle.drop
  turtle.select(16)
  dig()
  turtle.select(15)
  place()
  turtle.select(16)
  drop()
  turtle.select(15)
  dig()
  turtle.select(slot)
end

function digDown()
  local slot = turtle.getSelectedSlot()
  local dig = turtle.digDown
  local place = turtle.placeDown
  local drop = turtle.dropDown
  turtle.select(16)
  dig()
  turtle.select(15)
  place()
  turtle.select(16)
  drop()
  turtle.select(15)
  dig()
  turtle.select(slot)
end

-------------Main Program--------------

local dist = 39
local height = 6

local wall = 2

for k = 1, height do
  for j = 1, 4 do
    for i = 1, dist - 1 do
      dig()
      turtle.forward()
      wall = (wall + 1) % 4
      if wall >= 2 then
        placeTank()
      else
        placeStone()
      end
    end
    turtle.turnLeft()
  end
  digDown()
  turtle.down()
  wall = (wall - 1) % 4
end
      