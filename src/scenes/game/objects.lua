objects = {}

camp_fire = Model(g.newImage("assets/models/camp_fire.png"), 16, 16, {speed = 5})

function new_object(src, x, y, z, t, rad, collision, light)
    local id = #objects + 1
    objects[id] = {}
    objects[id].type = t
    objects[id].x = get_x(x)
    objects[id].y = get_y(y)
    objects[id].z = z
    objects[id].rad = rad or 0
    objects[id].src = src
    objects[id].light = light or nil

    if collision == true then
        if t == "cabin" then
            objects[id].body = love.physics.newBody(world, objects[id].x, objects[id].y, "static")
            objects[id].shape = love.physics.newChainShape(true,
                objects[id].src:getWidth()/2 - 10, -8,
                objects[id].src:getWidth()/2, -8,
                objects[id].src:getWidth()/2, -objects[id].src:getHeight()/2,
                -objects[id].src:getWidth()/2, -objects[id].src:getHeight()/2,
                -objects[id].src:getWidth()/2, objects[id].src:getHeight()/2,
                objects[id].src:getWidth()/2, objects[id].src:getHeight()/2,
                objects[id].src:getWidth()/2, 8,
                (objects[id].src:getWidth()/2) - 10, 8
            )
            objects[id].fixture = love.physics.newFixture(objects[id].body, objects[id].shape)
        else
            objects[id].body = love.physics.newBody(world, objects[id].x, objects[id].y, "static")
            objects[id].shape = love.physics.newRectangleShape(objects[id].src:getDimensions())
            objects[id].fixture = love.physics.newFixture(objects[id].body, objects[id].shape)
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
    objects[1] = {type = "player", x = 0, y = 0, src = player[player_id], id = player_id}

    new_object(Model(g.newImage("assets/models/cabin.png"), 64, 64), 45, 20, 0, "cabin", 0, true)

    new_object(camp_fire, 50, 20, 0, "camp_fire", 0, true,
        light_system.addLight(get_x(50), get_y(20), 130, {1,0.5,0}, 1))

    new_drop(4, get_x(48), get_y(18), 0)
end

local camp_fire_light_direction = 0
local camp_fire_light = 130

function objects_update(dt)
    camp_fire:animate(1)
    if camp_fire.anim_position == 0 then
        camp_fire_light = 140
    elseif camp_fire.anim_position == 1 then
        camp_fire_light = 135
    elseif camp_fire.anim_position == 2 then
        camp_fire_light = 130
    elseif camp_fire.anim_position == 3 then
        camp_fire_light = 135
    end

    for i = 1, #objects do
        if objects[i].type == "player" then
            objects[i].x = objects[i].src.bodyPhy:getX()
            objects[i].y = objects[i].src.bodyPhy:getY()
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
                                if player[p].alpha <= 0 then
                                    fade = 1
                                    player[p].enter_into_cabin = true
                                else
                                    player[p]:moveFoward(dt, 10)
                                    player[p].alpha = player[p].alpha - (5*dt)
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
                                    if player[p].alpha >= 1 then
                                        player[p].enter_into_cabin = false
                                    else
                                        player[p]:moveFoward(dt, 10)
                                        player[p].alpha = player[p].alpha + (5*dt)
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

function objects_interact()
    -- Confere se algum jogador está interagindo com algum objeto no cenário
    for i = 1, #player do
        if player[i].state == 2 and items[player[i].item_equiped].class == "exe" then
            local p_x, p_y = get_coord_x(player[i].interactive_point.x), get_coord_y(player[i].interactive_point.y)

            for o = 1, #objects do
                if objects[o].type == "tree" then
                    if player[i].interactive_point.x >= objects[o].x - 8 and 
                    player[i].interactive_point.x <= objects[o].x + 8 and
                    player[i].interactive_point.y >= objects[o].y - 8 and 
                    player[i].interactive_point.y <= objects[o].y + 8 then
                        if objects[o].hp <= 0 then
                            local wood_amount = math.random(3, 10)
                            local apple_amount = math.random(0,5)
                            for w = 1, wood_amount do
                                local x = (objects[o].x - 16) + math.random(0, 32)
                                local y = (objects[o].y - 16) + math.random(0, 32)
                                new_drop(5, x, y, 32)
                            end
                            if apple_amount > 0 then
                                for a = 1, apple_amount do
                                    local x = (objects[o].x - 16) + math.random(0, 32)
                                    local y = (objects[o].y - 16) + math.random(0, 32)
                                    new_drop(4, x, y, 32)
                                end
                            end
                            objects[o].fixture:destroy()
                            objects[o].src:animate(1)
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
                end
            end
        end
    end
end