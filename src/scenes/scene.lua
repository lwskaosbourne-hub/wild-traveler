-- Scene init:
scene = "game"

-- Screen Effects:
fade = 0
fade_alpha = 0
---------------------

require 'src/scenes/game/game_scene'

function scene_load()
	if scene == "game" then
		game_load()
	end
end

function scene_update(dt)
	if fade == 1 then
		if fade_alpha <= 1 then
			fade_alpha = fade_alpha + dt
		end
	else
		if fade_alpha >= 0 then
			fade_alpha = fade_alpha - dt
		end
	end

	if scene == "start" then
	elseif scene == "game" then
		game_update(dt)
	end
end

function scene_draw()
	if scene == "start" then
	elseif scene == "game" then
		game_draw()
	end

	g.setColor(0,0,0,fade_alpha)
	g.rectangle("fill", 0, 0, g.getWidth(), g.getHeight())
end

function scene_keypressed(key)
	if scene == "game" then
		game_keypressed(key)
	end
end