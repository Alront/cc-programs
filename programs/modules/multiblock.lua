os.loadAPI("/p/modules/module.lua")

module.load("bta")
module.load("item")
module.load("file")

cobble = "cobble"
dispenser = "dispenser"

stackSize = 64

--[[
    places a fluid below the turtle's current position
    CAREFUL: the space for the fluid and the space in front of the turtel need to be free (marked by X/F):

    T X
    F X X

    The fluid must be stored in fluidSlot in a container the the bottler can empty. The empty container will be dropped back into the 
    if advance is true, the  the turtle will move on to the position in front of it, otherwise it will return to the place it originally was
]]

function placeFluid(fluidSlot, dispenserSlot, cobbleSlot)
    -- place block to place against
    bta.down()
    bta.forward()
    bta.inv.select(cobbleSlot)
    if bta.inv.isEmpty() then
        requestToCurrentSlot(cobble)
    end
    bta.place()

    -- place dispenser
    bta.back()
    bta.inv.select(dispenserSlot)
    if bta.inv.isEmpty() then
        requestToCurrentSlot(dispenser)
    end
    bta.place()

    -- put in fluid
    bta.inv.select(fluidSlot)
    bta.drop(1)

    -- activate dispenser, retreive bucket
    bta.up()
    bta.forward()
    redstone.setOutput("bottom", true)
    sleep(0.25)
    redstone.setOutput("bottom", false)
    bta.suck(1, "down")

    bta.inv.select(dispenserSlot)
    bta.dig("down")

    bta.inv.select(cobbleSlot)
    bta.forward()
    bta.dig("down")
end

function requestToCurrentSlot(itemName, quantity)
    quantity = quantity or 1
    sleep(2)
    print("Requesting "..quantity.." "..tostring(itemName))
    while not item.request(itemName, quantity, nil, true) do end
end

function returnItem(slot)
    slot = slot or bta.inv.current()
    bta.inv.placeChest()

    if type(slot) == "table" then
        for _, j in ipairs(slot) do
            if bta.inv.isEmpty(j) then break end
            bta.inv.select(j)
            bta.drop(nil, "up")
        end
    else
        bta.inv.select(slot)
        bta.drop(nil, "up")
    end

    bta.inv.removeChest()

    item.storeAll()
end

function doFluids(fluids)
    local fluidSlots = { 4, 5, 6, 7, 8, 9, 10, 11 }
    local buckets = 0

    for i, record in ipairs(fluids) do
        bta.moveTo(record.position)

        while buckets == 0 do
            -- empty out old buckets
            returnItem(fluidSlots)

            -- look ahead to see if we can request more
            local count = 1
            local j = i + 1
            while fluids[j] ~= nil and fluids[j].item == record.item and count < #fluidSlots do
                count = count + 1
                j = j + 1
            end

            bta.inv.select(fluidSlots[1])
            requestToCurrentSlot(record.item, count)
            for _, j in ipairs(fluidSlots) do
                if bta.inv.isEmpty(j) then
                    break
                else
                    buckets = buckets + 1
                end
            end
        end

        --print("Placing fluid "..record.item.." at "..bta.posString(record.position))
        placeFluid(fluidSlots[buckets], 2, 3)
        buckets = buckets - 1
    end
    returnItem(fluidSlots)
end

function doBlocks(blocks)
    for i, record in ipairs(blocks) do
        bta.moveTo(record.position)
        bta.inv.select(1)

        while bta.inv.isEmpty() do
            -- look ahead to see if we can request more
            local count = 1
            local j = i + 1
            while blocks[j] ~= nil and blocks[j].item == record.item and count < stackSize do
                count = count + 1
                j = j + 1
            end
            requestToCurrentSlot(record.item, count)
        end

        --print("Building "..record.item.." at "..bta.posString(record.position))
        bta.placeDown()
    end
end

