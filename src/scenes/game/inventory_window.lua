inventory_window = false
inventory_window_x = g.getWidth()/2
inventory_window_y = g.getHeight()/2

inventory_buttons = {
    equip = {x = 0, y = 0, w = 0, h = 0, img = g.newImage("assets/inventory_button.png")}
}

local base_img = g.newImage("assets/inventory_window.png")
local back_img = g.newImage("assets/inventory_window_back.png")
local items_base_img = g.newImage("assets/inventory_window_itemsBase.png")

local selected_box = 0
local boxes = {}

function inventory_set()
    if dispositive == "pc" then
        inventory_window_size = zoom*0.5
    elseif dispositive == "android" then
        inventory_window_size = zoom
    end

    inventory_buttons.equip.x = inventory_window_x + (inventory_window_size*40)
    inventory_buttons.equip.y = inventory_window_y + (inventory_window_size*42)
    inventory_buttons.equip.w = inventory_buttons.equip.img:getWidth()*inventory_window_size
    inventory_buttons.equip.h = inventory_buttons.equip.img:getHeight()*inventory_window_size

    for i = 1, player[player_id].inventory.max do
        local boxes_count = 0

        if i >= 11 and i <= 20 then boxes_count = 1
        elseif i >= 21 and i <= 30 then boxes_count = 2
        elseif i >= 31 and i <= 40 then boxes_count = 3
        elseif i >= 41 and i <= 50 then boxes_count = 4 end
    
        boxes[i] = {
            x = (inventory_window_x - (base_img:getWidth()*inventory_window_size)/2 - (2*inventory_window_size)) + (i*(14*inventory_window_size)) - (boxes_count*(140*inventory_window_size)),
            y = inventory_window_y - (8*inventory_window_size) + (boxes_count*14)*inventory_window_size,
            w = items_base_img:getWidth()*inventory_window_size, h = items_base_img:getHeight()*inventory_window_size
        }
    end
end

function inventory_update(dt)
    -- Selected item check:
    if m.isDown(1) then
        for i = 1, #boxes do
            if m.getX() >= boxes[i].x - boxes[i].w/2 and m.getX() <= boxes[i].x + boxes[i].w/2 and
            m.getY() >= boxes[i].y - boxes[i].h/2 and m.getY() <= boxes[i].y + boxes[i].h/2 then
                -- Change the selected box/item ID:
                selected_box = i
            end
        end
    end
end

function inventory_buttonpressed(x, y, key)
    local key_pressed = 1
    if dispositive == "pc" then key_pressed = key end

    if key_pressed == 1 then
        if x >= inventory_buttons.equip.x and x <= inventory_buttons.equip.x + inventory_buttons.equip.w and
        y >= inventory_buttons.equip.y and y <= inventory_buttons.equip.y + inventory_buttons.equip.h then
            -- Equip/use item by the selected_box ID:
            if selected_box > 0 and player[player_id].inventory.items[selected_box].id > 0 and items[player[player_id].inventory.items[selected_box].id].type == "equipment" then
                -- Equipments:
                if player[player_id].item_equiped == selected_box then
                    player[player_id].item_equiped = 0
                else
                    player[player_id].item_equiped = selected_box
                end
            elseif selected_box > 0 and player[player_id].inventory.items[selected_box].id > 0 and items[player[player_id].inventory.items[selected_box].id].type == "potion" then
                -- Potions:
            end
        end
    end
end

function inventory_draw()
    -- Window base:
    g.setColor(1,1,1, 0.8)
    g.draw(back_img, inventory_window_x, inventory_window_y, 0, inventory_window_size, inventory_window_size, back_img:getWidth()/2, back_img:getHeight()/2)
    g.setColor(1,1,1)
    g.draw(base_img, inventory_window_x, inventory_window_y, 0, inventory_window_size, inventory_window_size, base_img:getWidth()/2, base_img:getHeight()/2)

    -- Item Boxes:
    for i = 1, #boxes do
        if selected_box == i then
            g.setColor(0,0,0,0.5)
        else
            g.setColor(1,1,1)
        end
        g.draw(items_base_img, boxes[i].x, boxes[i].y, 0, inventory_window_size, inventory_window_size, items_base_img:getWidth()/2, items_base_img:getHeight()/2)
        
        if player[player_id].inventory.items[i].id > 0 then
            g.setColor(1,1,1)
            g.draw(items_img, items[player[player_id].inventory.items[i].id].quad, 
                boxes[i].x, boxes[i].y, 0, inventory_window_size, inventory_window_size, 4, 4)
        end

        if i == player[player_id].item_equiped then
            g.setColor(1,1,1)
            g.print("E", boxes[i].x + (inventory_window_size*2), boxes[i].y + (inventory_window_size), 0, inventory_window_size/2, inventory_window_size/2)
        end
    end

    -- Item Info:
    if selected_box > 0 and player[player_id].inventory.items[selected_box].id > 0 then
        local x = inventory_window_x - (inventory_window_size*68)
        local y = inventory_window_y + (inventory_window_size*29)
        g.setColor(1,0,0)
        g.print(items[player[player_id].inventory.items[selected_box].id].name .. ":", x, y, 0, inventory_window_size/2, inventory_window_size/2)
    end

	g.setColor(1,1,1)
    g.draw(inventory_buttons.equip.img, inventory_buttons.equip.x, inventory_buttons.equip.y, 0, inventory_window_size, inventory_window_size)
    if selected_box > 0 and player[player_id].inventory.items[selected_box].id > 0 and items[player[player_id].inventory.items[selected_box].id].type == "equipment" then
        g.setColor(0,0,0)
        if player[1].item_equiped == selected_box then
            g.print("UNEQUIP", inventory_buttons.equip.x + inventory_window_size, inventory_buttons.equip.y + (inventory_window_size*1.5), 0, inventory_window_size/1.8, inventory_window_size/1.8)
        else
            g.print("EQUIP", inventory_buttons.equip.x + (inventory_window_size*2.5), inventory_buttons.equip.y + inventory_window_size, 0, inventory_window_size/1.5, inventory_window_size/1.5)
        end
    elseif selected_box > 0 and player[player_id].inventory.items[selected_box].id > 0 and items[player[player_id].inventory.items[selected_box].id].type == "potion" then
        g.setColor(0,0,0)
        g.print("USE", inventory_buttons.equip.x + (inventory_window_size*4.5), inventory_buttons.equip.y + inventory_window_size, 0, inventory_window_size/1.5, inventory_window_size/1.5)
    else
        g.setColor(0,0,0,0.5)
        g.print("...", inventory_buttons.equip.x + (inventory_window_size*7.5), inventory_buttons.equip.y + inventory_window_size, 0, inventory_window_size/1.5, inventory_window_size/1.5)
    end
end