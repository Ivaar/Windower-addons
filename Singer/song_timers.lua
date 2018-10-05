local song_timers = {}

local equip_mods = {
    [18342] = {0.2},            -- 'Gjallarhorn',    -- 75
    [18577] = {0.2},            -- 'Gjallarhorn',    -- 80
    [18578] = {0.2},            -- 'Gjallarhorn',    -- 85
    [18579] = {0.3},            -- 'Gjallarhorn',    -- 90
    [18580] = {0.3},            -- 'Gjallarhorn',    -- 95
    [18572] = {0.4},            -- 'Gjallarhorn',    -- 99
    [18840] = {0.4},            -- 'Gjallarhorn',    -- 99-2
    [18575] = {0.25},           -- 'Daurdabla',      -- 90
    [18576] = {0.25},           -- 'Daurdabla',      -- 95
    [18571] = {0.3},            -- 'Daurdabla',      -- 99
    [18839] = {0.3},            -- 'Daurdabla',      -- 99-2
    [19000] = {0.1},            -- 'Carnwenhan',     -- 75
    [19069] = {0.2},            -- 'Carnwenhan',     -- 80
    [19089] = {0.3},            -- 'Carnwenhan',     -- 85
    [19621] = {0.4},            -- 'Carnwenhan',     -- 90
    [19719] = {0.4},            -- 'Carnwenhan',     -- 95
    [19828] = {0.5},            -- 'Carnwenhan',     -- 99
    [19957] = {0.5},            -- 'Carnwenhan',     -- 99-2
    [20561] = {0.5},            -- 'Carnwenhan',     -- 119
    [20562] = {0.5},            -- 'Carnwenhan',     -- 119-2
    [20586] = {0.5},            -- 'Carnwenhan',     -- 119-3
    [21398] = {0.5},            -- 'Marsyas',
    [21400] = {0.1},            -- 'Blurred Harp',
    [21401] = {0.2,Ballad=2},   -- 'Blurred Harp +1',
    [21405] = {0.2} ,           -- 'Eminent Flute',
    [20629] = {0.05},           -- 'Legato Dagger',
    [20599] = {0.05},           -- 'Kali',
    [27672] = {Paeon=0.1},      -- 'Brioso Roundlet',
    [27693] = {Paeon=0.1},      -- 'Brioso Roundlet +1',
    [23049] = {Paeon=0.1},      -- 'Brioso Roundlet +2',
    [23384] = {Paeon=0.1},      -- 'Brioso Roundlet +3',
    [28074] = {0.1},            -- 'Mdk. Shalwar +1',
    [25865] = {0.12},           -- 'Inyanga Shalwar',
    [25866] = {0.15},           -- 'Inyanga Shalwar +1',
    [25882] = {0.17},           -- 'Inyanga Shalwar +2',
    [28232] = {0.1},            -- 'Brioso Slippers',
    [28253] = {0.11},           -- 'Brioso Slippers +1',
    [23317] = {0.13},           -- 'Brioso Slippers +2',
    [23652] = {0.15},           -- 'Brioso Slippers +3',
    [11073] = {Madrigal=0.1},   -- 'Aoidos\' Calot +2',
    [11093] = {0.1,Minuet=0.1}, -- 'Aoidos\' Hngrln. +2',
    [11113] = {March=0.1},      -- 'Ad. Mnchtte. +2',
    [11133] = {Ballad=0.1},     -- 'Aoidos\' Rhing. +2',
    [11153] = {Scherzo=0.1},    -- 'Aoidos\' Cothrn. +2',
    [11618] = {0.1},            -- 'Aoidos\' Matinee',
    [26031] = {0.1},            -- 'Brioso Whistle',
    [26032] = {0.2},            -- 'Moonbow Whistle',
    [26033] = {0.3},            -- 'Mnbw. Whistle +1',
    [26758] = {Madrigal=0.1},   -- 'Fili Calot',
    [26759] = {Madrigal=0.1},   -- 'Fili Calot +1',
    [26916] = {0.11,Minuet=0.1},-- 'Fili Hongreline',
    [26917] = {0.12,Minuet=0.1},-- 'Fili Hongreline +1',
    [27070] = {March=0.1},      -- 'Fili Manchettes',
    [27071] = {March=0.1},      -- 'Fili Manchettes +1',
    [27255] = {Ballad=0.1},     -- 'Fili Rhingrave',
    [27256] = {Ballad=0.1},     -- 'Fili Rhingrave +1',
    [27429] = {Scherzo=0.1},    -- 'Fili Cothurnes',
    [27430] = {Scherzo=0.1},    -- 'Fili Cothurnes +1',
    [26255] = {Madrigal=0.1,Prelude=0.1}, -- 'Intarabus\'s Cape',
    }

