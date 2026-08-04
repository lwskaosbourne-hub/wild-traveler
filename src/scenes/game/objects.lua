

camp_fire = Model(g.newImage("assets/models/camp_fire.png"), 16, 16, {speed = 5})

function new_object(src, x, y, z, t, rad, collision, light)
    local id = #objects + 1
    objects[id] = {}
    objects[id].id = id
    objects[id].type = t
    objects[id].x = get_x(x)
    objects[id].y = get_y(y)
    objects[id].z = z
    objects[id].rad = rad or 0
    objects[id].src = src
    objects[id].light = light or nil

    if collision == true then
        objects_collision[id] = {}
        if t == "cabin" then
            objects_collision[id].body = love.physics.newBody(world, objects[id].x, objects[id].y, "static")
            objects_collision[id].shape = love.physics.newChainShape(true,
                objects[id].src:getWidth()/2 - 10, -8,
                objects[id].src:getWidth()/2, -8,
                objects[id].src:getWidth()/2, -objects[id].src:getHeight()/2,
                -objects[id].src:getWidth()/2, -objects[id].src:getHeight()/2,
                -objects[id].src:getWidth()/2, objects[id].src:getHeight()/2,
                objects[id].src:getWidth()/2, objects[id].src:getHeight()/2,
                objects[id].src:getWidth()/2, 8,
                (objects[id].src:getWidth()/2) - 10, 8
            )
            objects_collision[id].fixture = love.physics.newFixture(objects_collision[id].body, objects_collision[id].shape)
        else
            objects_collision[id].body = love.physics.newBody(world, objects[id].x, objects[id].y, "static")
            objects_collision[id].shape = love.physics.newRectangleShape(objects[id].src:getDimensions())
            objects_collision[id].fixture = love.physics.newFixture(objects_collision[id].body, objects_collision[id].shape)
        end
    end
end

function new_drop(iten_id, x, y, z)
    local id = #objects + 1
    objects[id] = {}
    objects[id].type = "droped_iten"
    objects[id].x = x
    objects[id].y = y
    objects[id].z = z
    objects[id].src = DropedItens(iten_id, x, y, z)
end

function objects_ini()
    if world:isDestroyed() == true then
        world = phy.newWorld(0, 0, true)

        for i = 1, #player do
            player[i]:addBody(player[i].teleport_target.x, player[i].teleport_target.y)
        end
    end
    objects = {}
    objects_collision = {}
    objects[1] = {type = "player", x = 0, y = 0, src = player[player_id], id = player_id}

    for i = 1, #player do
        if player[i].light == nil then
            if player[i].light_switch == true then
                player[i].light = light_system.addLight(player[i].bodyPhy:getX(), player[i].bodyPhy:getY(), 100, {1,0.5,0}, 1)
            else
                player[i].light = light_system.addLight(player[i].bodyPhy:getX(), player[i].bodyPhy:getY(), 100, {1,0.5,0}, 0)
            end
        end
    end

    map_create_objects()

    --visible_objects = {}

    

    --new_object(Model(g.newImage("assets/models/cabin.png"), 64, 64), 45, 20, 0, "cabin", 0, true)

    --new_object(camp_fire, 50, 20, 0, "camp_fire", 0, true,
    --    light_system.addLight(get_x(50), get_y(20), 130, {1,0.5,0}, 1))

    --new_drop(4, get_x(48), get_y(18), 0)
end

function objects_destroy()
    --for i = 1, #objects do
    --    if objects[i].collision == true and objects_collision[i] ~= nil and objects_collision[i] then
    --        objects_collision[i].fixture:destroy()
    --    end
    --end
    light_system.lights = {}
    for i = 1, #player do
        player[i].light = nil
    end

    world:destroy()
end

local camp_fire_light_direction = 0
local camp_fire_light = 130

