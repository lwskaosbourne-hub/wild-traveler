danim={}
danim.objs={}
danim.objsTile={}

function danim:new(name, img, frames, y)
	danim.objs[#danim.objs + 1]={
		name=name,
		img=img,
		yframes=y,
		quad=love.graphics.newQuad(0, 0, img:getWidth()/frames, img:getHeight()/y, img:getDimensions()),
		t=0,
		frames=frames,
		f=0,
		w=img:getWidth()/frames,
		h=img:getHeight()/y,
		fY=0
	}
end

function danim:update(name, vel, dt)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			if danim.objs[i].t >= 1 then
				if danim.objs[i].f == danim.objs[i].frames - 1 then
					danim.objs[i].f = 0
				else
					danim.objs[i].f = danim.objs[i].f + 1
				end

				danim.objs[i].quad:setViewport( 
					(danim.objs[i].img:getWidth()/danim.objs[i].frames) * danim.objs[i].f, 
					(danim.objs[i].img:getHeight()/danim.objs[i].yframes) * danim.objs[i].fY, 
					danim.objs[i].img:getWidth()/danim.objs[i].frames, 
					danim.objs[i].img:getHeight()/danim.objs[i].yframes )

				danim.objs[i].t = 0
			else
				danim.objs[i].t = danim.objs[i].t + (vel*dt)
			end
		end
	end
end

function danim:draw(name, x, y, rad, w, h, color)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			love.graphics.setColor(color)
			love.graphics.draw(danim.objs[i].img, danim.objs[i].quad, x, y, rad, w, h, danim.objs[i].w/2, danim.objs[i].h/2)
		end
	end
end

function danim:drawTile(name, x, y, rad, w, h, color)
	for i=1, #danim.objsTile do
		if name == danim.objsTile[i].name then
			love.graphics.setColor(color)
			love.graphics.draw(danim.objsTile[i].img, danim.objsTile[i].quad, x, y, rad, w, h, danim.objsTile[i].w/2, danim.objsTile[i].h/2)
		end
	end
end

function danim:getFrame(name)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			return danim.objs[i].f
		end
	end
end

function danim:setFrame(name, frame)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			danim.objs[i].f = frame

			danim.objs[i].quad:setViewport( 
					(danim.objs[i].img:getWidth()/danim.objs[i].frames) * danim.objs[i].f, 
					(danim.objs[i].img:getHeight()/danim.objs[i].yframes) * danim.objs[i].fY, 
					danim.objs[i].img:getWidth()/danim.objs[i].frames, 
					danim.objs[i].img:getHeight()/danim.objs[i].yframes )
		end
	end
end

function danim:setYframe(name, frame)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			danim.objs[i].fY = frame
		end
	end
end

function danim:setImage(name, img)
	for i=1, #danim.objs do
		if name == danim.objs[i].name then
			danim.objs[i].img = img
		end
	end
end