local Object = require "lib/classic"
local Model = Object:extend()

function Model:new(image, x, y, w, h, collision, anim, color)
    self.image = image
    self.x = get_x(x)
    self.y = get_y(y)
    self.width = w
    self.height = h
    self.frames = (self.image:getWidth()/w) - 1
    self.quad = {}
    self.color = color or {1, 1, 1}
    self.animation = anim or nil
    if anim and anim ~= false then
        self.anim_switch = false
        self.anim_count = 0
        self.anim_frames = (self.image:getHeight()/h) - 1
        self.anim_position = 0
        self.anim_repeat = 1
        self.anim_repeat_max = 1
    end

    if collision then
        self.collision = collision
        if collision == true then
            self.body = love.physics.newBody(world, self.x, self.y, "static")
            self.shape = love.physics.newRectangleShape(16,16)
            self.fixture = love.physics.newFixture(self.body, self.shape)
        end
    else
        self.collision = false
    end

    for i = 0, self.frames do
        self.quad[i] = g.newQuad(i*w, 0, w, h, self.image:getDimensions())
    end
end

function Model:destroy()
    self.fixture:destroy()
end

function Model:update(dt)
    if self.animation ~= nil and self.anim_switch == true then
        if self.anim_count >= 1 then
            if self.anim_position >= self.anim_frames then
                self.anim_position = 0
                if self.anim_repeat >= self.anim_repeat_max then
                    for i = 0, self.frames do
                        self.quad[i]:setViewport(i*self.width, self.anim_position*self.height, self.width, self.height)
                    end
                    self.anim_switch = false
                    return
                else
                    self.anim_repeat = self.anim_repeat + 1
                end
            else
                self.anim_position = self.anim_position + 1
            end

            for i = 0, self.frames do
                self.quad[i]:setViewport(i*self.width, self.anim_position*self.height, self.width, self.height)
            end

            self.anim_count = 0
        else
            self.anim_count = self.anim_count + (dt*self.animation.speed)
        end
    end
end

function Model:animate(qnt)
    self.anim_count = 0
    self.anim_position = 0
    self.anim_repeat = 1
    self.anim_repeat_max = qnt
    self.anim_switch = true
end

function Model:draw_shadow()
    if model_shadow_position < 0 then
        g.setColor(0,0,0, 0.1+(model_shadow_position*0.03))
    else
        g.setColor(0,0,0, 0.1-(model_shadow_position*0.03))
    end
    for i = 0, self.frames do
        g.draw(self.image, self.quad[i], self.x+model_shadow_render[i].dx, self.y+model_shadow_render[i].dy, 0, 1, 1, self.width/2, self.height/2)
    end
end

function Model:draw(camera_rad)
    g.setColor(self.color)
    for i = 0, self.frames do
        g.draw(self.image, self.quad[i], self.x+model_render[i].dx, self.y+model_render[i].dy, 0, 1, 1, self.width/2, self.height/2)
    end
end

function Model:getX() return self.x end
function Model:getY() return self.y end
function Model:getWidth() return self.width end
function Model:getHeight() return self.height end

return Model