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
        
        local dx = obj.src.x - cam_x
        local dy = obj.src.y - cam_y
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
        
        local depthA = -a.src.x * sin_cam + a.src.y * cos_cam
        local depthB = -b.src.x * sin_cam + b.src.y * cos_cam
        
        return depthA < depthB
    end)

    visible_n = visible_count
end

function renderScene(cam)
    for i = 1, #visible_objects do
        visible_objects[i].src:draw(cam:getAngle())
    end
end