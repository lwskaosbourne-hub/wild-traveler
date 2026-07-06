map = {}

maps_total = 1

for m = 1, maps_total do
    local load_map = require("src/scenes/game/maps/map_"..m)

    map[m] = {}

    local count = 1

    for i = 1, load_map.height do
        map[m][i] = {}
    end

    for i = 1, #load_map.layers[1].data do
        if i == load_map.width*count + 1 then
            count = count + 1
        end
        map[m][count][i - (load_map.width*(count-1))] = load_map.layers[1].data[i]
    end
end

tileSize = 16

local water_image = g.newImage("assets/water.png")
danim:new("water", water_image, 16, 1)

tile_image = g.newImage("assets/tiles.png")
local tileCount = 0
tile = {}

for t = 1, (tile_image:getWidth()/tileSize) * (tile_image:getHeight()/tileSize) do
    if t == (tile_image:getWidth()/tileSize)*(tileCount+1) + 1 then tileCount = tileCount + 1 end
    --tile[t] = {x = t-((tile_image:getWidth()/tileSize)*tileCount), y = tileCount}
    tile[t] = {quad = g.newQuad((t-((tile_image:getWidth()/tileSize)*tileCount))*tileSize-tileSize, tileCount*tileSize, tileSize, tileSize, tile_image:getDimensions())}
end

earlyMap = 1

worldW, worldH = (#map[earlyMap][1] * tileSize)*8, (#map[earlyMap] * tileSize)*8

function get_x(x) return (worldW/2)-(#map[earlyMap][1]*tileSize/2)+(tileSize*x) - (tileSize/2) end
function get_y(y) return (worldH/2)-(#map[earlyMap]*tileSize/2)+(tileSize*y) - (tileSize/2) end

function get_coord_x(pixel_x)
    local mapCols = #map[earlyMap][1]
    
    local base_offset = (worldW / 2) - (mapCols * tileSize / 2) - (tileSize)
    
    local grid_x = (pixel_x - base_offset) / tileSize
    
    return math.floor(grid_x)
end

function get_coord_y(pixel_y)
    local mapCols = #map[earlyMap]
    
    local base_offset = (worldW / 2) - (mapCols * tileSize / 2) - (tileSize)
    
    local grid_y = (pixel_y - base_offset) / tileSize
    
    return math.floor(grid_y)
end

function map_create_objects()
    for x = 1, #map[earlyMap][1] do
        for y = 1, #map[earlyMap] do
            if map[earlyMap][y][x] == 2 then
                table.insert(objects, {type = "model", src = Model(montain, x, y, 16, 16, true)})
            elseif map[earlyMap][y][x] == 3 then
                table.insert(objects, {type = "model", src = Model(wall, x, y, 16, 16, true)})
            elseif map[earlyMap][y][x] == 4 then
                table.insert(objects, {type = "model", src = Model(grass, x, y, 16, 16)})
            elseif map[earlyMap][y][x] == 5 then
                table.insert(objects, {type = "model", src = Model(tree2, x, y, 64, 64, true)})
            elseif map[earlyMap][y][x] == 6 then
                table.insert(objects, {type = "model", src = Model(tree, x, y, 64, 64, true)})
            end
        end
    end
end

function map_update(dt)
    danim:update("water", 10, dt)
    danim:update("swim", 5, dt)
end

local swim_image = g.newImage("assets/swiming.png")
danim:new("swim", swim_image, 4, 1)

function map_draw(camera_rad)
    for x = 1, #map[earlyMap][1] do
        for y = 1, #map[earlyMap] do
            local tx = get_x(x)
            local ty = get_y(y)
            g.setColor(1,1,1)
            g.draw(tile_image, tile[map[earlyMap][y][x]].quad, tx, ty, 0, 1, 1, tileSize/2, tileSize/2)
        end
    end
end

function water_draw()
    for x = 1, #map[earlyMap][1] do
        for y = 1, #map[earlyMap] do
            if map[earlyMap][y][x] >= 10 and map[earlyMap][y][x] <= 18 then
                local tx = get_x(x)
                local ty = get_y(y)
                danim:draw("water", tx, ty, 0, 1, 1, {1,1,1})
            end
        end
    end
    for _, p in ipairs(player) do
        if p.is_swiming == true then
            danim:draw("swim", p.x, p.y, 0, 1, 1, {1,1,1})
        end
    end
end