function renderLoad()
    view_radius = 120 / camera_distance
end

visible_objects = {}
visible_n = 0

function renderUpdate(cam, objects)
    local visible_count = 0
    
    local cam_x, cam_y = cam:getPosition() 
    
    for i = 1, #objects do
        local obj = objects[i]
        
        local dx = obj.x - cam_x
        local dy = obj.y - cam_y
        local distance_sq = (dx * dx) + (dy * dy) 
        
        local obj_margin = 64 
        local cull_distance = view_radius + obj_margin
        
        if distance_sq < (cull_distance * cull_distance) then
            visible_count = visible_count + 1
            visible_objects[visible_count] = obj
        end
    end

    table.sort(visible_objects, function(a, b)
        local angle = cam:getAngle()
        local sin_cam = math.sin(angle)
        local cos_cam = math.cos(angle)
        
        local depthA = -a.x * sin_cam + a.y * cos_cam
        local depthB = -b.x * sin_cam + b.y * cos_cam
        
        return depthA < depthB
    end)

    visible_n = visible_count
end

local tree_shadow = g.newImage("assets/tree_shadow.png")

function renderScene(cam)
    for i = 1, #visible_objects do
        if visible_objects[i].type == "player" then
            visible_objects[i].src:draw(cam:getAngle())
        else
            if visible_objects[i].type == "tree" then
                if time.hour >= 6 and time.hour < 12 then
                    g.setColor(1,1,1, (time.hour-6)/6)
                    g.draw(tree_shadow, visible_objects[i].x, visible_objects[i].y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                elseif time.hour >= 12 and time.hour < 18 then
                    g.setColor(1,1,1, 1-(time.hour-12)/6)
                    g.draw(tree_shadow, visible_objects[i].x, visible_objects[i].y, 0, 1, 1, tree_shadow:getWidth()/2, tree_shadow:getHeight()/2)
                end
            end
            visible_objects[i].src:draw(visible_objects[i].x, visible_objects[i].y, visible_objects[i].z, visible_objects[i].rad)
        end
    end
end