--[[
    Build a multiblock with a given layout.
    IMPORTANT: The items needed will be requested from an item server. This item server needs to provide
    cobblestone and a dispenser.

    Fluids need to be provided in buckets that can be placed by a dispenser.

    layout = {
        layers = {
            [1] = {
                blocks = {
                    [1] = {position = <btaPosition>, item = "..."),
                    [2] = {position = <btaPosition>, item = "..."),
                    ...
                }
                fluids = {
                    [1] = {position = <btaPosition>, item = "..."),
                    [2] = {position = <btaPosition>, item = "..."),
                }

            },
            [2] = {
                blocks = ...,
                fluids = ...,
            },
            ...
        }
    }
]]

function build(layout)
    bta.up()
    bta.resetCoordinates()
    item.dumpInv()
    for layerNum, layer in ipairs(layout.layers) do
        if layer.fluids ~= nil then
            doFluids(layer.fluids)
        end
        if layer.blocks ~= nil then
            doBlocks(layer.blocks)
        end
    end
end

function layoutBuilder()
    local layout = {}
    local layers = {}
    layout.layers = layers

    local maxLayer = 0

    local positions = {}
    local items = {}

    function posKey(pos)
        return pos.x.."_"..pos.y.."_"..pos.z
    end

    local function addThing(pos, item, thingField)
        local entry = { position = pos, item = item }

        local posString = posKey(pos)

        if pos.z + 1 > maxLayer then
            maxLayer = pos.z + 1
        end

        if positions[posString] ~= nil then -- this position was already written to, we will overwrite
            local rec = positions[posString]
            if items[rec.entry.item] then
                items[rec.entry.item] = items[rec.entry.item] - 1
            end
            layers[rec.layer][thingField][rec.index] = entry
            rec.entry = entry
            if items[rec.entry.item] then
                items[rec.entry.item] = items[rec.entry.item] + 1
            else
                items[rec.entry.item] = 1
            end
        else -- new position, add it and record

            -- make sure the relevant tables exist
            if layers[pos.z + 1] == nil then
                layers[pos.z + 1] = {}
            end
            if layers[pos.z + 1][thingField] == nil then
                layers[pos.z + 1][thingField] = {}
            end

            table.insert(layers[pos.z + 1][thingField], entry) -- add the block at the end of the list for this layer
            positions[posString] = {layer = pos.z + 1, index = #(layers[pos.z + 1][thingField]), entry = entry} -- record the block at this position
            if items[item] then
                items[item] = items[item] + 1
            else
                items[item] = 1
            end
        end
    end

    local function add(pos, item) addThing(pos, item, "blocks") end
    local function addFluid(pos, item) addThing(pos, item, "fluids") end

    local function signum(number)
        if number >= 0 then
           return 1
        elseif number < 0 then
           return -1
        end
     end

    return {

        finalize = function()
            -- make sure the list is contiguous so that all layer can be looped through without preemtive loop exit
            for i = 1, maxLayer do
                if layers[i] == nil then
                    layers[i] = {}
                end
            end 

            local resourceReq = "Items required:"
            for item, count in pairs(items) do
                resourceReq = resourceReq.."\n"..item..": "..count
            end
            print(resourceReq)

            file.storeValue(layout, "debug")
            return layout
        end,

        add = add,
        addFluid = addFluid,

        --[[
            item can be either a string or a function that returns an string depending on the x, y, z coords
            the item name "air" can be returned to leave a position blank

            if item is a table containing a string, the it is added as a fluid
        ]]
        addCube = function(from, to, item)
            for z = from.z, to.z, signum(to.z - from.z) do
                for y = from.y, to.y, signum(to.y - from.y) do
                    for x = from.x, to.x, signum(to.x - from.x) do
                        local it
                        if type(item) == "string" or type(item) == "table" then
                            it = item
                        else
                            assert(type(item) == "function")
                            it = item(x, y, z)
                        end
                        if type(it) == "table" then
                            addFluid(bta.makePos(x, y, z, from.d), it[1])
                        elseif it ~= "air" then
                            add(bta.makePos(x, y, z, from.d), it)
                        end
                    end
                end
            end
        end,
    }
end