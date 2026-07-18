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

function objects_ini()
    objects[1] = {type = "player", x = 0, y = 0, src = player[player_id], id = player_id}

    new_object(Model(g.newImage("assets/models/cabin.png"), 64, 64), 45, 20, 0, "cabin", 0, true)

    new_object(camp_fire, 50, 20, 0, "camp_fire", 0, true,
        light_system.addLight(get_x(50), get_y(20), 150, {1,0.5,0}, 1))
end

function objects_update(dt)
    camp_fire:animate(1)
    for i = 1, #objects do
        if objects[i].type == "player" then
            objects[i].x = objects[i].src.bodyPhy:getX()
            objects[i].y = objects[i].src.bodyPhy:getY()
        elseif objects[i].type == "cabin" then
            if time.hour >= 18 and time.hour <= 24 or time.hour >= 0 and time.hour <= 5.9 then
                for p = 1, #player do
                    if player[p].x <= objects[i].x + objects[i].src:getWidth()/2 - 4 and
                        player[p].x >= objects[i].x - objects[i].src:getWidth()/2 + 4 and
                        player[p].y <= objects[i].y + objects[i].src:getHeight()/2 - 4 and
                        player[p].y >= objects[i].y - objects[i].src:getHeight()/2 + 4 then
                            player[p].movementsBlocked = true
                            fade = 1
                            if fade_alpha >= 1 then
                                fade = 0
                                player[p].energy = player[p].energy_max
                                player[p].hp = player[p].hp_max
                                player[p].movementsBlocked = false
                                time.hour = 6
                            end
                    end
                end
            end
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

return objects