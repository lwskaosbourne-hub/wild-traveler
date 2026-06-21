g = love.graphics
k = love.keyboard
w = love.window
m = love.mouse
a = love.audio
phy = love.physics

-- The type of dispositive version ("pc" or "android")
dispositive = "pc"

-- Graphics initiations:
g.setDefaultFilter("nearest", "nearest")

local font = g.newFont(7, "mono")
font:setLineHeight( font:getLineHeight()*2 )
g.setFont(font)

-- Requires:
require 'bin/danim'
require 'bin/scenes/scene'

function distanceFrom(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function love.load()
	--love.window.setMode(640, 440, {vsync=1, resizable=true}) -- 267, 150
	zoom = (g.getHeight()/(450/3))

	relativeMode = true
	if dispositive == "android" then
		w.setFullscreen(true)
	else
		m.setRelativeMode(relativeMode)
	end

	scene_load()

	dev_gui = false
end

function love.update(dt)
	scene_update(dt)
	--zoom = (g.getHeight()/(450/3))
	--cam:setWindow(100, 0, g.getWidth(), g.getHeight())
	--cam:setScale(zoom)
end

function love.draw()
	scene_draw()

	g.setColor(1,1,1)
	g.print("Alpha 0.0.1 | FPS: "..love.timer.getFPS(), g.getWidth() - zoom*60, g.getHeight() - zoom*10, 0, zoom/1.5, zoom/1.5)

	if dev_gui == true then
		g.print("Graphics zoom: "..zoom, zoom*5, zoom*10, 0, zoom/2, zoom/2)
		g.print("Camera distance: "..camera_distance, zoom*5, zoom*15, 0, zoom/2, zoom/2)
		g.print("Player position (X, Y): "..get_coord_x(player[1].bodyPhy:getX())..", "..get_coord_y(player[1].bodyPhy:getY()), zoom*5, zoom*15, 0, zoom/2, zoom/2)
	end
end

function love.keypressed(key)
	if scene == "game" then
		scene_keypressed(key)
		if key == 'escape' then
			if relativeMode == true then
				relativeMode = false
				m.setRelativeMode(relativeMode)
			else
				relativeMode = true
				m.setRelativeMode(relativeMode)
			end
		end
	end

	if key == 'f1' then
		if dev_gui == true then
			dev_gui = false
		else
			dev_gui = true
		end
	end
end

function love.wheelmoved(x, y)
    if scene == "game" then
		if y > 0 and camera_distance <= 1.5 then
			camera_distance = camera_distance + 0.01
			cam:setScale(zoom*camera_distance)
		elseif y < 0 and camera_distance >= 0.5 then
			camera_distance = camera_distance - 0.01
			cam:setScale(zoom*camera_distance)
		end
	end
end

function love.mousemoved(x, y, dx, dy)
	if scene == "game" then
		if relativeMode == true then
			if dispositive == "pc" then
				if player[1].movementsBlocked == false then
					cam:setAngle(cam:getAngle()+(dx*love.timer.getDelta()/10))
				end
			end
		end
	end
end

function love.mousepressed(x, y, key)
	if scene == "game" then
		if inventory_window == true then
			inventory_buttonpressed(x, y, key)
		end
	end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	if scene == "game" then
		if relativeMode == true then
			if dispositive == "android" and x > g.getWidth()/2 then
				if player[1].movementsBlocked == false then
					cam:setAngle(cam:getAngle()+(dx*love.timer.getDelta()/10))
				end
			end
		end
	end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
	if scene == "game" then
		if dispositive == "android" then
			if x >= g.getWidth() - ((bag_icon:getWidth()+2)*zoom) and
				x <= g.getWidth() - ((bag_icon:getWidth()+2)*zoom) + (bag_icon:getWidth()*zoom) and
				y >= 2*zoom and y <= (2*zoom) + (bag_icon:getHeight()*zoom) then
					if inventory_window == true then
						inventory_window = false
						player[1].movementsBlocked = false
						relativeMode = true
						m.setRelativeMode(relativeMode)
					else
						selected_box = 0
						inventory_window = true
						player[1].movementsBlocked = true
						relativeMode = false
						m.setRelativeMode(relativeMode)
						m.setPosition(g.getWidth()/2, g.getHeight()/2)
					end
			end
		end
	end
end

function love.resize(w, h)
	-- The zoom needs to be changed when the window resizes:
	zoom = (h/(450/3))
	cam:setWindow(0, 0, w, h)
	cam:setScale(zoom*camera_distance)
	toutch_buttons.movement.x = zoom*toutch_buttons.movement.size+10
	toutch_buttons.movement.y = g.getHeight() - (zoom*toutch_buttons.movement.size+10)
	toutch_buttons.movement.rad = zoom*toutch_buttons.movement.size
	inventory_window_x = g.getWidth()/2
	inventory_window_y = g.getHeight()/2
	inventory_set()
end