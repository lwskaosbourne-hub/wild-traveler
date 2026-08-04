local transiting_map = false
local target_x = 0
local target_y = 0
local target_map = 0

block_while_transiting = false

function teleport_update(dt)
    for i = 1, #map[earlyMap].teleport do
        local distance = distanceFrom(map[earlyMap].teleport[i].x, map[earlyMap].teleport[i].y, player[player_id].bodyPhy:getX(), player[player_id].bodyPhy:getY())

        if distance <= 8 then
            local t = map[earlyMap].teleport[i]

            player[player_id].color[4] = distance/8
            if distance <= 4 and transiting_map == false then
                player[player_id].movementsBlocked = true
                fade = 1
                if fade_alpha >= 1 then
                    target_x = get_x(t.properties.target_x)
                    target_y = get_y(t.properties.target_y)
                    target_map = t.properties.target_map
                    --player[player_id].bodyPhy:setPosition(target_x, target_y)
                    player[player_id].teleport_target.x = target_x
                    player[player_id].teleport_target.y = target_y
                    block_while_transiting = true

                    earlyMap = target_map
                    player[player_id].map = target_map
                    cam:setAngle(player[player_id].rad - math.rad(180))
                    objects_destroy()
                    objects_ini()
                
                    transiting_map = true
                else
                    player[player_id]:moveFoward(dt, 10)
                end

                --earlyMap = target_map
                --player[player_id].map = t.properties.target_map
                --cam:setAngle(player[player_id].rad - math.rad(180))

                --objects_destroy()
                --player[player_id].bodyPhy:setPosition(get_x(t.properties.target_x), get_y(t.properties.target_y))
                --objects_ini()

                --transiting_map = false
            end
        end
    end

    if transiting_map == true then
        fade = 0
        block_while_transiting = false
        if fade_alpha <= 0 then
            player[player_id].movementsBlocked = false
            collectgarbage("collect")
            player[player_id].color[4] = 1
            transiting_map = false
        else
            --player[player_id].alpha = 1 - fade_alpha
            player[player_id]:moveFoward(dt, 20)
        end
    end
end