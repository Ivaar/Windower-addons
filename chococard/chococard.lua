require('luau')
require('pack')
bit = require('bit')
extdata = require('extdata')

_addon.name = 'chococard'
_addon.author = 'Ivaar'
_addon.commands = {'chococard','cc'}

local chocobo = {
    plan        = {[0]='A','B','C','D'},
    rank        = {[0]='Poor(F)','Substandard(E)','A bit deficient(D)','Average(C)','Better than average(B)','Impressive(A)','Outstanding(S)','First-class(SS)'},
    ability     = {[0]='None','Gallop','Canter','Burrow','Bore','Auto-Regen','Treasure Finder'},
    temperament = {[0]='Very easygoing','Rather ill-tempered','Very patient chocobo','Quite sensitive','Rather enigmatic'},
    gender      = {[0]='Male','Female'},
    color       = {[0]='Yellow','Black','Blue','Red','Green'},
    size        = {[0]='Galka','Hume(M)','Hume(F)','Elvaan(M)','Elvaan(F)','Tarutaru(M)','Tarutaru(F)','Mithra'},
    weather     = {
        [0]     = {prefers='Clear days',        dislikes='None'},
        [1]     = {prefers='Hot, sunny days',   dislikes='Rainy days'},
        [2]     = {prefers='Rainy days',        dislikes='Thunderstorms'},
        [3]     = {prefers='Sandstorms',        dislikes='Windy days'},
        [4]     = {prefers='Windy days',        dislikes='Snowy days'},
        [5]     = {prefers='Snowy days',        dislikes='Hot, sunny days'},
        [6]     = {prefers='Thunderstorms',     dislikes='Sandstorms'},
        [7]     = {prefers='Auroras',           dislikes='Dark days'},
        [8]     = {prefers='Dark days',         dislikes='Auroras'},
        [9]     = {prefers='None',              dislikes='None'},
        [10]    = {prefers='Cloudy days',       dislikes='None'},
    }
}

local map_fields = function(key, ...)
    return T{...}:map(function(v) return chocobo[key][v] end)
end

local fields = {}

fields.egg = {
    DNA         = {'b3b3b3', 0x00+1,        fn=map_fields+{'color'}},
    ability     = {'b4',     0x01+1, 1+1},
    unknown1    = {'b1',     0x01+1, 5+1},
    plan        = {'b2',     0x01+1, 6+1},
    unknown2    = {'b15',    0x02+1},
    is_bred     = {'q',      0x03+1, 7+1},
}

fields.card = {
    STR         = {
        value   = {'C',      0x00+1},
        legs    = {'q',      0x00+1},
        rp      = {'b4',     0x00+1, 1+1,   fn=math.mult+{2}},
        rank    = {'b3',     0x00+1, 5+1},
    },
    END         = {
        value   = {'C',      0x01+1},
        tail    = {'q',      0x01+1},
        rp      = {'b4',     0x01+1, 1+1,   fn=math.mult+{2}},
        rank    = {'b3',     0x01+1, 5+1},
    },
    DSC         = {
        value   = {'C',      0x02+1},
        head    = {'q',      0x02+1},
        rp      = {'b4',     0x02+1, 1+1,   fn=math.mult+{2}},
        rank    = {'b3',     0x02+1, 5+1},
    },
    RCP         = {
        value   = {'C',      0x03+1},
        rp      = {'b5',     0x03+1},
        rank    = {'b3',     0x03+1, 5+1},
    },
    DNA         = {'b3b3b3', 0x04+1,        fn=map_fields+{'color'}},
    abilities   = {'b4b4',   0x05+1, 1+1,   fn=map_fields+{'ability'}},
    temperament = {'b3',     0x06+1, 1+1},
    weather     = {'b4',     0x06+1, 4+1},
    gender      = {'b1',     0x07+1},
    color       = {'b3',     0x07+1, 1+1},
    size        = {'b3',     0x07+1, 4+1},
    unknown     = {'b1',     0x07+1, 7+1},  -- body?
    name        = {'A12',    0x0C+1,        fn=tools.sig.decode},
}

local lookup = function(fn, key, ...)
    if fn then
        return fn(...)
    end
    if chocobo[key] then
        return chocobo[key][...]
    end
    return ...
end

function decode_chocobo(type, str)
    local tab = {}
    for i,t in pairs(fields[type]) do
        if t[1] then
            tab[i] = lookup(t.fn, i, str:unpack(unpack(t)))
        else
            tab[i] = {}
            for k,tt in pairs(t) do
                tab[i][k] = lookup(tt.fn, k, str:unpack(unpack(tt)))
            end
        end
    end
    return tab
end

local chocobo_item = {
    egg  = S{2312,2314,2317,2318,2319},
    card = S{2313,2339,2342,2402},
}

