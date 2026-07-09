local light_system = {}

light_system.lights = {}
light_system.ambient_color = {1,1,1,0} 

function light_system.load(w, h)
    light_system.canvas = love.graphics.newCanvas(w, h, {format = "rgba8"})
    light_system.image = love.graphics.newImage("assets/light.png")
end

function light_system.addLight(x, y, radius, color, intensity)
    local nova_luz = {
        x = x,
        y = y,
        radius = radius or 300,
        color = color or {1, 1, 1},
        intensity = intensity or 1
    }
    table.insert(light_system.lights, nova_luz)
    return nova_luz 
end

function light_system.draw(cam)
    g.setCanvas(light_system.canvas)
    g.clear(light_system.ambient_color)
    
    g.setBlendMode("add", "alphamultiply")
    
    local desenhar_luzes = function()
        for i = 1, #light_system.lights do
            local luz = light_system.lights[i]
            
            g.setColor(luz.color[1], luz.color[2], luz.color[3], luz.intensity * 0.5)
            local scale = luz.radius / light_system.image:getWidth()
            
            g.draw(light_system.image, luz.x, luz.y, 0, scale, scale, light_system.image:getWidth()/2, light_system.image:getHeight()/2)
        end
    end
    
    if cam then
        cam:draw(desenhar_luzes)
    else
        desenhar_luzes()
    end
    
    g.setCanvas()
    
    g.setBlendMode("multiply", "premultiplied")
    g.setColor(1, 1, 1, 1)
    
    g.draw(light_system.canvas, 0, 0)
    
    g.setBlendMode("alpha")
end

function light_system.setAmbientColor(r, g, b, a)
    light_system.ambient_color[1] = r
    light_system.ambient_color[2] = g
    light_system.ambient_color[3] = b
    light_system.ambient_color[4] = a or 1
end

return light_system