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
	
gamera = require 'lib/gamera'
require 'lib/danim'
Sprite = require 'src/scenes/game/sprites'
Model = require 'src/scenes/game/models'
require 'src/scenes/game/items'
DropedItens = require 'src/scenes/game/entities/droped_iten'
Player = require 'src/scenes/game/entities/player'
require 'src/scenes/game/inventory_window'
require 'src/scenes/game/map'
require 'src/scenes/game/hud'
require 'src/scenes/game/render'
light_system = require "src/scenes/game/light_system"
light_system.load(g.getWidth(), g.getHeight())
require "src/scenes/game/day_cicle"
require "src/scenes/game/objects"
require "src/scenes/game/teleport"

-- Enable/Disable Shadows (0 -> 'disabled', 1 -> 'enabled'):
shadows = 0

function touch_buttons_ini()
	toutch_buttons = {}
	toutch_buttons.movement = {id = nil, dist = 1, is_pressed = false, 
								x = zoom*30, y = g.getHeight() - (zoom*30), 
								rad = zoom*20, 
								dx = zoom*30, dy = g.getHeight() - (zoom*30), 
								angle = 0, size = 30}
	toutch_buttons.movement.x = zoom*toutch_buttons.movement.size+10
	toutch_buttons.movement.y = g.getHeight() - (zoom*toutch_buttons.movement.size+10)
	toutch_buttons.movement.rad = zoom*toutch_buttons.movement.size

	toutch_buttons.attack = {
		x = g.getWidth() - (zoom*40),
		y = g.getHeight() - (zoom*30),
		size = zoom*15,
		is_pressed = false
	}
end

function game_load()
    player_id = 1

    -- Physics:
    world = phy.newWorld(0, 0, true)

    -- Camera creation/configures:
	cam = gamera.new(0, 0, g.getWidth(), g.getHeight())
	camera_distance = 1
	cam:setWorld(0, 0, worldW, worldH)
	cam:setScale(zoom*camera_distance)
	cam:setPosition(worldW/2, worldH/2)
	last_camera_angle = cam:getAngle()

	player = {}
	--player[1] = Player(49, 15, 1, "cat", 2, 1)
	player[1] = Player(47, 97, earlyMap, "cat", 2, 1)
	player[1].rad = math.rad(180)

	inventory_set()

	renderLoad()

	--luz_do_jogador = light_system.addLight(player[player_id].bodyPhy:getX(), player[player_id].bodyPhy:getY(), 100, {1, 1, 1}, 1)
	--light_system.addLight(get_x(50), get_y(30), 100, {0.5, 0.3, 0}, 1)

	objects_ini()

	touch_buttons_ini()

	hp_icon = g.newImage("assets/heart.png")
	bag_icon = g.newImage("assets/bag.png")

	time = {
		hour = 15,
		hour_max = 23,
		minutes = 0,
		minutes_max = 60,
		count = 0,
		speed = 0.5
	}

	day_light = 0

	local atk_image = g.newImage("assets/attack.png")
	danim:new("player_attack", atk_image, 6, 1)

	insert_objects = false
end

function game_update(dt)
    for o = 1, #objects do
		if objects[o].type ~= "player" then
        	objects[o].src:update(dt)
		end
    end
	player[player_id]:update(dt, cam:getAngle())
	cam:setPosition(player[player_id].bodyPhy:getPosition())

	if block_while_transiting == false then
		map_update(dt)
		renderUpdate(cam, objects)
		objects_update(dt)
		inventory_update(dt)
	end
	teleport_update(dt)
	update_hud(dt)

	-- Day/Night process:
	--if time.count >= 1 then
	--	if time.hour > time.hour_max then
	--		time.hour = 0
	--	else
	--		time.hour = time.hour + 0.01
	--	end
	--	time.count = 0
	--else
	--	time.count = time.count + (time.speed*dt)
	--end
	if time.minutes >= time.minutes_max then
		if time.hour == time.hour_max then
			time.hour = 0
		else
			time.hour = time.hour + 1
		end
		time.minutes = 0
	else
		time.minutes = time.minutes + (time.speed*dt)
	end
	
	updateDayNightCycle(time.hour + (time.minutes*0.9/(time.minutes_max-1)))

	if k.isDown("up") then
		time.speed = 20
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
		
		--model_shadow_render[i].dx = (i * math.cos(math.rad(model_shadow_angle))) * model_shadow_position
		--model_shadow_render[i].dy = (i * math.sin(math.rad(model_shadow_angle))) * model_shadow_position
	end
	world:update(dt)
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

function game_draw()
    cam:draw(function(l,t,w,h)
		water_draw()
		map_draw(cam:getAngle())
		if insert_objects == true then
			local x = get_x(get_coord_x(cam:toWorldX(m.getX(), m.getY()))) - (tileSize/2)
			local y = get_y(get_coord_y(cam:toWorldY(m.getX(), m.getY()))) - (tileSize/2)
			g.setColor(1,0,0,0.5)
			g.rectangle("line", x, y, tileSize, tileSize)
		end
		if block_while_transiting == false then
			renderScene(cam, objects)
		end

		if dev_gui == true then
			for i = 1, #map[earlyMap].teleport do
				g.setColor(1,1,1,0.5)
				g.rectangle("fill", map[earlyMap].teleport[i].x - 8, map[earlyMap].teleport[i].y - 8, 16, 16)
			end
		end
	end)
	if dispositive == "android" then
		if inventory_window == false then
			g.setColor(1,1,1)
			g.circle("line", toutch_buttons.movement.x, toutch_buttons.movement.y, toutch_buttons.movement.rad)
			g.circle("fill", toutch_buttons.movement.dx, toutch_buttons.movement.dy, toutch_buttons.movement.rad/3)

			g.circle("fill", toutch_buttons.attack.x, toutch_buttons.attack.y, toutch_buttons.attack.size)
		end
		g.setColor(1,1,1)
		g.draw(bag_icon, g.getWidth() - ((bag_icon:getWidth()+2)*zoom), 2*zoom, 0, zoom, zoom)
	end
	-- Screen Color and Lights:
	light_system.draw(cam)

	draw_hud()

	if inventory_window == true then
		inventory_draw()
	end
end

function game_keypressed(key)
    for _, p in ipairs(player) do
		p:keypressed(key)
    end
    
		
	if key == 'escape' then
		if relativeMode == true then
			relativeMode = false
			m.setRelativeMode(relativeMode)
		else
			relativeMode = true
			m.setRelativeMode(relativeMode)
		end
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