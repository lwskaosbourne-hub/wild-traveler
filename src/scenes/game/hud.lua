local hud_base = g.newImage("assets/hud.png")
local hp_bar = g.newImage("assets/hp_bar.png")
local energy_bar = g.newImage("assets/energy_bar.png")

function draw_hud()
    local hpBarW = (player[player_id].hp*1/player[player_id].hp_max) * zoom
    local energyBarW = (player[player_id].energy*1/player[player_id].energy_max) * zoom

    g.setColor(1,1,1)
    g.draw(hud_base, zoom, zoom, 0, zoom, zoom)

    --g.setColor(1,1,1,0.8)
    g.draw(hp_bar, zoom + (zoom*11), zoom + (zoom*2), 0, hpBarW, zoom)
    g.draw(energy_bar, zoom + (zoom*11), zoom + (zoom*11), 0, energyBarW, zoom)

    local minutes_calc = math.floor(((time.hour-math.floor(time.hour))*60/1))
    local minutes = 0
    local hour = 0
    if math.floor(time.hour) < 10 then
        hour = "0" .. math.floor(time.hour)
    else
        hour = math.floor(time.hour)
    end
    if minutes_calc < 10 then
        minutes = "0" .. minutes_calc
    else
        minutes = minutes_calc
    end
    g.setColor(1,1,1)
    g.print(hour..":"..minutes, zoom + (zoom*10), zoom + (zoom*19), 0, zoom, zoom)
end