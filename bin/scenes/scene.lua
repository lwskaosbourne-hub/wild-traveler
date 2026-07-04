-- Scene init:
scene = "game"

player_id = 1

-- Physics:
world = phy.newWorld(0, 0, true)

gamera = require 'bin/scenes/game/gamera'
require 'bin/danim'
Sprite = require 'bin/scenes/game/sprites'
Model = require 'bin/scenes/game/models'
require 'bin/scenes/game/items'
Player = require 'bin/scenes/game/entities/player'
require 'bin/scenes/game/inventory_window'
require 'bin/scenes/game/map'

-- Enable/Disable Shadows (0 -> 'disabled', 1 -> 'enabled'):
shadows = 1

function scene_load()
	-- Camera creation/configures:
	cam = gamera.new(0, 0, g.getWidth(), g.getHeight())
	camera_distance = 1
	cam:setWorld(0, 0, worldW, worldH)
	cam:setScale(zoom*camera_distance)
	cam:setPosition(worldW/2, worldH/2)

	player = {}
	player[1] = Player(50, 20, 0, "cat", 1, 1)

	inventory_set()

	-- Models textures:
	tree = g.newImage("src/models/tree.png")
	tree2 = g.newImage("src/models/tree2.png")
	wall = g.newImage("src/models/brickWall.png")
	grass = g.newImage("src/models/grass.png")

	objects = {}
	objects[1] = {type = "player", src = player[player_id], id = player_id}
	--objects[2] = {type = "model", src = Model("tree", 3, 3, 64, 64)} -- o modelo recebe: o nome do modelo, a posição x, a posição y, largura e altura
	--objects[3] = {type = "model", src = Model("tree", 1, 1, 64, 64)} -- aqui eu coloquei apenas uma variável a mais para mudar a cor dos modelos e distinguir
	--objects[4] = {type = "model", src = Model("flowers", 5, 5, 16, 16)}

	map_create_objects()

	model_render = {}
	model_shadow_render = {}
	model_shadow_position = 0
	model_shadow_destinyPosition = 0
	model_shadow_angle = 45
	max_models_render = 64
	for i = 0, max_models_render do
		model_render[i] = {dx = 0, dy = 0}
		model_shadow_render[i] = {dx = 0, dy = 0}
	end

	toutch_buttons = {}
	toutch_buttons.movement = {id = nil, dist = 1, is_pressed = false, 
								x = zoom*30, y = g.getHeight() - (zoom*30), 
								rad = zoom*20, 
								dx = zoom*30, dy = g.getHeight() - (zoom*30), 
								angle = 0, size = 30}
	toutch_buttons.movement.x = zoom*toutch_buttons.movement.size+10
	toutch_buttons.movement.y = g.getHeight() - (zoom*toutch_buttons.movement.size+10)
	toutch_buttons.movement.rad = zoom*toutch_buttons.movement.size

	hp_icon = g.newImage("src/heart.png")
	bag_icon = g.newImage("src/bag.png")

	time = {
		hour = 12,
		hour_max = 23,
		count = 0,
		speed = 1
	}

	day_light = 0
end

