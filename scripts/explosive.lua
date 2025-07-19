require "explode_lib:explode"

function on_interact(x, y, z, playerid)
    local strenght = 35
    local checkDurability = false
    local pushEntity = true
    local recursiveBlocks = {}
    recursiveBlocks["explode_lib:explosive"] = {strenght, checkDurability, pushEntity, "cpy", "explode"};
    explode(x, y, z, strenght, checkDurability, pushEntity, recursiveBlocks)
end
