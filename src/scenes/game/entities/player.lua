local Object = require "lib/classic"
local Player = Object:extend()

local shadow = g.newImage("assets/shadow.png")

function Player:new(name, x, y, map, sprite, body_id, eyes_id)
    self.name = name
    self.name_text = g.newText(font, name)
    self.hp_max = 100
    self.hp = self.hp_max
    self.energy_max = 100
    self.energy = self.energy_max
    self.auto_healing = 1
    self.x = get_x(x)
    self.y = get_y(y)
    self.z = 0
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
    self.lamp = Sprite("player", "assets/sprites/lamp.png", 4, 8)
    self.state = 0 -- 0 = Static, 1 = Walking, 2 = Attack, 3 = Sit
    self.movementsBlocked = false
    self.bodyPhy = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(6)
    self.fixture = love.physics.newFixture(self.bodyPhy, self.shape)
    self.is_swiming = false
    self.inventory = {
        max = 30,
        items = {}
    }
    self.inventory.empty_spaces = self.inventory.max - 4
    for i = 1, self.inventory.max do
        self.inventory.items[i] = {id = 0, n = 1}
    end
    self.inventory.items[1] = {id = 1, n = 1}
    self.inventory.items[2] = {id = 2, n = 1}
    self.inventory.items[3] = {id = 3, n = 1}
    self.inventory.items[4] = {id = 8, n = 1}
    self.item_equiped = 2 -- ID of the item equiped
    self.secondary_item_equiped = 0
    self.interactive_point = {x = 0, y = 0}

    self.light = light_system.addLight(self.bodyPhy:getX(), self.bodyPhy:getY(), 100, {1,0.5,0}, 0)
    self.light_dir = 0
    self.light_speed = 10
    self.light_switch = false

    self.color = {1, 1, 1, 1}
    self.enter_into_cabin = false
    self.siting_on_a_chair = {state = 0, id = 0}

    self.teleport_target = {x = 0, y = 0}

    self.is_walking = false

    self.hotkey = 0
end

function Player:addBody(x, y)
    self.bodyPhy = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newCircleShape(6)
    self.fixture = love.physics.newFixture(self.bodyPhy, self.shape)
end

function Player:addIten(id)
    local last_space = 0
    
    for i = 1, self.inventory.max do
        if self.inventory.items[i].id == id and self.inventory.items[i].n < items[id].maximum_coupling then
            self.inventory.items[i].n = self.inventory.items[i].n + 1
            if self.inventory.items[i].n == items[id].maximum_coupling then
                self.inventory.empty_spaces = self.inventory.empty_spaces - 1
            end
            break
        elseif last_space == 0 then
            if self.inventory.items[i].id == 0 then last_space = i end
        end

        if i == self.inventory.max then
            self.inventory.items[last_space].id = id
            self.inventory.items[last_space].n = 1
            self.inventory.empty_spaces = self.inventory.empty_spaces - 1
            break
        end
    end
end

function Player:remove_iten(id, n)
    if self.inventory.items[id].n - n <= 0 then
        self.inventory.empty_spaces = self.inventory.empty_spaces + 1
        self.inventory.items[id] = {id = 0, n = 1}
    else
        self.inventory.items[id].n = self.inventory.items[id].n - n
    end
end

function Player:getMap()
    return self.map
end