function objects_update(dt)
    camp_fire:animate(1)
    if camp_fire.anim_position == 0 then
        camp_fire_light = 160
    elseif camp_fire.anim_position == 1 then
        camp_fire_light = 155
    elseif camp_fire.anim_position == 2 then
        camp_fire_light = 150
    elseif camp_fire.anim_position == 3 then
        camp_fire_light = 155
    end

    for i = 1, #objects do
        if objects[i].type == "player" then
            objects[i].x = objects[i].src.bodyPhy:getX()
            objects[i].y = objects[i].src.bodyPhy:getY()
        elseif objects[i].type == "cave_exit" then
            objects[i].light.color = {ambient_color[1], ambient_color[2], ambient_color[3]}
            objects[i].light.intensity = ambient_color[4]
            objects[i].src.color = ambient_color
        elseif objects[i].type == "droped_iten" then
            if objects[i].src.player_get_iten == true then
                player[objects[i].src.player_id_following]:addIten(objects[i].src.iten_id)
                table.remove(objects, i)
                return
            else
                objects[i].x = objects[i].src.x
                objects[i].y = objects[i].src.y
            end
        elseif objects[i].type == "cabin" then
            for p = 1, #player do
                if time.hour >= 18 and time.hour <= 24 or time.hour >= 0 and time.hour <= 5.9 or player[p].enter_into_cabin == true then
                    if player[p].x <= objects[i].x + objects[i].src:getWidth()/2 and
                        player[p].x >= objects[i].x - objects[i].src:getWidth()/2 and
                        player[p].y <= objects[i].y + objects[i].src:getHeight()/2 and
                        player[p].y >= objects[i].y - objects[i].src:getHeight()/2 then
                            if player[p].enter_into_cabin == false then
                                player[p].movementsBlocked = true
                                if player[p].color[4] <= 0 then
                                    fade = 1
                                    player[p].enter_into_cabin = true
                                else
                                    player[p]:moveFoward(dt, 10)
                                    player[p].color[4] = player[p].color[4] - (5*dt)
                                end
                            else
                                if fade_alpha >= 1 then
                                    fade = 0
                                    player[p].rad = player[p].rad - math.rad(180)
                                    player[p].energy = player[p].energy_max
                                    player[p].hp = player[p].hp_max
                                    player[p].movementsBlocked = false
                                    time.hour = 6
                                elseif fade_alpha <= 0 then
                                    if player[p].color[4] >= 1 then
                                        player[p].enter_into_cabin = false
                                    else
                                        player[p]:moveFoward(dt, 10)
                                        player[p].color[4] = player[p].color[4] + (5*dt)
                                    end
                                end
                            end
                    end
                end
            end
        elseif objects[i].type == "camp_fire" then
            objects[i].light.radius = camp_fire_light
        end
    end
end

function objects_interact(key)
    -- Confere se algum jogador está interagindo com algum objeto no cenário
    for i = 1, #player do
        if player[i].state == 2 then
            local p_x, p_y = get_coord_x(player[i].interactive_point.x), get_coord_y(player[i].interactive_point.y)

            for o = 1, #objects do
                if objects[o].type == "tree" and items[player[i].item_equiped].class == "exe" and key == 1 then
                    if player[i].interactive_point.x >= objects[o].x - 8 and 
                    player[i].interactive_point.x <= objects[o].x + 8 and
                    player[i].interactive_point.y >= objects[o].y - 8 and 
                    player[i].interactive_point.y <= objects[o].y + 8 then
                        if objects[o].hp <= 0 then
                            local wood_amount = math.random(8, 15)
                            local apple_amount = math.random(0,5)
                            for w = 1, wood_amount do
                                local x = (objects[o].x - 16) + math.random(0, 32)
                                local y = (objects[o].y - 16) + math.random(0, 32)
                                new_drop(6, x, y, 32)
                            end
                            if apple_amount > 0 then
                                for a = 1, apple_amount do
                                    local x = (objects[o].x - 16) + math.random(0, 32)
                                    local y = (objects[o].y - 16) + math.random(0, 32)
                                    new_drop(5, x, y, 32)
                                end
                            end
                            remove_object_from_map(get_coord_x(objects[o].x), get_coord_y(objects[o].y))
                            objects_collision[o].fixture:destroy()
                            table.remove(objects_collision, o)
                            objects[o].src:animate(1)
                            objects[o].collision = false
                            table.remove(objects, o)
                        else
                            if danim:getFrame("player_attack") == 0 then
                                objects[o].src:animate(1)
                                player[i].energy = player[i].energy - 1
                                objects[o].hp = objects[o].hp - 1
                            end
                        end
                        break
                    end
                elseif objects[o].type == "rock" and items[player[i].item_equiped].class == "pickaxe" and key == 1 then
                    if player[i].interactive_point.x >= objects[o].x - 8 and 
                    player[i].interactive_point.x <= objects[o].x + 8 and
                    player[i].interactive_point.y >= objects[o].y - 8 and 
                    player[i].interactive_point.y <= objects[o].y + 8 then
                        if objects[o].hp <= 0 then
                            local rock_amount = math.random(3, 10)
                            for r = 1, rock_amount do
                                local x = (objects[o].x - 16) + math.random(0, 32)
                                local y = (objects[o].y - 16) + math.random(0, 32)
                                new_drop(7, x, y, 16)
                            end
                            remove_object_from_map(get_coord_x(objects[o].x), get_coord_y(objects[o].y))
                            objects_collision[o].fixture:destroy()
                            table.remove(objects_collision, o)
                            objects[o].src:animate(1)
                            objects[o].collision = false
                            table.remove(objects, o)
                        else
                            if danim:getFrame("player_attack") == 0 then
                                objects[o].src:animate(1)
                                player[i].energy = player[i].energy - 1
                                objects[o].hp = objects[o].hp - 1
                            end
                        end
                        break
                    end
                elseif objects[o].type == "chair" and key == 2 then
                    if player[i].interactive_point.x >= objects[o].x - 8 and 
                    player[i].interactive_point.x <= objects[o].x + 8 and
                    player[i].interactive_point.y >= objects[o].y - 8 and 
                    player[i].interactive_point.y <= objects[o].y + 8 then
                        player[i]:destroy_fixture()
                        --player[i].movementsBlocked = true
                        player[i].siting_on_a_chair.state = 1
                        player[i].siting_on_a_chair.id = o
                    end
                end
            end
        end
    end
end