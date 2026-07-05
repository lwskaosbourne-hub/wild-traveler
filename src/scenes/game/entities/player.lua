local Object = require "lib/classic"
local Player = Object:extend()

local shadow = g.newImage("assets/shadow.png")

function Player:new(x, y, map, sprite, body_id, eyes_id)
    self.hp_max = 20
    self.hp = self.hp_max/2
    self.energy_max = 20
    self.energy = self.energy_max
    self.x = get_x(x)
    self.y = get_y(y)
    self.w = 16
    self.h = 16
    self.dx = 0
    self.dy = 0
    self.rad = 0
    self.speed = 50
    self.map = map
    self.standCount = 1
    self.body_id = body_id
    self.eyes_id = eyes_id
    self.sprite = sprite
    self.body = Sprite("player", "assets/sprites/" .. sprite .. "/body" .. body_id .. ".png", 4, 8)
    self.eyes = Sprite("player", "assets/sprites/" .. sprite .. "/eyes" .. eyes_id .. ".png", 4, 8)
    self.state = 0
    self.movementsBlocked = false
    self.bodyPhy = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(6)
    self.fixture = love.physics.newFixture(self.bodyPhy, self.shape)
    self.is_swiming = false
    self.inventory = {
        max = 30,
        items = {}
    }
    for i = 1, self.inventory.max do
        self.inventory.items[i] = {id = 0}
    end
    self.inventory.items[1] = {id = 1}
    self.inventory.items[2] = {id = 2}
    self.inventory.items[3] = {id = 3}
    self.item_equiped = 2 -- ID of the item equiped
    self.attack = false
end

function Player:getMap()
    return self.map
end

function Player:update(dt, camera_rad)
    --self.sprite:update(dt, camera_rad)

    local cameraDeg = math.deg(camera_rad)
    local playerDeg = math.deg(self.rad)

    local relativeAngle = (cameraDeg - playerDeg) % 360

    self.body:setY(math.floor((relativeAngle + 22.5) / 45) % 8)
    self.eyes:setY(math.floor((relativeAngle + 22.5) / 45) % 8)

    -- Swiming:
    if map[earlyMap][get_coord_y(self.y)][get_coord_x(self.x)] >= 10 and map[earlyMap][get_coord_y(self.y)][get_coord_x(self.x)] <= 18 then
        self.body.y_divide = 1.6
        self.eyes.y_divide = 1.6
        self.is_swiming = true
        self.speed = 25
    else
        self.body.y_divide = 1
        self.eyes.y_divide = 1
        self.is_swiming = false
        self.speed = 50
    end

    -- Movements:
    if self.state == 0 and self.movementsBlocked == false then
        if k.isDown("w") then
            if k.isDown("a") then
                self.rad = camera_rad - math.rad(45)
            elseif k.isDown("d") then
                self.rad = camera_rad + math.rad(45)
            else
                self.rad = camera_rad
            end
        elseif k.isDown("s") then
            if k.isDown("a") then
                self.rad = camera_rad - math.rad(180-45)
            elseif k.isDown("d") then
                self.rad = camera_rad + math.rad(180-45)
            else
                self.rad = camera_rad + math.rad(180)
            end
        elseif k.isDown("d") then
            self.rad = camera_rad + math.rad(90)
        elseif k.isDown("a") then
            self.rad = camera_rad - math.rad(90)
        end

        if toutch_buttons.movement.is_pressed == true then
            self.rad = camera_rad + toutch_buttons.movement.angle + math.rad(90)
            self.standCount = 0
            self.eyes:setX(0)
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
        end
        
        if k.isDown("w") or k.isDown("s") or k.isDown("a") or k.isDown("d") or toutch_buttons.movement.is_pressed == true then
            self.dx = self.speed*math.cos(self.rad - math.rad(90))
            self.dy = self.speed*math.sin(self.rad - math.rad(90))
            self.bodyPhy:setPosition(self.bodyPhy:getX() + (self.dx* toutch_buttons.movement.dist)*dt, self.bodyPhy:getY() + self.dy*dt)
            self.x = self.bodyPhy:getX()
            self.y = self.bodyPhy:getY()
            self.bodyPhy:setAwake( true )

            self.body:anim(self.speed/5, dt)
            self.eyes:setX(self.body.index_x/self.body.frame_w)
        else
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyesAnim" .. self.eyes_id .. ".png")
            self.body:setX(0)
            if self.standCount >= 10 then
                if self.eyes.index_x >= self.eyes.frame_w*self.eyes.frames_x - self.eyes.frame_w then
                    self.eyes:setX(0)
                    self.standCount = 0
                else
                    self.eyes:anim(10, dt)
                end
            else
                self.eyes:setX(0)
                self.standCount = self.standCount + (dt*3)
            end
        end

        if self.attack == true then
            if danim:getFrame("player_attack") < 5 then
                danim:update("player_attack", 30, dt)
                self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
                self.body:setX(3)
                self.eyes:setX(3)
            else
                self.attack = false
            end
        end
    end
end

function Player:keypressed(key)
    if key == "w" or key == "s" or key == "a" or key == "d" then
        self.standCount = 0
        self.eyes:setX(0)
        self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
    end
    if key == "e" then
        self.attack = true
    end
end

function Player:draw_weapon(camera_rad)
    if self.item_equiped > 0 then
        local rotation = 0
        local x, y, dir = 0, 0, 1
        if self.body:get_frame_y() == 2 * 16 then
            x = -2
        end
        if self.body:get_frame_y() == 6 * 16 then
            dir = -1
            x = -2
        end
        g.setColor(1,1,1)
        if self.body:get_frame_x() == 0 or self.body:get_frame_x() == 32 then
            g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                self.bodyPhy:getX(), self.bodyPhy:getY(), camera_rad-rotation, dir, 1, (8/2)+x, 9+y)
        else
            g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                self.bodyPhy:getX(), self.bodyPhy:getY(), camera_rad-rotation, dir, 1, (8/2)+x, 8+y)
        end
    end
end

function Player:draw(camera_rad)
    if dev_gui == true then
        g.setColor(1,0,0,0.5)
        g.rectangle("line", get_x(get_coord_x(self.bodyPhy:getX())) - (tileSize/2), get_y(get_coord_y(self.bodyPhy:getY())) - (tileSize/2), tileSize, tileSize)
    end

    if self.attack == true then
        danim:draw("player_attack", self.bodyPhy:getX(), self.bodyPhy:getY(), self.rad, 1, 1, {1,1,1})
    end

    if self.body:get_frame_y() >= 2 * 16 and self.body:get_frame_y() <= 6 *16 then
        if self.is_swiming == false and self.attack == false then
            self:draw_weapon(camera_rad)
        end
    end

    g.setColor(1,1,1)
    g.draw(shadow, self.bodyPhy:getX(), self.bodyPhy:getY(), 0, 1, 1, shadow:getWidth()/2, shadow:getHeight()/2)
    self.body:draw(self.bodyPhy:getX(), self.bodyPhy:getY(), camera_rad)
    self.eyes:draw(self.bodyPhy:getX(), self.bodyPhy:getY(), camera_rad)

    if self.body:get_frame_y() >= 0 * 16 and self.body:get_frame_y() <= 1 *16 or self.body:get_frame_y() == 7 * 16 then
        if self.is_swiming == false and self.attack == false then
            self:draw_weapon(camera_rad)
        end
    end
end

function Player:atk()
    if self.attack == false then
        danim:setFrame("player_attack", 0)
        self.attack = true
    end
end

function Player:getPosition()
    return self.x, self.y
end

return Player