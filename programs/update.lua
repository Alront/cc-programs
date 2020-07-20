shell.run("github Alront cc-programs . programs master")
if fs.exists("/programs") then
    fs.delete("/programs")
end
fs.move("/downloads/cc-programs/programs", "/prgs")