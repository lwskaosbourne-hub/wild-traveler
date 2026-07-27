function renderLoad()
    view_radius = 120 / camera_distance
end

visible_objects = {}
visible_n = 0

function renderUpdate(cam, objects)
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

local tree_shadow = g.newImage("assets/tree_shadow.png")

function renderScene(cam)
    -- OTIMIZAÇÃO 2b: Usamos 'visible_n' em vez de '#visible_objects' para garantir exatidão
    for i = 1, visible_n do
        local obj = visible_objects[i] -- Criado um atalho local para manter o código limpo
        
        if obj.type == "player" or obj.type == "droped_iten" then
            obj.src:draw(cam:getAngle())
        else
            if obj.type == "tree" then
                g.setBlendMode("alpha", "premultiplied")

                if time.hour >= 6 and time.hour < 12 then
                    g.setColor(1, 1, 1, (time.hour-6)/6)
                    g.draw(tree_shadow, obj.x, obj.y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                elseif time.hour >= 12 and time.hour < 18 then
                    g.setColor(1, 1, 1, 1-(time.hour-12)/6)
                    g.draw(tree_shadow, obj.x, obj.y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                end

                g.setBlendMode("alpha")
            end
            
            obj.src:draw(obj.x, obj.y, obj.z, obj.rad)
        end
    end
end