function Player:update(dt, camera_rad)
    if self.secondary_item_equiped > 0 and items[self.inventory.items[self.secondary_item_equiped].id].class == "lamp" then
        self.lamp:setX(self.body.index_x/self.body.frame_w)
        self.light_switch = true
        self.light.intensity = 1
    else
        self.light_switch = false
        self.light.intensity = 0
    end

    if self.energy >= self.energy_max - (self.energy_max/5) and self.hp < self.hp_max then
        if self.hp >= self.hp_max then
            self.hp = self.hp_max
        else
            self.hp = self.hp + (self.auto_healing*dt)
        end
    end

    -- Hotkeys:
    if self.hotkey > 0 then
        if self.inventory.items[self.hotkey].id > 0 then
            if items[self.inventory.items[self.hotkey].id].type == "equipment" then
                if self.item_equiped == self.hotkey then
                    self.item_equiped = 0
                    game_message("* You unequiped "..items[self.inventory.items[self.hotkey].id].name, {1,0,0})
                else
                    self.item_equiped = self.hotkey
                    game_message("* You have equiped "..items[self.inventory.items[self.hotkey].id].name)
                end
            elseif items[self.inventory.items[self.hotkey].id].type == "secondary" then
                if self.secondary_item_equiped == self.hotkey then
                    self.secondary_item_equiped = 0
                    game_message("* You unequiped "..items[self.inventory.items[self.hotkey].id].name, {1,0,0})
                else
                    self.secondary_item_equiped = self.hotkey
                    game_message("* You have equiped "..items[self.inventory.items[self.hotkey].id].name)
                end
            end
        end
        self.hotkey = 0
    end

    if self.siting_on_a_chair.state == 1 then
        if distanceFrom(self.bodyPhy:getX(), self.bodyPhy:getY(), objects[self.siting_on_a_chair.id].x, objects[self.siting_on_a_chair.id].y) <= 4 then
            self.bodyPhy:setPosition(objects[self.siting_on_a_chair.id].x, objects[self.siting_on_a_chair.id].y)
            self.body:setX(0)
            self.body:setTexture("assets/sprites/" .. self.sprite .. "/body" .. self.body_id .. "sit.png")
            self.state = 3
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyesAnim" .. self.eyes_id .. ".png")
            self.eyes:setX(0)
            self.standCount = 0
            self.z = objects[self.siting_on_a_chair.id].src.frames
            self.rad = self.rad - math.rad(180)
            self.is_walking = false
            self.siting_on_a_chair.state = 2
        else
            self.is_walking = true
            self.rad = math.atan2((objects[self.siting_on_a_chair.id].y - self.bodyPhy:getY()), (objects[self.siting_on_a_chair.id].x - self.bodyPhy:getX())) + math.rad(90)
            self:moveFoward(dt, 30)
        end
    elseif self.siting_on_a_chair.state == 2 then
        if m.isDown(2) then
            self.z = 0
            self.body:setX(0)
            self.body:setTexture("assets/sprites/" .. self.sprite .. "/body" .. self.body_id .. ".png")
            self.siting_on_a_chair.state = 3
        end
    elseif self.siting_on_a_chair.state == 3 then
        if distanceFrom(self.bodyPhy:getX(), self.bodyPhy:getY(), objects[self.siting_on_a_chair.id].x, objects[self.siting_on_a_chair.id].y) > 12 then
            self:create_fixture()
            self.body:setX(0)
            self.eyes:setX(0)
            self.movementsBlocked = false
            self.is_walking = false
            self.siting_on_a_chair.id = 0
            self.siting_on_a_chair.state = 0
        else
            self.is_walking = true
            self:moveFoward(dt, 30)
        end
    end

    if self.light ~= nil then
        self.light.x, self.light.y = self.bodyPhy:getPosition()

        if self.light_switch == true then
            if self.light_dir == 0 then
                if self.light.radius >= 120 then
                    self.light_dir = 1
                else
                    self.light.radius = self.light.radius + (self.light_speed*dt)
                end
            else
                if self.light.radius <= 100 then
                    self.light_dir = 0
                else
                    self.light.radius = self.light.radius - (self.light_speed*dt)
                end
            end
        end
    end

    local cameraDeg = math.deg(camera_rad)
    local playerDeg = math.deg(self.rad)

    local relativeAngle = (cameraDeg - playerDeg) % 360

    self.body:setY(math.floor((relativeAngle + 22.5) / 45) % 8)
    self.eyes:setY(math.floor((relativeAngle + 22.5) / 45) % 8)
    self.lamp:setY(math.floor((relativeAngle + 22.5) / 45) % 8)

    -- Swiming:
    if map[earlyMap].grid[get_coord_y(self.y)][get_coord_x(self.x)] >= 10 and map[earlyMap].grid[get_coord_y(self.y)][get_coord_x(self.x)] <= 18 then
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
    if self.movementsBlocked == false or self.state == 3 then
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
    end

    
        if toutch_buttons.movement.is_pressed == true and self.movementsBlocked == false then
            self.rad = camera_rad + toutch_buttons.movement.angle + math.rad(90)
            self.standCount = 0
            self.eyes:setX(0)
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
        end
    
    if k.isDown("w") or k.isDown("s") or k.isDown("a") or k.isDown("d") or toutch_buttons.movement.is_pressed == true and self.siting_on_a_chair.state == 0 then
        if self.movementsBlocked == false then
            self.state = 1
            local run_spd = 0
            if k.isDown("lshift") then run_spd = 20 end
            self.dx = (self.speed+run_spd)*math.cos(self.rad - math.rad(90))
            self.dy = (self.speed+run_spd)*math.sin(self.rad - math.rad(90))
            self.bodyPhy:setPosition(self.bodyPhy:getX() + (self.dx* toutch_buttons.movement.dist)*dt, self.bodyPhy:getY() + self.dy*dt)
            self.x = self.bodyPhy:getX()
            self.y = self.bodyPhy:getY()
            self.bodyPhy:setAwake( true )
            if self.body.index_x == self.body.frame_w * 3 then
                self.energy = self.energy - 0.01
            end
            self.interactive_point.x = self.x + (10*math.cos(self.rad - math.rad(90)))
            self.interactive_point.y = self.y + (10*math.sin(self.rad - math.rad(90)))
            self.body:anim((self.speed+run_spd)/5, dt)
            self.eyes:setX(self.body.index_x/self.body.frame_w)
        end
    elseif self.is_walking == false and self.state ~= 2 then
        if self.state ~= 3 then
            self.state = 0
        end
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

    if self.state == 2 then
        if danim:getFrame("player_attack") < 5 then
            danim:update("player_attack", 20, dt)
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
            self.body:setX(3)
            self.eyes:setX(3)
        else
            self.movementsBlocked = false
            self.state = 0
        end
    end
