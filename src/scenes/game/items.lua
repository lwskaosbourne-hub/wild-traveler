items = {
    {name = "Sword", type="equipment", class="sword", index_x = 1, index_y = 0},
    {name = "Exe", type="equipment", class="exe", index_x = 4, index_y = 0},
    {name = "Healt Potion", type="potion", class="heal", index_x = 0, index_y = 1},
}

items[0] = {name = "Hand", type="equipment", class="punch", index_x = 0, index_y = 0}

items_img = g.newImage("assets/items.png")
for i = 1, #items do
    items[i].quad = g.newQuad(items[i].index_x*8, items[i].index_y*8, 8, 8, items_img:getDimensions())
end