require "explode_lib:explode"

function on_interact(x, y, z, playerid)
    local strenght = 32
    local checkDurability = false
    local pushEntity = true
    local recursiveBlocks = {}
    local spawnParticles = true
    local playSound = true
    recursiveBlocks["explode_lib:explosive"] = {strenght, checkDurability, pushEntity, "cpy", "explode", spawnParticles, playSound};
    explode(x, y, z, strenght, checkDurability, pushEntity, recursiveBlocks, spawnParticles, playSound)
end
