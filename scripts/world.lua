require "explode_lib:explode"

function on_world_tick()
    if (processPlanExplode ~= 0) then
        queueMove()
    end
end

function on_world_open()
    loadResist()
end
