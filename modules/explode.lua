planExplode = {}

processPlanExplode = 0

local sin = math.sin
local cos = math.cos
local deg2rad = math.pi / 180
local steper = 180 / math.pi
local blck = block

local function get_direction(cx, cy, cz, x, y, z)
    local dx = x - cx
    local dy = y - cy
    local dz = z - cz
    local yaw = math.atan2(dz, dx)
    local pitch = math.atan2(dy, math.sqrt(dx*dx + dz*dz))
    return yaw, pitch
end

function processPlanExplodeReset()
    processPlanExplode = 0
end

function explodeProcedural(cx, cy, cz, strenght, checkBaseDurability, holder, recursiveBlocks)
    local stepStr = 1 / (strenght / 35)
    for i = stepStr, 1, stepStr do
        table.insert(planExplode, {cx, cy, cz, strenght * i, checkBaseDurability, holder, recursiveBlocks, "explode"})
    end
    processPlanExplode = 1
    print(processPlanExplode, #planExplode)
end

function explode(cx, cy, cz, strenght, checkBaseDurability, pushEntities, recursiveBlocks)
    print("Preparing to explode...")
    local resistList = {}
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
    cx = cx
    cy = cy
    cz = cz
    blck.set(cx, cy, cz, 0)
    local uptime1 = time.uptime()
    local totalBlocks = 0
    local total = 0
    local astep = steper / strenght
    strenght = strenght / 2
    for i = 0, 360, astep do
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
                        bp = blck.properties[bl]["base:durability"]
                        if (bp ~= nil and checkBaseDurability == true) then
                            rayHP = rayHP - blck.properties[bl]["base:durability"]
                        end
                    end
                    if (resistList[tostring(bl)] ~= nil and (bp == nil or checkBaseDurability ~= true)) then
                        rayHP = rayHP - resistList[tostring(bl)]
                    end
                    if (rayHP <= 0) then
                        break; -- Никто не заметит ;)
                    end
                    local rebl = blck.name(bl)
                    if (rebl ~= nil and recursiveBlocks[rebl] ~= nil) then
                        if (recursiveBlocks[rebl][4] == "cpy") then
                            table.insert(planExplode, {x, y, z, recursiveBlocks[rebl][1], recursiveBlocks[rebl][2], recursiveBlocks[rebl][3], recursiveBlocks, recursiveBlocks[rebl][5]})
                        else
                            table.insert(planExplode, {x, y, z, recursiveBlocks[rebl][1], recursiveBlocks[rebl][2], recursiveBlocks[rebl][3], recursiveBlocks[rebl][4], recursiveBlocks[rebl][5]})
                        end
                        processPlanExplode = 1
                    end
                    blck.set(x, y, z, 0)
                    totalBlocks = totalBlocks + 1
                end
                rayHP = rayHP - 1
            end
            total = total + 1
        end
    end
    print("Explode finished.")
    print("Total rays:  ", total)
    print("Total blocks:  ", totalBlocks)
    local uptime2 = time.uptime()
    local uptime = uptime2 - uptime1
    print("Explode Was  ", uptime, "  seconds")
    print("Pushing entities...")
    if (pushEntities == true) then
        for v, en in ipairs(entities.get_all_in_radius({cx, cy, cz}, strenght * 2)) do
            local e = entities.get(en)
            local ps = e.transform:get_pos()
            local dx, dy = get_direction(cx, cy, cz, ps[1], ps[2], ps[3])
            local distance = math.sqrt((ps[1] - cx)^2 + (ps[2] - cy)^2 + (ps[3] - cz)^2)
            local v = e.rigidbody:get_vel()
            local d = distance / (strenght * 2)
            local sx, sy, sz = (cos(dx) * cos(dy)), (cos(dx) * sin(dy)), (sin(dx) / d)
            e.rigidbody:set_vel({v[1] + ((sx / d) * 20), v[2] + ((sy / d) * 3), v[3] + (sz * 20)})
        end
    end
end
