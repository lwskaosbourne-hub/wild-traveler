items = {{name = "Sword",       type="equipment", class="sword",   index_x = 1, index_y = 0, maximum_coupling = 1,  use_value = 0,   desc = "One handed weapon."},
        {name = "Exe",          type="equipment", class="exe",     index_x = 4, index_y = 0, maximum_coupling = 1,  use_value = 0,   desc = "One handed weapon."},
        {name = "Pickaxe",      type="equipment", class="pickaxe", index_x = 3, index_y = 1, maximum_coupling = 1,  use_value = 0,   desc = "One handed weapon."},
        {name = "Healt Potion", type="heal",      class="potion",  index_x = 0, index_y = 1, maximum_coupling = 99, use_value = 10,  desc = "Heals 10 points of life."},
        {name = "Apple",        type="heal",      class="food",    index_x = 1, index_y = 1, maximum_coupling = 99, use_value = 10,  desc = "Heals 10 points of energy."},
        {name = "Wood",         type="material",  class="wood",    index_x = 2, index_y = 1, maximum_coupling = 99, use_value = 0,   desc = "Used into constructions and crafts."},
        {name = "Rock",         type="material",  class="rock",    index_x = 4, index_y = 1, maximum_coupling = 99, use_value = 0,   desc = "Used into constructions and crafts."},
        {name = "Lamp",         type="secondary", class="lamp",    index_x = 0, index_y = 2, maximum_coupling = 1,  use_value = 0,   desc = "A simple light lamp."},
}

items[0] = {name = "Hand", type="equipment", class="punch", index_x = 0, index_y = 0, maximum_coupling = 1}

items_img = g.newImage("assets/items.png")
for i = 1, #items do
    items[i].quad = g.newQuad(items[i].index_x*8, items[i].index_y*8, 8, 8, items_img:getDimensions())
end