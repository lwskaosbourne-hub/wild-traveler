local hud_base = g.newImage("assets/hud.png")
local hp_bar = g.newImage("assets/hp_bar.png")
local energy_bar = g.newImage("assets/energy_bar.png")

local hud_scale = 0

function update_hud(dt)
    hud_scale = zoom*gui_scale
end

function draw_hud()
    local hpBarW = (player[player_id].hp*1/player[player_id].hp_max) * hud_scale
    local energyBarW = (player[player_id].energy*1/player[player_id].energy_max) * hud_scale

    g.setColor(1,1,1)
    g.draw(hud_base, hud_scale, hud_scale, 0, hud_scale, hud_scale)

    --g.setColor(1,1,1,0.8)
    g.draw(hp_bar, hud_scale + (hud_scale*11), hud_scale + (hud_scale*2), 0, hpBarW, hud_scale)
    g.draw(energy_bar, hud_scale + (hud_scale*11), hud_scale + (hud_scale*11), 0, energyBarW, hud_scale)

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
    g.print(hour..":"..minutes, hud_scale + (hud_scale*10), hud_scale + (hud_scale*19), 0, hud_scale/1.5, hud_scale/1.5)
end