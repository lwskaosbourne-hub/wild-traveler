-- 1. A Função Mágica: Lerp (Linear Interpolation)
-- Ela encontra o valor exato entre 'a' e 'b' baseado em uma porcentagem 't' (de 0.0 a 1.0)
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- 2. A Tabela (Paleta) de Horários
-- Adicione os horários que quiser! Só lembre de manter a ordem crescente das horas,
-- e o último horário (24) deve ter a mesma cor do primeiro (0) para o loop ser suave.
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

-- 3. A Função que atualiza a cor
function updateDayNightCycle(current_hour)
    local start_node
    local end_node

    -- Encontra entre quais dois horários nós estamos agora
    for i = 1, #day_cycle - 1 do
        if current_hour >= day_cycle[i].hour and current_hour < day_cycle[i+1].hour then
            start_node = day_cycle[i]
            end_node = day_cycle[i+1]
            break
        end
    end

    -- Segurança caso não encontre (fallback)
    if not start_node then return end

    -- Descobre quantos porcento do caminho já andamos entre o horário inicial e o final
    local hour_range = end_node.hour - start_node.hour
    local time_passed = current_hour - start_node.hour
    local t = time_passed / hour_range -- Isso gera um valor de 0.0 até 1.0

    -- Mistura as cores Vermelha, Verde, Azul e Alpha
    local r = lerp(start_node.color[1], end_node.color[1], t)
    local g = lerp(start_node.color[2], end_node.color[2], t)
    local b = lerp(start_node.color[3], end_node.color[3], t)
    local a = lerp(start_node.color[4], end_node.color[4], t)

    -- Atualiza no sistema de luz que criamos na resposta anterior
    light_system.setAmbientColor(r, g, b, a)
end