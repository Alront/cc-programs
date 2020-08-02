local filelist = fs.list("/p/tower/api/api.lua")

if filelist == nil then
  print("No API found")
  return
end

for i = 1, #filelist do
  if filelist[i] ~= "loadAPIs" then
    os.loadAPI("/p/tower/api/"..filelist[i])
    print("Loaded "..filelist[i].." API")
  end
end

print("Loaded "..(#filelist - 1).." APIs")