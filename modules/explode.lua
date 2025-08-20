local planExplode = {}
local resistList = {}

processPlanExplode = 0

local sin = math.sin
local cos = math.cos
local deg2rad = math.pi / 180
local steper = 180 / math.pi
local blck = block
local maxParticles = 4

local function get_direction(cx, cy, cz, x, y, z)
    dx = x - cx
    dy = y - cy
    dz = z - cz
    yaw = math.atan2(dx, dz)
    pitch = math.asin(-dy / math.sqrt(dx*dx + dy*dy + dz*dz));
    return yaw, pitch
end

function explodeProcedural(pos, options)
    local stepStr = 1 / (options.strenght / 35)
    for i = stepStr, 1, stepStr do
        local strn = options.strenght * i
        local opts = options
        opts.strenght = strn
        table.insert(planExplode, {pos, options})
    end
    processPlanExplode = 1
end

function queueMove()
    planExplode[1].options.func(planExplode[1].pos, planExplode[1].options)
    table.remove(planExplode, 1)
    if (#planExplode <= 0) then
        processPlanExplode = 0
    end
end

function loadResist()
    for o, pn in ipairs(pack.get_installed()) do
        if (file.exists(pn .. ":resistance_list.properties")) then
            local fl = file.read(pn .. ":resistance_list.properties")
            for line in fl:gmatch("[^\r\n]+") do
                local pos = nil
                for i = 1, #line do
                    if line:sub(i, i) == '=' then
                        pos = i
                        break
                    end
                end
                if pos then
                    local key = line:sub(1, pos - 1)
                    local value_str = line:sub(pos + 1)
                    local value_num = tonumber(value_str)
                    if value_num ~= nil and value_str ~= nil then
                        resistList[tostring(block.index(key))] = value_num
                    end
                end
            end
        end
    end
end

function explode(pos, options)
    local cx = pos[1] + 0.5
    local cy = pos[2] + 0.5
    local cz = pos[3] + 0.5
    local strenght = options.strenght
    local astep = steper / (strenght * (strenght * 0.05))
    strenght = strenght / 2
    for i = 0, 180, astep do
        for j = 0, 360, astep do
            local a = i * deg2rad
            local m = j * deg2rad
            local stepx = cos(m) * cos(a)
            local stepy = cos(m) * sin(a)
            local stepz = sin(m)
            local x = cx
            local y = cy
            local z = cz
            local rayHP = strenght
            while rayHP > 0 do
                x = x + stepx
                y = y + stepy
                z = z + stepz
                local bl = blck.get(x, y, z)
                if (bl ~= 0) then
                    local bp
                    if (blck.properties[bl]) then
                        bp = blck.properties[bl]["explode_lib:blast_resistance"]
                        if (bp ~= nil) then
                            rayHP = rayHP - blck.properties[bl]["explode_lib:blast_resistance"]
                        end
                    end
                    if (resistList[tostring(bl)] ~= nil and bp == nil) then
                        rayHP = rayHP - resistList[tostring(bl)]
                    end
                    if (rayHP <= 0) then
                        break; -- Никто не заметит ;)
                    end
                    local rebl = blck.name(bl)
                    if (rebl ~= nil and options.recursiveBlocks[rebl] ~= nil) then
                        if (options.recursiveBlocks[rebl].recursiveBlocks == "cpy") then
                            local opts = options.recursiveBlocks[rebl]
                            opts.recursiveBlocks = options.recursiveBlocks
                            table.insert(planExplode, {pos = {x, y, z}, options = opts})
                        else
                            table.insert(planExplode, {pos = {x, y, z}, options = options.recursiveBlocks[rebl]})
                        end
                        processPlanExplode = 1
                    end
                    blck.set(x, y, z, 0)
                end
                rayHP = rayHP - 1
            end
        end
    end
    if (options.pushEntities == true) then
        for v, en in ipairs(entities.get_all_in_radius({cx, cy, cz}, strenght * 2)) do
            local e = entities.get(en)
            local ps = e.transform:get_pos()
            local dx, dy = get_direction(cx, cy, cz, ps[1], ps[2], ps[3])
            local distance = math.sqrt((ps[1] - cx)^2 + (ps[2] - cy)^2 + (ps[3] - cz)^2)
            local v = e.rigidbody:get_vel()
            local d = distance / (strenght * 2)
            local sx = math.cos(pitch) * math.sin(yaw)
            local sy = -math.sin(pitch)
            local sz = math.cos(pitch) * math.cos(yaw)
            e.rigidbody:set_vel({v[1] + ((sx / d) * 4), v[2] + ((sy / d) * 2), v[3] + ((sz / d) * 4)})
        end
    end
    if gfx and options.spawnParticles == true then
        local ext = {
            lifetime=4.0 * ((strenght * 2) / 35),
            spawn_interval=0.001,
            explosion={0,0,0},
            texture="particles:smoke",
            size={6, 6, 6},
            spawn_shape="sphere",
            spawn_spread={1, 1, 1},
            acceleration={0, 0, 0},
            max_distance = 16 * core.get_setting("chunks.load-distance")
        }
        for i = 1, maxParticles * ((strenght * 2) / 35) do
            ext.explosion = {strenght * i, strenght * i, strenght * i}
            gfx.particles.emit({cx, cy, cz}, 64, ext)
        end
    end
    if (options.playSound == true) then
        audio.play_stream("sounds/explosion.ogg", cx, cy, cz, 1, (math.random() * 0.5) + 0.75)
    end
end
