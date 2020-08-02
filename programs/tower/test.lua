
local start = 0
local endlvl = 14
local pillarHeight = 5



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
  local event, key = os.pullEvent("char") -- limit os.pullEvent to the 'key' event
  if key ~= keys.y then -- if the key pressed was 'e'
    --abort = true
  end
end

computeMaterials()