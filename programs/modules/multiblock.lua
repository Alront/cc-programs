os.loadAPI("/p/modules/module.lua")

module.load("bta")
module.load("item")
module.load("file")

bottler = "bottler"
fluidPlacer = "fluidPlacer"
cobble = "cobble"

--[[
    places a fluid below the turtle's current position
    CAREFUL: the space for the fluid and the space in front of the turtel need to be free (marked by X/F):

    T X
    F X X

    The fluid must be stored in fluidSlot in a container the the bottler can empty. The empty container will be dropped back into the 
    if advance is true, the  the turtle will move on to the position in front of it, otherwise it will return to the place it originally was
]]
function placeFluid(fluidSlot, bottlerSlot, placerSlot, emptySlot, cobbleSlot, advance)
    print("Placing fluid...")
    -- place bottler
    bta.inv.select(bottlerSlot)
    if bta.inv.isEmpty() then
        requestToCurrentSlot(bottler)
    end
    bta.place()
    bta.down()
    
    -- place block to place against
    bta.forward()
    bta.inv.select(cobbleSlot)
    if bta.inv.isEmpty() then
        requestToCurrentSlot(cobble)
    end
    bta.place()
    bta.back()

    --place fluid placer
    bta.inv.select(placerSlot)
    if bta.inv.isEmpty() then
        requestToCurrentSlot(fluidPlacer)
    end
    bta.place()

    -- put in fluid
    bta.up()
    bta.inv.select(fluidSlot)
    bta.drop()
    sleep(5)

    -- remove stuff
    bta.inv.select(emptySlot)
    bta.suck()

    bta.inv.select(bottlerSlot)
    bta.dig()

    bta.forward()
    bta.inv.select(placerSlot)
    bta.dig("down")

    bta.forward()
    bta.inv.select(cobbleSlot)
    bta.dig("down")

    if not advance then
        bta.back(2)
    end
end

function requestToCurrentSlot(itemName, quantity)
    quantity = quantity or 1
    sleep(2)
    print("Requesting "..quantity.." "..tostring(itemName))
    while not item.request(itemName, quantity, nil, false) do end
end

function returnItem(slot)
    slot = slot or bta.inv.current()
    bta.inv.placeChest()
    bta.inv.select(slot)
    bta.drop("up")
    bta.inv.removeChest()
    item.storeAll()
end

function doFluids(fluids)
    for i, record in ipairs(fluids) do
        bta.moveTo(record.position)
        bta.inv.select(1)

        if bta.inv.isEmpty() then
            -- look ahead to see if we can request more
            local count = 1
            local j = i + 1
            while fluids[j] ~= nil and fluids[j].item == record.item do
                count = count + 1
                j = j + 1
            end
            requestToCurrentSlot(record.item, count)
        end

        print("Placing fluid "..record.item.." at "..bta.posString(record.position))
        placeFluid(1, 2, 3, 4, 5, true)
        returnItem(4)
    end
end

function doBlocks(blocks)
    for i, record in ipairs(blocks) do
        bta.moveTo(record.position)
        bta.inv.select(1)

        if bta.inv.isEmpty() then
            -- look ahead to see if we can request more
            local count = 1
            local j = i + 1
            while blocks[j] ~= nil and blocks[j].item == record.item do
                count = count + 1
                j = j + 1
            end
            requestToCurrentSlot(record.item, count)
        end

        print("Building "..record.item.." at "..bta.posString(record.position))
        bta.placeDown()
    end
end

--[[
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
    layout = {}
    layers = {}
    layout.layers = layers

    function add(pos, item)
        if layers[pos.z + 1] == nil then
            layers[pos.z + 1] = {}
        end
        if layers[pos.z + 1].blocks == nil then
            layers[pos.z + 1].blocks = {}
        end
        table.insert(layers[pos.z + 1].blocks, { position = pos, item = item })
    end

    function addFluid(pos, item)
        if layers[pos.z + 1] == nil then
            layers[pos.z + 1] = {}
        end
        if layers[pos.z + 1].fluids == nil then
            layers[pos.z + 1].fluids = {}
        end
        table.insert(layers[pos.z + 1].fluids, { position = pos, item = item })
    end

    return {

        finalize = function()
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
            for x = from.x, to.x do
                for y = from.y, to.y do
                    for z = from.z, to.z do
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