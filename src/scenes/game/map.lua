map = {}

maps_total = 1

for m = 1, maps_total do
    local load_map = require("src/scenes/game/maps/map_"..m)

    map[m] = {
        grid = {},
        obj = {}
    }

    local count = 1

    for i = 1, load_map.height do
        map[m].grid[i] = {}
    end

    for i = 1, #load_map.layers[1].data do
        if i == load_map.width*count + 1 then
            count = count + 1
        end
        map[m].grid[count][i - (load_map.width*(count-1))] = load_map.layers[1].data[i]
    end

    count = 1

    for i = 1, load_map.height do
        map[m].obj[i] = {}
    end

    for i = 1, #load_map.layers[2].data do
        if i == load_map.width*count + 1 then
            count = count + 1
        end
        map[m].obj[count][i - (load_map.width*(count-1))] = load_map.layers[2].data[i]
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

worldW, worldH = (#map[earlyMap].grid[1] * tileSize)*8, (#map[earlyMap].grid * tileSize)*8

function get_x(x) return (worldW/2)-(#map[earlyMap].grid[1]*tileSize/2)+(tileSize*x) - (tileSize/2) end
function get_y(y) return (worldH/2)-(#map[earlyMap].grid*tileSize/2)+(tileSize*y) - (tileSize/2) end

function get_coord_x(pixel_x)
    local mapCols = #map[earlyMap].grid[1]
    
    local base_offset = (worldW / 2) - (mapCols * tileSize / 2) - (tileSize)
    
    local grid_x = (pixel_x - base_offset) / tileSize
    
    return math.floor(grid_x)
end

function get_coord_y(pixel_y)
    local mapCols = #map[earlyMap].grid
    
    local base_offset = (worldW / 2) - (mapCols * tileSize / 2) - (tileSize)
    
    local grid_y = (pixel_y - base_offset) / tileSize
    
    return math.floor(grid_y)
end

-- Models textures:
montain = Model(g.newImage("assets/models/montain.png"), 16, 16)
montain_water = Model(g.newImage("assets/models/montain_water.png"), 16, 16)
tree = g.newImage("assets/models/tree.png")
tree2 = g.newImage("assets/models/tree2.png")
wall = Model(g.newImage("assets/models/brickWall.png"), 16, 16)
grass = Model(g.newImage("assets/models/grass.png"), 16, 16, {speed = 5})
rock = g.newImage("assets/models/rock.png")
water_rock = g.newImage("assets/models/water_rock.png")
fall = Model(g.newImage("assets/models/fall.png"), 16, 16, {speed = 5})

flower1 = Model(g.newImage("assets/models/flower1.png"), 16, 16)
flower2 = Model(g.newImage("assets/models/flower2.png"), 16, 16)

function map_create_objects()
    for x = 1, #map[earlyMap].obj[1] do
        for y = 1, #map[earlyMap].obj do
            if map[earlyMap].obj[y][x] == 2 then
                table.insert(objects, {type = "model", x = get_x(x), y = get_y(y), z = 0, rad = 0, src = montain, collision = true})
            elseif map[earlyMap].obj[y][x] == 3 then
                table.insert(objects, {type = "model", x = get_x(x), y = get_y(y), z = 0, rad = 0, src = wall, collision = true})
            elseif map[earlyMap].obj[y][x] == 4 then
                table.insert(objects, {type = "grass", x = get_x(x), y = get_y(y), z = 0, rad = 0, src = grass, collision = false})
            elseif map[earlyMap].obj[y][x] == 5 then
                table.insert(objects, {type = "tree", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = Model(tree2, 64, 64, {speed = 20}), collision = true})
            elseif map[earlyMap].obj[y][x] == 6 then
                table.insert(objects, {type = "tree", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = Model(tree, 64, 64, {speed = 20}), collision = true})
            elseif map[earlyMap].obj[y][x] == 7 then
                table.insert(objects, {type = "rock", x = get_x(x), y = get_y(y), z = 0, rad = 0, src = Model(rock, 16, 16), collision = true})
            elseif map[earlyMap].obj[y][x] == 8 then
                table.insert(objects, {type = "water_rock", x = get_x(x), y = get_y(y), z = 0, rad = 0, src = Model(water_rock, 16, 16), collision = true})
            elseif map[earlyMap].obj[y][x] == 20 then
                table.insert(objects, {type = "montain_water", x = get_x(x), y = get_y(y), z = 35, rad = 0, src = montain_water, collision = false})
            elseif map[earlyMap].obj[y][x] == 21 then
                table.insert(objects, {type = "fall", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = fall, collision = true})
            elseif map[earlyMap].obj[y][x] == 22 then
                table.insert(objects, {type = "flower", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = flower1,
                light = light_system.addLight(get_x(x), get_y(y), 64, {get_rgb(204, 126, 157)}, 0.5), collision = false})
            elseif map[earlyMap].obj[y][x] == 23 then
                table.insert(objects, {type = "flower", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = flower2,
                light = light_system.addLight(get_x(x), get_y(y), 64, {get_rgb(127, 255, 255)}, 0.5), collision = false})
            end
        end
    end

    for i = 1, #objects do
        if objects[i].collision == true then
            objects[i].body = love.physics.newBody(world, objects[i].x, objects[i].y, "static")
            objects[i].shape = love.physics.newRectangleShape(16,16)
            objects[i].fixture = love.physics.newFixture(objects[i].body, objects[i].shape)
        end
    end
end

function map_update(dt)
    danim:update("water", 10, dt)
    danim:update("swim", 5, dt)
    fall:animate(1)
    grass:animate(1)
end

local swim_image = g.newImage("assets/swiming.png")
danim:new("swim", swim_image, 4, 1)

function is_water(x, y)
    if map[earlyMap].grid[y][x] >= 10 and map[earlyMap].grid[y][x] <= 18 or map[earlyMap].grid[y][x] == 8 then
        return true
    else
        return false
    end
end

function map_draw(camera_rad)
    for x = 1, #map[earlyMap].grid[1] do
        for y = 1, #map[earlyMap].grid do
            local tx = get_x(x)
            local ty = get_y(y)
            g.setColor(1,1,1)
            g.draw(tile_image, tile[map[earlyMap].grid[y][x]].quad, tx, ty, 0, 1, 1, tileSize/2, tileSize/2)
        end
    end
end

function change_map(map_id, x, y, tile_id)
    map[map_id].grid[y][x] = tile_id
end

function water_draw()
    for x = 1, #map[earlyMap].grid[1] do
        for y = 1, #map[earlyMap].grid do
            if is_water(x, y) then
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