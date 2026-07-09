objects = {}

function objects_ini()
    objects[1] = {type = "player", src = player[player_id], id = player_id}
end

function objects_update()
    -- Confere se algum jogador está interagindo com algum objeto no cenário
    for i = 1, #player do
        if player[i].state == 2 and items[player[i].item_equiped].class == "exe" then
            local p_x, p_y = get_coord_x(player[i].interactive_point.x), get_coord_y(player[i].interactive_point.y)

            for o = 1, #objects do
                if objects[o].type == "tree" then
                    if player[i].interactive_point.x >= objects[o].src.x - 8 and 
                    player[i].interactive_point.x <= objects[o].src.x + 8 and
                    player[i].interactive_point.y >= objects[o].src.y - 8 and 
                    player[i].interactive_point.y <= objects[o].src.y + 8 then
                        if objects[o].hp <= 0 then
                            objects[o].src:destroy()
                            table.remove(objects, o)
                            change_map(player[i].map, p_x, p_y, 1)
                        else
                            if danim:getFrame("player_attack") == 0 then
                                objects[o].src:animate(1)
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