end

function Player:moveFoward(dt, speed)
    self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
    self.state = 1
    local run_spd = 0
    self.dx = (speed+run_spd)*math.cos(self.rad - math.rad(90))
    self.dy = (speed+run_spd)*math.sin(self.rad - math.rad(90))
    self.bodyPhy:setPosition(self.bodyPhy:getX() + (self.dx* toutch_buttons.movement.dist)*dt, self.bodyPhy:getY() + self.dy*dt)
    self.x = self.bodyPhy:getX()
    self.y = self.bodyPhy:getY()
    self.bodyPhy:setAwake( true )
    self.interactive_point.x = self.x + (10*math.cos(self.rad - math.rad(90)))
    self.interactive_point.y = self.y + (10*math.sin(self.rad - math.rad(90)))
    self.body:anim((speed+run_spd)/5, dt)
    self.eyes:setX(self.body.index_x/self.body.frame_w)
end

function Player:keypressed(key)
    if key == "w" or key == "s" or key == "a" or key == "d" and self.siting_on_a_chair.state == 0 then
        self.standCount = 0
        self.eyes:setX(0)
        self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyes" .. self.eyes_id .. ".png")
    end
    --if key == "q" then
    --    if self.light_switch == true then
    --        self.light.intensity = 0
    --        self.light_switch = false
    --    else
    --        self.light.intensity = 1
    --        self.light_switch = true
    --    end
    --end
    if key == "e" and self.siting_on_a_chair.state == 0 then
        if self.state == 3 then
            self.movementsBlocked = false
            self.body:setX(0)
            self.body:setTexture("assets/sprites/" .. self.sprite .. "/body" .. self.body_id .. ".png")
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyesAnim" .. self.eyes_id .. ".png")
            self.eyes:setX(0)
            self.state = 0
        else
            self.movementsBlocked = true
            self.body:setX(0)
            self.body:setTexture("assets/sprites/" .. self.sprite .. "/body" .. self.body_id .. "sit.png")
            self.eyes:setTexture("assets/sprites/" .. self.sprite .. "/eyesAnim" .. self.eyes_id .. ".png")
            self.eyes:setX(0)
            self.state = 3
        end
    end

    -- Hotkeys input:
    if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or 
        key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
            local hk = tonumber(key)
            if key == "0" then hk = 10 end
            self.hotkey = hk
    end
end

function Player:destroy_fixture()
    self.fixture:destroy()
end

