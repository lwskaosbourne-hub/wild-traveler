function renderLoad()
    view_radius = math.sqrt((love.graphics.getWidth()/2)^2 + (love.graphics.getHeight()/2)^2)/zoom
end

function renderScene(cam, objects)
    -- 1. FASE DE FILTRAGEM (Culling)
    local visible_objects = {}
    local visible_count = 0
    
    -- Posição atual da câmera no mundo
    local cam_x, cam_y = cam:getPosition() 
    
    for i = 1, #objects do
        local obj = objects[i]
        
        -- Calcula a distância entre o objeto e a câmera
        local dx = obj.src.x - cam_x
        local dy = obj.src.y - cam_y
        -- Omitir o math.sqrt e comparar com o raio ao quadrado deixa o código ainda mais rápido
        local distance_sq = (dx * dx) + (dy * dy) 
        
        -- Margem extra de segurança (ex: 64 pixels) para o objeto não sumir 
        -- bruscamente quando estiver na beiradinha da tela. Ajuste conforme o tamanho dos seus modelos.
        local obj_margin = 64 
        local cull_distance = view_radius + obj_margin
        
        if distance_sq < (cull_distance * cull_distance) then
            -- Se está dentro do raio, entra para a lista VIP de renderização
            visible_count = visible_count + 1
            visible_objects[visible_count] = obj
        end
    end

    -- 2. FASE DE ORDENAÇÃO
    -- Agora o table.sort trabalha apenas com os itens visíveis.
    -- Se antes ordenava 5000, agora talvez ordene só 50. O ganho de FPS aqui é absurdo.
    table.sort(visible_objects, function(a, b)
        local angle = cam:getAngle()
        -- Dica extra de otimização: armazenar o seno e cosseno em variáveis locais 
        -- evita chamar a função de matemática 4 vezes por comparação.
        local sin_cam = math.sin(angle)
        local cos_cam = math.cos(angle)
        
        local depthA = -a.src.x * sin_cam + a.src.y * cos_cam
        local depthB = -b.src.x * sin_cam + b.src.y * cos_cam
        
        return depthA < depthB
    end)

    -- 3. FASE DE DESENHO
    for i = 1, #visible_objects do
        local obj = visible_objects[i]
        obj.src:draw(cam:getAngle())
    end
end