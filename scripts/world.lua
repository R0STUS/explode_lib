require "explode_lib:explode"

local funcs = {}

funcs["explode"] = explode
funcs["explodeProcedural"] = explodeProcedural

function on_world_tick()
    if (processPlanExplode ~= 0) then
        funcs[planExplode[1][8]](planExplode[1][1], planExplode[1][2], planExplode[1][3], planExplode[1][4], planExplode[1][5], planExplode[1][6], planExplode[1][7], planExplode[1][9], planExplode[1][10])
        table.remove(planExplode, 1)
        if (#planExplode <= 0) then
            processPlanExplodeReset()
            print(processPlanExplode, #planExplode)
        end
    end
end
