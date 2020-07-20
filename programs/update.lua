if fs.exists("/downloads/cc-programs") then
    fs.delete("/downloads/cc-programs")
end
shell.run("github Alront cc-programs . programs master")
if fs.exists("/p") then
    fs.delete("/p")
end
fs.move("/downloads/cc-programs/programs", "/p")