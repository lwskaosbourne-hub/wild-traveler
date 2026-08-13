map = {}

maps_total = 2

earlyMap = 2
tileSize = 16
worldW, worldH = (100 * tileSize)*8, (100 * tileSize)*8

function get_x(x) return (worldW/2)-(#map[earlyMap].grid[1]*tileSize/2)+(tileSize*x) - (tileSize/2) end
function get_y(y) return (worldH/2)-(#map[earlyMap].grid*tileSize/2)+(tileSize*y) - (tileSize/2) end

for m = 1, maps_total do
    local load_map = require("src/scenes/game/maps/map_"..m)

    map[m] = {
        grid = {},
        obj = {},
        teleport = {},
        width = load_map.width,
        height = load_map.height
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

    if #load_map.layers[3].objects > 0 then
        for i = 1, #load_map.layers[3].objects do
            map[m].teleport[i] = {}
            map[m].teleport[i].x = (worldW/2)-(#map[m].grid[1]*tileSize/2)+load_map.layers[3].objects[i].x + (tileSize/2)
            map[m].teleport[i].y = (worldH/2)-(#map[m].grid*tileSize/2)+load_map.layers[3].objects[i].y + (tileSize/2)
            map[m].teleport[i].properties = {
                target_map = load_map.layers[3].objects[i].properties["teleport"][1],
                target_x = load_map.layers[3].objects[i].properties["teleport"][2] + 1,
                target_y = load_map.layers[3].objects[i].properties["teleport"][3] + 1
            }
        end
    end
end

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
montain_wall = Model(g.newImage("assets/models/montain_wall.png"), 16, 16)
montain_water = Model(g.newImage("assets/models/montain_water.png"), 16, 16)
tree = g.newImage("assets/models/tree.png")
tree2 = g.newImage("assets/models/tree2.png")
wall = Model(g.newImage("assets/models/brickWall.png"), 16, 16)
grass = Model(g.newImage("assets/models/grass.png"), 16, 16, {speed = 0.001})
rock = g.newImage("assets/models/rock.png")
water_rock = g.newImage("assets/models/water_rock.png")
fall = Model(g.newImage("assets/models/fall.png"), 16, 16, {speed = 5})

montain_cave = Model(g.newImage("assets/models/montain_cave.png"), 16, 16)
cave_wall = Model(g.newImage("assets/models/cave_wall.png"), 16, 16)

cave_exit_light = Model(g.newImage("assets/models/cave_exit.png"), 16, 16)
cave_exit_base = Model(g.newImage("assets/models/cave_exit_base.png"), 16, 16)

void = Model(g.newImage("assets/models/void.png"), 16, 16)

flower1 = Model(g.newImage("assets/models/flower1.png"), 16, 16)
flower2 = Model(g.newImage("assets/models/flower2.png"), 16, 16)

chair = Model(g.newImage("assets/models/chair.png"), 16, 16)
trunk = Model(g.newImage("assets/models/trunk.png"), 16, 16)

function map_create_objects()
    for x = 1, #map[earlyMap].obj[1] do
        for y = 1, #map[earlyMap].obj do
            if map[earlyMap].obj[y][x] == 2 then
                new_object(montain_wall, x, y, 0, "model", 0, true)
            elseif map[earlyMap].obj[y][x] == 3 then
                new_object(montain_cave, x, y, 0, "model", 0, false)
            elseif map[earlyMap].obj[y][x] == 4 then
                new_object(grass, x, y, 0, "grass", 0, false)
            elseif map[earlyMap].obj[y][x] == 5 then
                new_object(Model(tree2, 64, 64, {speed = 20}), x, y, 0, "tree", 0, true)
                --table.insert(objects, {type = "tree", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = Model(tree2, 64, 64, {speed = 20}), collision = true})
            elseif map[earlyMap].obj[y][x] == 6 then
                new_object(Model(tree, 64, 64, {speed = 20}), x, y, 0, "tree", 0, true)
                --table.insert(objects, {type = "tree", x = get_x(x), y = get_y(y), z = 0, rad = 0, hp = 5, src = Model(tree, 64, 64, {speed = 20}), collision = true})
            elseif map[earlyMap].obj[y][x] == 7 then
                new_object(Model(rock, 16, 16, {speed = 20}), x, y, 0, "rock", 0, true)
            elseif map[earlyMap].obj[y][x] == 8 then
                new_object(Model(water_rock, 16, 16), x, y, 0, "water_rock", 0, true)
            elseif map[earlyMap].obj[y][x] == 9 then
                new_object(void, x, y, 0, "void", 0, true)
            elseif map[earlyMap].obj[y][x] == 20 then
                new_object(montain_water, x, y, 35, "montain_water", 0, false)
            elseif map[earlyMap].obj[y][x] == 21 then
                new_object(fall, x, y, 0, "fall", 0, true)
            elseif map[earlyMap].obj[y][x] == 22 then
                new_object(flower1, x, y, 0, "flower", 0, false)
            elseif map[earlyMap].obj[y][x] == 23 then
                new_object(flower2, x, y, 0, "flower", 0, false)
            elseif map[earlyMap].obj[y][x] == 24 then
                new_object(camp_fire, x, y, 0, "camp_fire", 0, true,
                light_system.addLight(get_x(x), get_y(y), 130, {1,0.5,0}, 1))
            elseif map[earlyMap].obj[y][x] == 25 then
                new_object(chair, x, y, 0, "chair", 0, true)
            elseif map[earlyMap].obj[y][x] == 28 then
                new_object(cave_wall, x, y, 0, "cave_wall", 0, true)
            elseif map[earlyMap].obj[y][x] == 30 then
                new_object(cave_exit_light, x, y, 0, "cave_exit", 0, false,
                light_system.addLight(get_x(x), get_y(y), 120, {1, 1, 1}, 1))
            elseif map[earlyMap].obj[y][x] == 31 then
                new_object(trunk, x, y, 0, "chair", 0, true)
            elseif map[earlyMap].obj[y][x] == 32 then
                new_object(montain, x, y, 35, "montain", 0, false)
            end
        end
    end
end

function map_update(dt)
    danim:update("water", 10, dt)
    danim:update("swim", 5, dt)
    fall:animate(1)
    grass:animate(1)
    cave_exit_base:update(dt)
end

function remove_object_from_map(ox, oy)
    for x = 1, #map[earlyMap].obj[1] do
        for y = 1, #map[earlyMap].obj do
            if x == ox and y == oy then
                map[earlyMap].obj[y][x] = 0
            end
        end
    end
end

local swim_image = g.newImage("assets/swiming.png")
danim:new("swim", swim_image, 4, 1)

function is_water(x, y)
    if map[earlyMap].grid[y][x] >= 10 and map[earlyMap].grid[y][x] <= 18 then
        return true
    elseif map[earlyMap].grid[y][x] == 8 then
        return true
    elseif map[earlyMap].grid[y][x] >= 26 and map[earlyMap].grid[y][x] <= 27 then
        return true
    elseif map[earlyMap].grid[y][x] >= 35 and map[earlyMap].grid[y][x] <= 36 then
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
            if map[earlyMap].grid[y][x] > 0 then
                g.draw(tile_image, tile[map[earlyMap].grid[y][x]].quad, tx, ty, 0, 1, 1, tileSize/2, tileSize/2)
            end
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