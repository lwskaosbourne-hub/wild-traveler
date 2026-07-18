g = love.graphics
k = love.keyboard
w = love.window
m = love.mouse
a = love.audio
phy = love.physics

version = "Alpha 0.1.1"

-- The type of dispositive version ("pc" or "android")
dispositive = "pc"

-- Graphics initiations:
g.setDefaultFilter("nearest", "nearest")

local font = g.newFont(7, "mono")
font:setLineHeight( font:getLineHeight()*2 )
g.setFont(font)

function get_rgb(r, g, b)
	return (r/255), (g/255), (b/255)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

-- Requires:
require 'lib/danim'
require 'src/scenes/scene'

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

	fullscreen = false
end

function love.update(dt)
	scene_update(dt)
end

function love.draw()
	scene_draw()

	g.setColor(1,1,1)
	g.print(version.." | FPS: "..love.timer.getFPS(), g.getWidth() - zoom*60, g.getHeight() - zoom*10, 0, zoom/1.5, zoom/1.5)

	if dev_gui == true then
		g.print("Graphics zoom: "..zoom, zoom*5, zoom*50, 0, zoom/2, zoom/2)
		g.print("Camera distance: "..camera_distance, zoom*5, zoom*55, 0, zoom/2, zoom/2)
		g.print("Player position (X, Y): "..get_coord_x(player[player_id].bodyPhy:getX())..", "..get_coord_y(player[player_id].bodyPhy:getY()), zoom*5, zoom*60, 0, zoom/2, zoom/2)
		g.print("Total objects: "..#objects, zoom*5, zoom*65, 0, zoom/2, zoom/2)
		g.print("Visible objects: "..visible_n, zoom*5, zoom*70, 0, zoom/2, zoom/2)
	end
end

function love.keypressed(key)
	scene_keypressed(key)

	if key == "f12" then
		if fullscreen == false then
			fullscreen = true
		else
			fullscreen = false
		end
		w.setFullscreen(fullscreen)
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
		renderLoad()
	end
end

function love.mousemoved(x, y, dx, dy)
	if scene == "game" then
		if relativeMode == true then
			if dispositive == "pc" then
				if player[player_id].movementsBlocked == false then
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
		else
			if key == 1 then
				player[player_id]:atk()
				objects_interact()
			end
		end
	end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	if scene == "game" then
		if relativeMode == true then
			if dispositive == "android" and x > g.getWidth()/2 then
				if player[player_id].movementsBlocked == false then
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

			if inventory_window == true then
				inventory_buttonpressed(x, y)
			end
		end
	end
end

function love.resize(w, h)
	-- The zoom needs to be changed when the window resizes:
	zoom = (h/(450/3))
	if scene == "game" then
		cam:setWindow(0, 0, w, h)
		cam:setScale(zoom*camera_distance)
		toutch_buttons.movement.x = zoom*toutch_buttons.movement.size+10
		toutch_buttons.movement.y = g.getHeight() - (zoom*toutch_buttons.movement.size+10)
		toutch_buttons.movement.rad = zoom*toutch_buttons.movement.size
		inventory_window_x = g.getWidth()/2
		inventory_window_y = g.getHeight()/2
		inventory_set()
		light_system.load(w, h)
		renderLoad()
	end
end