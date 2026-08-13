function renderLoad()
    view_radius = 120 / camera_distance
end

visible_objects = {}
visible_n = 0

local tree_shadow = g.newImage("assets/tree_shadow.png")
local grass_shadow = g.newImage("assets/grass_shadow.png")
local grass_shadow_quad = g.newQuad(0, 0, grass_shadow:getWidth()/2, grass_shadow:getHeight(), grass_shadow:getDimensions())

function renderUpdate(cam, objects)
    --if grass.anim_position == 1 then
    --    grass_shadow_quad:setViewport(grass_shadow:getWidth()/2, 0, grass_shadow:getWidth()/2, grass_shadow:getHeight(), grass_shadow:getDimensions())
    --elseif grass.anim_position == 3 then
    --    grass_shadow_quad:setViewport(0, 0, grass_shadow:getWidth()/2, grass_shadow:getHeight(), grass_shadow:getDimensions())
    --end

    local visible_count = 0
    local cam_x, cam_y = cam:getPosition() 
    
    for i = 1, #objects do
        local obj = objects[i]
        
        local dx = obj.x - cam_x
        local dy = obj.y - cam_y
        local distance_sq = (dx * dx) + (dy * dy) 
        
        local obj_margin = 64 
        local cull_distance = view_radius + obj_margin
        
        if distance_sq < (cull_distance * cull_distance) then
            visible_count = visible_count + 1
            visible_objects[visible_count] = obj
        end
    end

    -- OTIMIZAÇÃO 2: Limpamos os resíduos do frame anterior. 
    -- Isso garante que o table.sort não processe objetos invisíveis fantasmas.
    for i = visible_count + 1, #visible_objects do
        visible_objects[i] = nil
    end

    -- OTIMIZAÇÃO 1: Calculamos a trigonometria apenas UMA vez por frame.
    local angle = cam:getAngle()
    local sin_cam = math.sin(angle)
    local cos_cam = math.cos(angle)

    table.sort(visible_objects, function(a, b)
        -- Usamos as variáveis locais já calculadas acima
        local depthA = -a.x * sin_cam + a.y * cos_cam
        local depthB = -b.x * sin_cam + b.y * cos_cam
        
        return depthA < depthB
    end)

    visible_n = visible_count
end

function renderScene(cam)
    -- OTIMIZAÇÃO 2b: Usamos 'visible_n' em vez de '#visible_objects' para garantir exatidão
    for i = 1, visible_n do
        local obj = visible_objects[i] -- Criado um atalho local para manter o código limpo
        
        if obj.type == "player" then
            if obj.src.siting_on_a_chair.id > 0 then
                objects[obj.src.siting_on_a_chair.id].src:draw(
                    objects[obj.src.siting_on_a_chair.id].x, 
                    objects[obj.src.siting_on_a_chair.id].y, 
                    objects[obj.src.siting_on_a_chair.id].z, 
                    objects[obj.src.siting_on_a_chair.id].rad)
            end
            obj.src:draw(cam:getAngle())
        elseif obj.type == "droped_iten" then
            obj.src:draw(cam:getAngle())
        elseif obj.type == "chair" then
            for p = 1, #player do
                if player[p].siting_on_a_chair.id ~= obj.id then
                    obj.src:draw(obj.x, obj.y, obj.z, obj.rad)
                end
            end
        else
            if obj.type == "tree" then
                g.setBlendMode("alpha", "premultiplied")

                if time.hour >= 6 and time.hour < 12 then
                    g.setColor(1, 1, 1, ((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-6)/6)
                    g.draw(tree_shadow, obj.x, obj.y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                elseif time.hour >= 12 and time.hour < 18 then
                    g.setColor(1, 1, 1, 1-((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-12)/6)
                    g.draw(tree_shadow, obj.x, obj.y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                end

                g.setBlendMode("alpha")
            end
            
            --if obj.type == "grass" then
            --    g.setBlendMode("alpha", "premultiplied")
--
            --    if time.hour >= 6 and time.hour < 12 then
            --        g.setColor(1, 1, 1, ((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-6)/6)
            --        g.draw(grass_shadow, grass_shadow_quad, obj.x, obj.y, 0, 1, 1, grass_shadow:getWidth()/4, grass_shadow:getHeight()/2)
            --    elseif time.hour >= 12 and time.hour < 18 then
            --        g.setColor(1, 1, 1, 1-((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-12)/6)
            --        g.draw(grass_shadow, grass_shadow_quad, obj.x, obj.y, 0, 1, 1, grass_shadow:getWidth()/4, grass_shadow:getHeight()/2)
            --    end
--
            --    g.setBlendMode("alpha")
            --end
            
            obj.src:draw(obj.x, obj.y, obj.z, obj.rad)

            if obj.type == "cave_exit" then
                cave_exit_base:draw(obj.x, obj.y, obj.z, obj.rad)
            end
        end
    end
end