local btaDir = "/bta/"
local btaPath = "/bta"


function ensureDirectory(dir)
    if not fs.exists(dir) and fs.isDir(dir) then
        fs.makeDir(dir)
    end
end

ensureDirectory(btaPath)

function exists(name)
    return fs.exists(btaDir..name) and not fs.isDir(btaDir..name)
end

--[[
-- Load a table form a given file with the optional specified line processing function.
-- The function takes as argument a line number and a string and returns a key, value pair for the table.
-- Alternatively, an array can be passed as the "keys" argument. It's elements will then be used as keys and
-- all values will be converted using the optional stringConversion function.
    Example usage: 
        loadFromFile(myFile) returns an array containing all lines of the file
        loadFromFile(myFile, function(i, line) return i-1, tonumnber(line) end) returns an array with all lines as numbers and starting form 0
        loadFromFIle(myile, {"a", "b", "c"}, tonumber) returns a table { a = .., b = .., c = ..} with the value of the elements being the lines of the file as numbers
]]
function loadFromFile(fileName, keys, stringConversion)
    --print("Loading file "..fileName)
    if not exists(fileName) then
        print("Could not find file "..fileName)
        return {}
    end
    local getEntry
    if not keys then
        getEntry = function(i, line) return i, line end
    elseif type(keys) == "function" then
        getEntry = keys
    elseif type(keys) == "table" then
        stringConversion = stringConversion or function(x) return x end
        getEntry = function(i, line)
            return keys[i], stringConversion(line)
        end
    else
        error("Unexpected keys type")
    end
    local content = {}
    local file = fs.open(btaDir..fileName, "r")
    local line = file.readLine()
    local i = 0
    while line ~= nil do
        i = i+1
        --print("Read line "..i)
        local key, value = getEntry(i, line)
        content[key] = value
        line = file.readLine()
    end
    file.close()

    return content
end

local function getSortedLineIndecies(content)
    local indecies = {}
    local i = 0
    local maxLine = 0
    for key, value in pairs(content) do
        if type(key) == "number" then
            i = i + 1
            indecies[i] = key
            if i > maxLine then
                maxLine = i
            end
        end
    end
    table.sort(indecies)
    return indecies, maxLine
end

--[[
    Set the contents of a file with the given name. The content is expected to be a
    table with keys of numbers and values of strings (or others types), corresponding to line numbers to be overwritten
    and the content of those lines. If the "wipe" parameter is not true, lines which are not specified remain if the
    file already exists or are assumed to be "" otherwise.
]]
function setFileContent(name, content, wipe)
    local lines
    if not exists(name) or wipe then
        lines = {}
    else
        lines = loadFromFile(name)
    end

    local indecies, maxLine = getSortedLineIndecies(content)
    maxLine = math.max(maxLine, #lines)
    local file = fs.open(btaDir..name, "w")
    for i = 1, maxLine do
        if content[i] ~= nil then
            file.writeLine(tostring(content[i]))
        else
            if i <= #lines then
                file.writeLine(lines[i])
            else
                file.writeLine("")
            end
        end
    end
    file.close()
end

--[[
    Files are layed out as follows:
    {
    string
    <name of the first key>
    table
    {
    string
    <subtableKey>
    number
    <your number here>
    }
    }
]]
local function appendToContent(toStore, fileContent, i)
    if type(toStore) == "number" then
        i = i+1
        fileContent[i] = "number"
        i = i+1
        fileContent[i] = tostring(toStore)
        return i
    elseif type(toStore) == "string" then
        i = i+1
        fileContent[i] = "string"
        i = i+1
        fileContent[i] = toStore
        return i
    elseif type(toStore) == "table" then
        i = i+1
        fileContent[i] = "table"
        i = i+1
        fileContent[i] = "{"
        for key, value in pairs(toStore) do
            local function typesOk(strings)
                local keyOk = false
                local valueOk = false
                for _, elem in ipairs(strings) do
                    keyOk = keyOk or type(key) == elem
                    valueOk = valueOk or type(value) == elem
                end
                return keyOk and valueOk
            end
            if typesOk({"number", "string", "table"}) then
                i = appendToContent(key)
                i = appendToContent(value)
            end
        end
        i = i+1
        fileContent[i] = "}"
        return i
    else
        return i
    end
end

--[[
    Stores a number, string or table in a specified file. Only strings, numbers and other tables will be stored as elements of tables
]]
function storeValue(value, fileName)
    local fileContent = {}
    appendToContent(value, fileContent, 0)
    setFileContent(fileName, fileContent, true)
end

--[[
    Values are stored as follows:
    type
    value

    Values for tables are stored as follow:
    {
    keyType
    key
    ValueType
    value
    ...
    }

    This function returns the line index at the end of the returned value and the value
]]
local function readValueFromContent(content, i)
    i = i+1
    local t = content[i] -- read the type of the value
    if t == "}" then -- reached the end of a table definition, return nil
        return i, nil
    end
    i = i+1
    local k = content[i] -- read the value
    if t == "number" then
        return i, tonumber(k)
    elseif t == "string" then
        return i, k
    elseif t == "table" then
        local value = {}
        assert(k == "{", "Expected '{' at the beginning of tables")
        local v
        i, k = readValueFromContent(content, i)
        while k ~= nil do
            i, v = readValueFromContent(content, i)
            value[k] = v
            i, k = readValueFromContent(content, i)
        end
        return value
    else
        error("Encountered unknown type in file: "..t)
    end
end

--[[
    Load a value from a given file. If the file does not exist or is empty, the default value will be returned
]]
function loadValue(fileName, default)
    if not exists(fileName) then
        return default
    end
    local content = loadFromFile(fileName)
    if #content == 0 then
        return default
    end
    return readValueFromContent(content, 0)
end

--[[ComputerCraft textutils api offers better functionality than what is implemented here, use it instead]]

loadValue = function(fileName, default)
    if not exists(fileName) then
        return default
    end

    local file = fs.open(btaDir..fileName, "r")
    local value = textutils.unserialize(file.readAll())
    file.close()
    if value == nil then
        return default
    else
        return value
    end
end

storeValue = function (value, filename)
    local file = fs.open(btaDir..filename, "w")
    file.write(textutils.serialize(value))
    file.close()
end
