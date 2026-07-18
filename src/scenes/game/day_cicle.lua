local day_cycle = {
    {hour = 0,  color = {0.05, 0.05, 0.15, 1}}, -- Meia-noite (Azul muito escuro)
    {hour = 5,  color = {0.05, 0.05, 0.20, 1}}, -- Fim da madrugada
    {hour = 6,  color = {0.40, 0.20, 0.25, 1}}, -- Amanhecer (Avermelhado)
    {hour = 8,  color = {1.00, 1.00, 1.00, 1}}, -- Manhã (Luz total, apaga a escuridão)
    {hour = 17, color = {1.00, 1.00, 1.00, 1}}, -- Fim de tarde
    {hour = 18, color = {0.70, 0.35, 0.15, 1}}, -- Pôr do sol (Laranja)
    {hour = 20, color = {0.10, 0.10, 0.25, 1}}, -- Início da noite (Azul escuro)
    {hour = 23, color = {0.05, 0.05, 0.15, 1}}  -- Fim do dia (Fecha o ciclo)
}

local start_node
local end_node

function updateDayNightCycle(current_hour)
    for i = 1, #day_cycle - 1 do
        if current_hour >= day_cycle[i].hour and current_hour < day_cycle[i+1].hour then
            start_node = i
            end_node = i+1
            break
        end
    end

    if not start_node then return end

    local t = (current_hour - day_cycle[start_node].hour) / (day_cycle[end_node].hour - day_cycle[start_node].hour)

    -- Mistura as cores Vermelha, Verde, Azul e Alpha
    light_system.setAmbientColor(
        lerp(day_cycle[start_node].color[1], day_cycle[end_node].color[1], t), 
        lerp(day_cycle[start_node].color[2], day_cycle[end_node].color[2], t), 
        lerp(day_cycle[start_node].color[3], day_cycle[end_node].color[3], t), 
        lerp(day_cycle[start_node].color[4], day_cycle[end_node].color[4], t)
    )
end