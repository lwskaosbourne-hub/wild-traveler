local Object = require "lib/classic"
local Sprite = Object:extend()

function Sprite:new(name, texture, frames_x, frames_y)
    self.name = name
    self.texture = g.newImage(texture)
    self.rad = 0
    self.index_x = 0
    self.index_y = 0
    self.frames_x = frames_x
    self.frames_y = frames_y
    self.frame_w = self.texture:getWidth()/frames_x
    self.frame_h = self.texture:getHeight()/frames_y
    self.animCount = 0
    self.y_divide = 1
    self.quad = g.newQuad(self.index_x, self.index_y, self.frame_w, self.frame_h/self.y_divide, self.texture:getDimensions())
end

function Sprite:setY(y)
    self.index_y = y*self.frame_h
    self.quad:setViewport(self.index_x, self.index_y, self.frame_w, self.frame_h/self.y_divide, self.texture:getDimensions())
end

function Sprite:setX(x)
    self.index_x = x*self.frame_w
    self.quad:setViewport(self.index_x, self.index_y, self.frame_w, self.frame_h/self.y_divide, self.texture:getDimensions())
end

function Sprite:anim(speed, dt)
    if self.animCount >= 1 then
        if self.index_x >= self.frame_w*self.frames_x - self.frame_w then
            self.index_x = 0
            self.quad:setViewport(self.index_x, self.index_y, self.frame_w, self.frame_h/self.y_divide, self.texture:getDimensions())
        else
            self.index_x = self.index_x + self.frame_w
            self.quad:setViewport(self.index_x, self.index_y, self.frame_w, self.frame_h/self.y_divide, self.texture:getDimensions())
        end
        
        self.animCount = 0
    else
        self.animCount = self.animCount + speed*dt
    end
end

function Sprite:draw(x, y, camera_rad)
    g.setColor(1,1,1)
    g.draw(self.texture, self.quad, x, y, camera_rad, 1, 1, self.frame_w/2, self.frame_h/self.y_divide)
end

function Sprite:setTexture(src)
    self.texture = g.newImage(src)
end

function Sprite:get_frame_x() return self.index_x end
function Sprite:get_frame_y() return self.index_y end

return Sprite