local log_chocobo = function(tab)
    if 'None' == tab.abilities[2] then tab.abilities[2] = nil end
    windower.add_to_chat(207, '\n%s (%s) [%s] Jockey: %s DNA: [%s %s %s]':format(tab.name, tab.gender, tab.color, tab.size, unpack(tab.DNA)))
    windower.add_to_chat(207, 'STR: %3d %s %d~%d/32RP %s':format(tab.STR.value, tab.STR.rank, tab.STR.rp, tab.STR.rp+1, tab.STR.legs and 'Legs and talons' or ''))
    windower.add_to_chat(207, 'END: %3d %s %d~%d/32RP %s':format(tab.END.value, tab.END.rank, tab.END.rp, tab.END.rp+1, tab.END.tail and 'Tailfeather plumage' or ''))
    windower.add_to_chat(207, 'DSC: %3d %s %d~%d/32RP %s':format(tab.DSC.value, tab.DSC.rank, tab.DSC.rp, tab.DSC.rp+1, tab.DSC.head and 'Beak and crest' or ''))
    windower.add_to_chat(207, 'RCP: %3d %s %d/32RP':format(tab.RCP.value, tab.RCP.rank, tab.RCP.rp))
    windower.add_to_chat(207, 'Abilities: %s':format(table.concat(tab.abilities, ' & ')))
    windower.add_to_chat(207, 'Personality: %s':format(tab.temperament))
    windower.add_to_chat(207, 'Weather: Prefers %s. Dislikes %s.':format(tab.weather.prefers, tab.weather.dislikes))

    if tab.unknown == 1 then
        windower.add_to_chat(207, 'Observed unknown value')
    end
    --windower.add_to_chat(207, str:hex())
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x105 then
        if chocobo_item.card[data:unpack('H', 15)] then
            log_chocobo_card(data:sub(18))
        end
    end
end)

local get_speed = function(speed_mod, gear)
    return math.min(speed_mod + gear, 8) / 8 * 20 + 80
end

local get_duration = function(time_mod, gear)
    return (math.min(time_mod + 4, 11) + gear) * 4 + 1
end

windower.register_event('addon command', function(...)
    local commands = {...}
    commands[1] = commands[1] and commands[1]:lower()
    if commands[1] == 'log' then
        windower.add_to_chat(207, '--------------------------------------------------------------------------------')
        for i,v in ipairs(windower.ffxi.get_items(0)) do
            if chocobo_item.egg[v.id] then
                local tab = decode_chocobo('egg', v.extdata)
                local tier = v.id > 2314 and v.id-2314 or v.id == 2314 and 2 or 1
                windower.add_to_chat(207, '\nEgg T%d [%s warm]':format(tier, {'faintly','slightly','a bit','a little','somewhat'}[tier]))
                if tab.is_bred then
                    windower.add_to_chat(207, 'Plan: %s DNA: [%s %s %s]':format(tab.plan, unpack(tab.DNA)))
                    windower.add_to_chat(207, 'Ability: %s unknowns: %d %d':format(tab.ability, tab.unknown1, tab.unknown2))
                    --windower.add_to_chat(207, v.extdata:hex())
                end
            elseif chocobo_item.card[v.id] then
                local tab = decode_chocobo('card', v.extdata)
                log_chocobo(tab)

                local speed_mod = math.floor(tab.STR.value / 0x20) -- str rank
                local time_mod = math.floor(tab.END.value / 0x20) -- end rank
                for x = 1, 2 do
                    if tab.abilities[x] == 'Gallop' then
                        speed_mod = speed_mod + 1
                    elseif tab.abilities[x] == 'Canter' then
                        time_mod = time_mod + 1
                    end
                end

                windower.add_to_chat(207, 'Riding Speed: %.1f%% (Purple Race Silks: %.1f%%)':format(get_speed(speed_mod, 0), get_speed(speed_mod, 1)))
                windower.add_to_chat(207, 'Riding Time: %d Minutes (Red Race Silks: %d Minutes)':format(get_duration(time_mod, 0), get_duration(time_mod, 1)))
            end
        end
    elseif commands[1] == 'display' then

    elseif commands[1] == 'padock' then
        local last = {
            [0x05B] = windower.packets.last_outgoing(0x05B) or '',
            [0x033] = windower.packets.last_incoming(0x033) or '',
            [0x034] = windower.packets.last_incoming(0x034) or '',
        }
        
        if 70 ~= last[0x05B]:unpack('H', 0x10+1) then return end -- chocobo circuit zone id

        local option = last[0x05B]:unpack('H', 0x08+1)
        local menu_id = last[0x05B]:unpack('H', 0x12+1)

        if menu_id == last[0x033]:unpack('H', 0x0C+1) then
            if option > 5 and option < 9 then
                -- free runs and mission races
                -- incoming packet 0x05C
                -- 0x04 chocobo data
                -- 0x0C orders
                -- 0x10 equipment
                -- 0x14 affiliation
                -- 0x1C
                local tab = decode_chocobo('card', windower.packets.last_incoming(0x05C):sub(0x04+1, 0x0B+1)..string.char(0):rep(16))
                if option > 6 then
                    tab.name = windower.packets.last_incoming(0x05D):sub(0x38+1, 0x47+1)
                else
                    tab.name = last[0x033]:sub(0x10+1, 0x1F+1)
                end
                log_chocobo(tab)
            end
        elseif menu_id == last[0x034]:unpack('H', 0x2C+1) and bit.band(option, 0x07) == 0 then
            -- crystal stakes padock
            -- incoming packet 0x05C 
            -- 0x04
            -- 0x08 affiliation
            -- 0x0C orders
            -- 0x10 equipment
            -- 0x14 chocobo data
            -- 0x1C saddle
            -- 0x20
            local tab = decode_chocobo('card', windower.packets.last_incoming(0x05C):sub(0x14+1, 0x1B+1)..string.char(0):rep(16))
            tab.name = windower.packets.last_incoming(0x05D):sub(0x28+1, 0x37+1)
            log_chocobo(tab)
        end
    end
end)
