local Object = require "lib/classic"
local Model = Object:extend()

function Model:new(image, x, y, w, h, collision, color)
    self.image = image
    self.x = get_x(x)
    self.y = get_y(y)
    self.width = w
    self.height = h
    self.frames = self.image:getWidth()/w
    self.quad = {}
    self.color = color or {1, 1, 1}

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

function Model:update(dt)
    if self.collision == true then
        self.body:setAwake( true )
    end
end

function Model:draw_shadow()
    for i = 0, self.frames do
        if model_shadow_position < 0 then
            g.setColor(0,0,0, 0.1+(model_shadow_position*0.03))
        else
            g.setColor(0,0,0, 0.1-(model_shadow_position*0.03))
        end
        g.draw(self.image, self.quad[i], self.x+model_shadow_render[i].dx, self.y+model_shadow_render[i].dy, 0, 1, 1, self.width/2, self.height/2)
    end
end

function Model:draw(camera_rad)
    for i = 0, self.frames do
        g.setColor(self.color)
        g.draw(self.image, self.quad[i], self.x+model_render[i].dx, self.y+model_render[i].dy, 0, 1, 1, self.width/2, self.height/2)
    end
end

function Model:getX() return self.x end
function Model:getY() return self.y end
function Model:getWidth() return self.width end
function Model:getHeight() return self.height end

return Model