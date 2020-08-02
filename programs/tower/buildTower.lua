os.loadAPI("/p/tower/tower.lua")
os.loadAPI("/p/tower/util.lua")
args  = {...}

if args[1] == "--help" or not args[1] then
    print("Usages:")
    print("  buildLevels(numberOfLevels) expands tower by numberOfLevels")
    print("  buildLevels(start, end, [pillarheight], [noRefules], [dontAskIfOk]) full arg usage")
    print("Make sure to have a fuel chest in slot 14, stair chest in slot 15 and block chest in slot 16")
    return
end


tower.buildLevels(args[1], args[2], args[3], args[4], args[5])