function scene_update(dt)
	if scene == "start" then
	elseif scene == "game" then
		player[player_id]:update(dt, cam:getAngle())
		cam:setPosition(player[player_id]:getPosition())

		inventory_update(dt)

		map_update(dt)

		-- Day/Night process:
		if time.count >= 1 then
			if time.hour >= time.hour_max then
				time.hour = 0
			else
				time.hour = time.hour + (dt*time.speed)
			end
			time.count = 0
		else
			time.count = time.count + (dt*time.speed)
		end

		model_shadow_position = (time.hour-12)*12/24
		if time.hour >= 1 and time.hour < 12 then
			-- Manhã:
			day_light = 0.5 - (time.hour*0.5/12)
		elseif time.hour >= 12 and time.hour < 13 then
			-- Meio-dia:
			day_light = 0
		elseif time.hour >= 0 and time.hour < 1 then
			-- Meia-noite:
			day_light = 0.5
		else
			-- Tarde/Noite:
			day_light = ((time.hour-12)*0.5/12)
		end
			

		if k.isDown("up") then
			time.speed = 10
		elseif k.isDown("down") then
			time.speed = 5
		else
			time.speed = 1
		end
			
		if k.isDown("left") then
			model_shadow_angle = model_shadow_angle + 1
		elseif k.isDown("right") then
			model_shadow_angle = model_shadow_angle - 1
		end

		for i = 0, max_models_render do
			model_render[i].dx = i * math.cos(cam:getAngle() - math.rad(90))
			model_render[i].dy = i * math.sin(cam:getAngle() - math.rad(90))
			
			model_shadow_render[i].dx = (i * math.cos(math.rad(model_shadow_angle))) * model_shadow_position
			model_shadow_render[i].dy = (i * math.sin(math.rad(model_shadow_angle))) * model_shadow_position
		end

		world:update(dt)

    	-- ALGORITMO DE ORDENAÇÃO 2.5D:
    	table.sort(objects, function(a, b)
        	-- Projetamos a posição X e Y de cada objeto no eixo de visão da câmera.
        	-- Baseado no seu código de draw, esta fórmula calcula quem está mais "atrás" na tela:
        	local depthA = -a.src.x * math.sin(cam:getAngle()) + a.src.y * math.cos(cam:getAngle())
        	local depthB = -b.src.x * math.sin(cam:getAngle()) + b.src.y * math.cos(cam:getAngle())
        
        	-- Quem tiver a menor profundidade (mais longe da câmera) deve ser desenhado primeiro (fundo)
        	return depthA < depthB
    	end)

		if dispositive == "android" then
			-- Obtém uma lista com os IDs de todos os toques ativos na tela no frame atual
			local active_touches = love.touch.getTouches()
			local still_touching = false

			if not toutch_buttons.movement.is_pressed then
    			-- ESTADO 1: O direcional NÃO está pressionado.
    			-- Vamos procurar se algum dedo tocou dentro da área dele.
    			for i, id in ipairs(active_touches) do
    			    local tx, ty = love.touch.getPosition(id)
    			    local dist = distanceFrom(tx, ty, toutch_buttons.movement.x, toutch_buttons.movement.y)
        
    			    if dist <= toutch_buttons.movement.rad then
    			        -- Captura o controle!
    			        toutch_buttons.movement.is_pressed = true
    			        toutch_buttons.movement.touch_id = id
            			break -- Já encontramos o dedo, não precisamos olhar os outros.
        			end
    			end

			else
    			-- ESTADO 2: O direcional ESTÁ pressionado.
    			-- Vamos procurar especificamente pelo dedo que capturou o controle.
    			for i, id in ipairs(active_touches) do
        
        			if id == toutch_buttons.movement.touch_id then
            			still_touching = true -- O dedo ainda está na tela
            
            			local touchX, touchY = love.touch.getPosition(id)
            			local currentDist = distanceFrom(touchX, touchY, toutch_buttons.movement.x, toutch_buttons.movement.y)
            
            			toutch_buttons.movement.angle = math.atan2((touchY - toutch_buttons.movement.y), (touchX - toutch_buttons.movement.x))

            			-- Aplica a trava geométrica
            			if currentDist > toutch_buttons.movement.rad then
                			toutch_buttons.movement.dx = toutch_buttons.movement.x + math.cos(toutch_buttons.movement.angle) * toutch_buttons.movement.rad
                			toutch_buttons.movement.dy = toutch_buttons.movement.y + math.sin(toutch_buttons.movement.angle) * toutch_buttons.movement.rad
							toutch_buttons.movement.dist = 1
            			else
                			toutch_buttons.movement.dx = touchX
                			toutch_buttons.movement.dy = touchY
							toutch_buttons.movement.dist = currentDist*1/toutch_buttons.movement.rad
            			end
            
            			break -- Já processamos o dedo correto, podemos sair do loop.
        			end
    			end

    			-- Se o loop terminou e não encontramos o ID armazenado, o jogador soltou esse dedo.
    			if not still_touching then
        			toutch_buttons.movement.is_pressed = false
        			toutch_buttons.movement.touch_id = nil
        			toutch_buttons.movement.dx = toutch_buttons.movement.x
        			toutch_buttons.movement.dy = toutch_buttons.movement.y
    			end
			end
		end
	end
end

function scene_draw()
	if scene == "start" then
	elseif scene == "game" then
		cam:draw(function(l,t,w,h)
			water_draw()
			map_draw(cam:getAngle())
			if shadows == 1 then
				for _, obj in ipairs(objects) do
					if distanceFrom(obj.src.x, obj.src.y, cam:getPosition()) < 200/camera_distance+model_shadow_position then
						if obj.type ~= "player" then
							obj.src:draw_shadow()
						end
					end
    			end
			end
			if relativeMode == false then
				local x = get_x(get_coord_x(cam:toWorldX(m.getX(), m.getY()))) - (tileSize/2)
				local y = get_y(get_coord_y(cam:toWorldY(m.getX(), m.getY()))) - (tileSize/2)
				g.setColor(1,0,0,0.5)
				g.rectangle("line", x, y, tileSize, tileSize)
			end
			for _, obj in ipairs(objects) do
				if distanceFrom(obj.src.x, obj.src.y, cam:getPosition()) < 200/camera_distance then
					obj.src:draw(cam:getAngle())
				end
    		end
		end)

		if dispositive == "android" then
			if inventory_window == false then
				g.setColor(1,1,1)
				g.circle("line", toutch_buttons.movement.x, toutch_buttons.movement.y, toutch_buttons.movement.rad)
				g.circle("fill", toutch_buttons.movement.dx, toutch_buttons.movement.dy, toutch_buttons.movement.rad/3)
			end

			g.setColor(1,1,1)
			g.draw(bag_icon, g.getWidth() - ((bag_icon:getWidth()+2)*zoom), 2*zoom, 0, zoom, zoom)
		end

		-- Screen Color and Lights:
        g.setColor(0,0,0, day_light)
		g.rectangle("fill", 0, 0, g.getWidth(), g.getHeight())

		--g.setColor(1,1,1)
		--g.print("Hour: "..time.hour.."/"..time.hour_max .. " / "..day_light, zoom, zoom*10, 0, zoom, zoom)

		for i = 0, 5 do
			g.setColor(1,1,1)
			g.draw(hp_icon, (i * (hp_icon:getWidth() + 1) + 2)*zoom, zoom*2, 0, zoom, zoom)
		end

		if inventory_window == true then
			inventory_draw()
		end
	end
end

function scene_keypressed(key)
	for _, p in ipairs(player) do
		p:keypressed(key)
    end

	if key == "tab" then
		if inventory_window == true then
			inventory_window = false
			player[player_id].movementsBlocked = false
			relativeMode = true
			m.setRelativeMode(relativeMode)
		else
			selected_box = 0
			inventory_window = true
			player[player_id].movementsBlocked = true
			relativeMode = false
			m.setRelativeMode(relativeMode)
			m.setPosition(g.getWidth()/2, g.getHeight()/2)
		end
	end
end