local Object = require "lib/classic"
local Iten = Object:extend()

local shadow = g.newImage("assets/iten_shadow.png")

function Iten:new(iten_id, x, y, z)
    self.iten_id = iten_id
    self.x = x
    self.y = y
    self.z = z
    self.follow = false
    self.follow_speed = 100
    self.player_id_following = 0
    self.fall = true
    self.fall_count = 0
    self.fall_speed = 500

    self.player_get_iten = false
end

function Iten:update(dt)
    if self.fall == true then
        if self.fall_count >= 1 then
            if self.z <= 0 then
                self.z = 0
                self.fall = false
            else
                self.z = self.z - 2
                self.fall_count = 0
            end
        else
            self.fall_count = self.fall_count + (self.fall_speed*dt)
        end
    end

    if self.follow == false and self.fall == false then
        if self.z == 0 then
            for p = 1, #player do
                if distanceFrom(self.x, self.y, player[p].bodyPhy:getX(), player[p].bodyPhy:getY()) <= 16 then
                    if player[p].inventory.empty_spaces > 0 then
                        self.player_id_following = p
                        self.follow = true
                    end
                end
            end
        end
    end

    if self.player_id_following > 0 then
        if distanceFrom(self.x, self.y, player[self.player_id_following].bodyPhy:getX(), player[self.player_id_following].bodyPhy:getY()) >= 16 then
            self.follow = false
            self.player_id_following = 0
            return
        end
        local angle = math.atan2((player[self.player_id_following].bodyPhy:getY() - self.y), (player[self.player_id_following].bodyPhy:getX() - self.x))
        local dx = self.follow_speed * math.cos(angle)
        local dy = self.follow_speed * math.sin(angle)
        self.x = self.x + (dx*dt)
        self.y = self.y + (dy*dt)

        
        if distanceFrom(self.x, self.y, player[self.player_id_following].bodyPhy:getX(), player[self.player_id_following].bodyPhy:getY()) <= 4 then
            self.player_get_iten = true
        end
    end
end

function Iten:draw(camera_rad)
    g.setColor(1,1,1, lerp(1, 0, self.z/32))
    g.draw(shadow, self.x, self.y, 0, 1, 1, 2, 2)
    g.setColor(1,1,1)
    g.draw(items_img, items[self.iten_id].quad, self.x+model_render[self.z].dx, self.y+model_render[self.z].dy, camera_rad, 1, 1, 4, 8)
end

return Iten