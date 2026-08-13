local limite_rotacao = 0.5 

function atmosphere_init()
    -- Cria uma tabela para guardar nossos vagalumes
    vagalumes_luzes = {}
    local quantidade_vagalumes = 500

    for i = 1, quantidade_vagalumes do
        local x_inicial = get_x(math.random(1, 100))
        local y_inicial = get_y(math.random(1, 100))
        local raio = math.random(3, 5)
        local cor = {0.6, 1.0, 0.3} -- Verde/Amarelo neon
        local intensidade = 0.8

        -- Cria a luz usando a função do seu sistema
        local luz = light_system.addLight(x_inicial, y_inicial, raio, cor, intensidade)
        
        -- Salvamos a luz junto com dados extras para fazer o movimento depois
        table.insert(vagalumes_luzes, {
            obj = luz,
            base_x = x_inicial,
            base_y = y_inicial,
            offset = math.random(0, 100)
        })
    end
end

function night_atmosphere_update(dt)
    -- No love.update(dt)
    local tempo = love.timer.getTime()
    local speed = 1
    
    for _, v in ipairs(vagalumes_luzes) do
        if time.hour >= 19 or time.hour <= 5 then
            -- Calcula o novo deslocamento baseado no tempo
            local dx = math.sin((tempo * speed) + v.offset) * 30
            local dy = math.cos((tempo * speed * 0.8) + v.offset) * 30
            
            -- Atualiza a posição da luz no sistema
            v.obj.x = v.base_x + dx
            v.obj.y = v.base_y + dy
            
            -- Se o seu sistema permitir mudar a intensidade/raio em tempo real para o efeito de piscar:
            local pulso = (math.sin((tempo * 1.0) + v.offset) + 1) / 2
            v.obj.intensity = 0.2 + (0.6 * pulso) -- Pisca de 0.2 a 0.8 de intensidade
        else
            v.obj.intensity = 0
        end
    end
end

function night_atmosphere()
    -- 1. Cálculo do tempo para a Noite (ex: das 18:00 até as 06:00)
    local alpha_time_lua = 0
    
    if time.hour >= 19 and time.hour < 24 then
        -- Anoitecer: vai de 0 (às 18h) até 1 (às 00h)
        alpha_time_lua = ((time.hour + (time.minutes * 0.9 / (time.minutes_max - 1))) - 19) / 6
    elseif time.hour >= 0 and time.hour < 6 then
        -- Madrugada/Amanhecer: vai de 1 (às 00h) até 0 (às 06h)
        alpha_time_lua = 1 - ((time.hour + (time.minutes * 0.9 / (time.minutes_max - 1))) / 6)
    end
    
    alpha_time_lua = math.max(0, math.min(0.2, alpha_time_lua))

    -- 2. Se for noite, aplica a lógica da câmera e renderiza o luar
    if alpha_time_lua > 0 then
        local alpha_camera = 1 - (math.abs(cam:getAngle()) / limite_rotacao)
        alpha_camera = math.max(0, alpha_camera)
        
        local light_zoom = zoom / 20
        local final_intensity_lua = alpha_time_lua * alpha_camera

        if final_intensity_lua > 0 then
            g.setBlendMode("add")
        
            local img = light_system.image
            local ox = img:getWidth() / 2
            local oy = img:getHeight() / 2
            local gw, gh = g.getWidth(), g.getHeight()
        
            -- Cor Azulada/Fria típica de luar
            -- Brilho Central no canto superior DIREITO (gw, 0)
            g.setColor(0.4, 0.6, 0.9, 0.6 * final_intensity_lua)
            g.draw(img, gw, 0, 0, 2 * light_zoom, 2 * light_zoom, ox, oy)
        
            -- Feixe Principal Lunar (Invertido na diagonal contrária)
            g.draw(img, gw, 0, math.pi * 0.75, 6 * light_zoom, 1.5 * light_zoom, ox, oy)
        
            -- Reflexos Lunares na diagonal opuesta
            g.setColor(0.4, 0.6, 0.9, 0.2 * final_intensity_lua)
            g.draw(img, gw * 0.8, gh * 0.2, 0, 0.5 * light_zoom, 0.5 * light_zoom, ox, oy)
            g.draw(img, gw * 0.65, gh * 0.35, 0, 0.3 * light_zoom, 0.3 * light_zoom, ox, oy)
            g.draw(img, gw * 0.45, gh * 0.55, 0, 0.8 * light_zoom, 0.8 * light_zoom, ox, oy)
        
            -- Limpeza
            g.setBlendMode("alpha")
            g.setColor(1, 1, 1, 1)
        end
    end
end

function day_atmosphere()
    if time.hour >= 6 and time.hour < 12 then
        g.setColor(1, 1, 1, ((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-6)/6)
        g.draw(sun_light, g.getWidth()/2, g.getHeight()/2, -cam:getAngle(), zoom*sun_radius, zoom*sun_radius, sun_light:getWidth()/2, sun_light:getHeight()/2)
    elseif time.hour >= 12 and time.hour < 18 then
        g.setColor(1, 1, 1, 1-((time.hour + (time.minutes*0.9/(time.minutes_max-1)))-12)/6)
        g.draw(sun_light, g.getWidth()/2, g.getHeight()/2, -cam:getAngle(), zoom*sun_radius, zoom*sun_radius, sun_light:getWidth()/2, sun_light:getHeight()/2)
    end
	
	local alpha_time = 0
	if time.hour >= 6 and time.hour < 12 then
	    alpha_time = ((time.hour + (time.minutes * 0.9 / (time.minutes_max - 1))) - 6) / 6
	elseif time.hour >= 12 and time.hour < 18 then
	    alpha_time = 1 - ((time.hour + (time.minutes * 0.9 / (time.minutes_max - 1))) - 12) / 6
	end
	alpha_time = math.max(0, math.min(1, alpha_time))
	if alpha_time > 0 then
	    local alpha_camera = 1 - (math.abs(cam:getAngle()) / limite_rotacao)
	    alpha_camera = math.max(0, alpha_camera)
		local light_zoom = zoom/20
	
	    local final_intensity = alpha_time * alpha_camera
	
	    if final_intensity > 0 then
	        g.setBlendMode("add")
		
	        local img = light_system.image
	        local ox = img:getWidth() / 2
	        local oy = img:getHeight() / 2
	        local gw, gh = g.getWidth(), g.getHeight()
		
	        -- Brilho Central (com alpha base de 0.8)
	        g.setColor(1, 0.9, 0.7, 0.8 * final_intensity)
	        g.draw(img, 0, 0, 0, 2*light_zoom, 2*light_zoom, ox, oy)
		
	        -- Feixe Principal (esticado)
	        g.draw(img, 0, 0, math.pi / 4, 6*light_zoom, 1.5*light_zoom, ox, oy)
		
	        -- Reflexos (Lens flares na diagonal)
	        g.setColor(1, 0.95, 0.8, 0.3 * final_intensity)
	        g.draw(img, gw * 0.2, gh * 0.2, 0, 0.5*light_zoom, 0.5*light_zoom, ox, oy)
	        g.draw(img, gw * 0.35, gh * 0.35, 0, 0.3*light_zoom, 0.3*light_zoom, ox, oy)
	        g.draw(img, gw * 0.55, gh * 0.55, 0, 0.8*light_zoom, 0.8*light_zoom, ox, oy)
		
	        -- Limpeza
	        g.setBlendMode("alpha")
	        g.setColor(1, 1, 1, 1)
	    end
	end
end