function Player:create_fixture()
    self.fixture = love.physics.newFixture(self.bodyPhy, self.shape)
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
        g.setColor(self.color)
        if self.state == 3 then
            if self.body:get_frame_x() == 0 or self.body:get_frame_x() == 32 then
                g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                    self.bodyPhy:getX()+model_render[self.z].dx-model_render[2].dx, 
                    self.bodyPhy:getY()+model_render[self.z].dy-model_render[2].dy, 
                    camera_rad-rotation, dir, 1, (8/2)+x, 9+y)
            else
                g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                    self.bodyPhy:getX()+model_render[self.z].dx-model_render[2].dx, 
                    self.bodyPhy:getY()+model_render[self.z].dy-model_render[2].dy, 
                    camera_rad-rotation, dir, 1, (8/2)+x, 8+y)
            end
        else
            if self.body:get_frame_x() == 0 or self.body:get_frame_x() == 32 then
                g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                    self.bodyPhy:getX()+model_render[self.z].dx, self.bodyPhy:getY()+model_render[self.z].dy, camera_rad-rotation, dir, 1, (8/2)+x, 9+y)
            else
                g.draw(items_img, items[self.inventory.items[self.item_equiped].id].quad, 
                    self.bodyPhy:getX()+model_render[self.z].dx, self.bodyPhy:getY()+model_render[self.z].dy, camera_rad-rotation, dir, 1, (8/2)+x, 8+y)
            end
        end
    end
end

function Player:draw(camera_rad)
    if dev_gui == true then
        g.setColor(1,1,1,0.5)
        g.rectangle("line", get_x(get_coord_x(self.interactive_point.x)) - (tileSize/2), get_y(get_coord_y(self.interactive_point.y)) - (tileSize/2), tileSize, tileSize)

        g.setColor(0,0,0)
        g.circle("fill", self.interactive_point.x, self.interactive_point.y, 0.5)
    end

    if self.state == 2 then
        g.setColor(self.color)
        danim:draw("player_attack", self.bodyPhy:getX(), self.bodyPhy:getY(), self.rad, 1, 1, self.color)
    end
    
    if self.siting_on_a_chair.state ~= 2 then
        g.setColor(self.color)
        g.draw(shadow, self.bodyPhy:getX(), self.bodyPhy:getY(), 0, 1, 1, shadow:getWidth()/2, shadow:getHeight()/2)
    end

    if self.body:get_frame_y() >= 2 * 16 and self.body:get_frame_y() <= 6 *16 then
        if self.is_swiming == false and self.state ~= 2 then
            self:draw_weapon(camera_rad)
        end
    end
    
    self.body:draw(self.bodyPhy:getX()+model_render[self.z].dx, self.bodyPhy:getY()+model_render[self.z].dy, camera_rad, self.color)
    if self.state == 3 then
        self.eyes:draw(self.bodyPhy:getX()+model_render[self.z].dx-model_render[2].dx, 
                        self.bodyPhy:getY()+model_render[self.z].dy-model_render[2].dy, 
                        camera_rad, self.color)
    else
        self.eyes:draw(self.bodyPhy:getX()+model_render[self.z].dx, self.bodyPhy:getY()+model_render[self.z].dy, camera_rad, self.color)
    end

    if self.secondary_item_equiped > 0 and items[self.inventory.items[self.secondary_item_equiped].id].class == "lamp" and self.is_swiming == false then
        if self.state == 3 then
            self.lamp:draw(self.bodyPhy:getX()+model_render[self.z].dx-model_render[2].dx, 
                            self.bodyPhy:getY()+model_render[self.z].dy-model_render[2].dy, 
                            camera_rad, self.color)
        else
            self.lamp:draw(self.bodyPhy:getX()+model_render[self.z].dx, self.bodyPhy:getY()+model_render[self.z].dy, camera_rad, self.color)
        end
    end

    if self.body:get_frame_y() >= 0 * 16 and self.body:get_frame_y() <= 1 *16 or self.body:get_frame_y() == 7 * 16 then
        if self.is_swiming == false and self.state ~= 2 then
            self:draw_weapon(camera_rad)
        end
    end
end

function Player:atk()
    if self.state ~= 2 and self.movementsBlocked == false then
        danim:setFrame("player_attack", 0)
        self.movementsBlocked = true
        self.state = 2
    end
end

function Player:getPosition()
    return self.x, self.y
end

return Player