local slots = {'main','sub','range','head','neck','body','hands','legs','feet','back'}

function song_timers.duration(name,buffs)
    local mult = 1
    local item = windower.ffxi.get_items('equipment')
    for _,slot in ipairs(slots) do
        local mod = equip_mods[windower.ffxi.get_items(item[slot..'_bag'],item[slot]).id]
        if mod then
            for k,v in pairs(mod) do
                if k == 1 or string.find(name, k) then
                    mult = mult + v
                end
            end
        end
    end
    if buffs.troubadour then mult = mult*2 end
    if string.find(name,'Scherzo') then mult = buffs['soul voice'] and mult*2 or buffs.marcato and mult*1.5 or mult end
    return math.floor(mult*120)
end

function song_timers.buff_lost(targ,buff)
    local buff = get.songs[buff:lower()]
    if not buff or not timers[targ] then return end
    local minimum,song
    for k,song_name in pairs(buff) do
        local song_timer = timers[targ][song_name]
        if song_timer and (not minimum or song_timer.ts < minimum) then
            minimum = song_timer.ts
            song = song_name
        end
    end
    if not song then return end
    if not settings.song[targ] then song_timers.delete(song,'AoE') end
    song_timers.delete(song,targ)
end

function song_timers.update(targ)
    if targ == 'buffs' then return end
    if not timers[targ] then timers[targ] = {} end
    local current_time = os.time()
    local temp_timer_list = {}
    for song_name,expires in pairs(timers[targ]) do
        if expires.ts < current_time then
            temp_timer_list[song_name] = true
        end
    end
    for song_name,expires in pairs(temp_timer_list) do
        timers[targ][song_name] = nil
    end
end

function song_timers.delete(song,targ)
    timers[targ][song] = nil
    windower.send_command('timers delete "%s [%s]"':format(song,targ))
end

function song_timers.create(song,targ,dur,current_time,buffs)
    timers[targ][song] = {ts=current_time+dur,nt=buffs.troubadour,sv=buffs['soul voice']}
    if timers.AoE[song] and targ ~= 'AoE' or not settings.timers then return end
    windower.send_command('timers create "%s [%s]" %s down':format(song,targ,dur))
end
              
function song_timers.adjust(spell_name,targ,buffs)
    local current_time = os.time()
    local dur = song_timers.duration(spell_name,buffs)
    song_timers.update(targ)
    if timers[targ][spell_name] then
        if timers[targ][spell_name].ts < (current_time + dur) then
            song_timers.create(spell_name,targ,dur,current_time,buffs)
        end
    else
        if table.length(timers[targ]) < get.maxsongs(targ,buffs) then
            song_timers.create(spell_name,targ,dur,current_time,buffs)
        else
            local rep,repsong
            for song_name,expires in pairs(timers[targ]) do
                if current_time + dur > expires.ts then
                    if not rep or rep > expires.ts then
                        rep = expires.ts
                        repsong = song_name
                    end
                end
            end
            if repsong then
                song_timers.delete(repsong,targ)
                song_timers.create(spell_name,targ,dur,current_time,buffs)
            end
        end
    end
end

function song_timers.reset(bool)
    for k,targ in pairs(timers) do
        for i,v in pairs(targ) do
            windower.send_command('timers delete "%s [%s]"':format(i,k))
        end
    end
    if bool then return end
    timers = {AoE={},buffs={Haste={},Refresh={}}}
    casting = false
end

return song_timers
