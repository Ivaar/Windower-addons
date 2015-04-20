_addon.command = 'sing'
--res = require 'resources'
--config = require('config')
--spells=require('spells')
require('luau')
require('pack')
packets = require('packets')
texts = require('texts')
song_id = require('spells')
nexttime = os.clock()
lasttime = nexttime
del = 0
lastdel = 0
JA_delay = 1.2
MA_delay = 6
recast_minimum = 0
timers = {self = {},}
base_songs = 3
default = {
    march=2,
    minuet=1,
    madrigal=0,
    scherzo=0,
    prelude=0,
    ballad=0,
    delay=3,
    marcato='valor minuet v',
    clarion='minuet',
    actions=false,
    }
equipment = {
    [21407] = 'Terpander',
    [20561] = 'Carnwenhan',--119
    [20562] = 'Carnwenhan',--119-2
    [20629] = 'Legato Dagger',
    [18575] = 'Daurdabla',--90
    [18576] = 'Daurdabla',--95
    [18571] = 'Daurdabla',--99
    [18839] = 'Daurdabla',--99-2
    [18572] = 'Gjallarhorn',--99
    [18840] = 'Gjallarhorn',--99-2
    [27672] = 'Brioso Roundlet',
    [27693] = 'Brioso Roundlet +1',
    [28232] = 'Brioso Slippers',
    [28253] = 'Brioso Slippers +1',
    [28074] = 'Mdk. Shalwar +1',
    [11113] = 'Ad. Mnchtte. +2',
    [11093] = 'Aoidos\' Hngrln. +2',
    [11073] = 'Aoidos\' Calot +2',
    [11133] = 'Aoidos\' Rhing. +2',
    [11153] = 'Aoidos\' Cothrn. +2',
    [11618] = 'Aoidos\' Matinee',
    }
setting = config.load(default)
windower.register_event('prerender',function ()
    local curtime = os.clock()
    if nexttime + del <= curtime then
        lasttime = nexttime
        lastdel = del
        nexttime = curtime
        del = 0.1
        local lock,JA_WS_lock,Magic_lock,Engaged
        local maxsongs = base_songs
        local play = windower.ffxi.get_player()
        local buffs = calculate_buffs(play.buffs)
        local abil_recasts = windower.ffxi.get_ability_recasts()
        local spell_recasts = windower.ffxi.get_spell_recasts()
        if buffs.terror or buffs.stun or buffs.sleep or buffs.petrification or buffs.charm then
            -- Nothing to be done
            lock = true
        end
        if buffs.amnesia then
            JA_WS_lock = true
        end
        if buffs.silence or buffs.mute then
            Magic_lock = true
        end
        if play.status == 1 then
            Engaged = true
        end
        for k,v in pairs(timers) do
            update_timers(k)
        end
        if buffs['clarion call'] or table.length(timers.self) > base_songs then
            maxsongs = maxsongs+1 
            song[setting.clarion] = setting[setting.clarion] + 1
        end
        if not lock and not Magic_lock and setting.actions and not casting then
            if base_songs == 4 and table.length(timers.self) == maxsongs-2 and not buffs.pastoral and spell_recasts[406] <= recast_minimum then
                cast_song('Herb Pastoral','<me>',JA_WS_lock,buffs)
            elseif table.length(timers.self) == maxsongs-1 and not buffs.round and spell_recasts[414] <= recast_minimum then
                cast_song('Warding Round','<me>',JA_WS_lock,buffs)
            elseif setting.march == 2 and spell_recasts[419] <= recast_minimum and 
            (not timers.self['Advancing March'] or os.time() - timers.self['Advancing March'] + 20 > 0) then
                cast_song('Advancing March','<me>',JA_WS_lock,buffs)
            elseif setting.march >= 1 and spell_recasts[420] <= recast_minimum and 
            (not timers.self['Victory March'] or os.time() - timers.self['Victory March'] + 20 > 0) then
                cast_song('Victory March','<me>',JA_WS_lock,buffs)
            elseif setting.minuet == 4 and spell_recasts[395] <= recast_minimum and 
            (not timers.self['Valor Minuet II'] or os.time() - timers.self['Valor Minuet II'] + 20 > 0) then
                cast_song('Valor Minuet II','<me>',JA_WS_lock,buffs)
            elseif setting.minuet == 3 and spell_recasts[396] <= recast_minimum and 
            (not timers.self['Valor Minuet III'] or os.time() - timers.self['Valor Minuet III'] + 20 > 0) then
                cast_song('Valor Minuet III','<me>',JA_WS_lock,buffs)
            elseif setting.minuet >= 2 and spell_recasts[397] <= recast_minimum and 
            (not timers.self['Valor Minuet IV'] or os.time() - timers.self['Valor Minuet IV'] + 20 > 0) then
                cast_song('Valor Minuet IV','<me>',JA_WS_lock,buffs)
            elseif setting.minuet >= 1 and spell_recasts[398] <= recast_minimum and 
            (not timers.self['Valor Minuet V'] or os.time() - timers.self['Valor Minuet V'] + 20 > 0) then
                cast_song('Valor Minuet V','<me>',JA_WS_lock,buffs)
            elseif setting.madrigal == 2 and spell_recasts[399] <= recast_minimum and 
            (not timers.self['Sword Madrigal'] or os.time() - timers.self['Sword Madrigal'] + 20 > 0) then
                cast_song('Sword Madrigal','<me>',JA_WS_lock,buffs)
            elseif setting.madrigal >= 1 and spell_recasts[400] <= recast_minimum and 
            (not timers.self['Blade madrigal'] or os.time() - timers.self['Blade Madrigal'] + 20 > 0) then
               cast_song('Blade Madrigal','<me>',JA_WS_lock,buffs)	
            elseif setting.prelude == 2 and spell_recasts[401] <= recast_minimum and 
            (not timers.self['Hunter\'s Prelude'] or os.time() - timers.self['Hunter\'s Prelude'] + 20 > 0) then
                cast_song('Hunter\'s Prelude','<me>',JA_WS_lock,buffs)
            elseif setting.prelude >= 1 and spell_recasts[402] <= recast_minimum and 
            (not timers.self['Archer\'s Prelude'] or os.time() - timers.self['Archer\'s Prelude'] + 20 > 0) then
               cast_song('Archer\'s Prelude','<me>',JA_WS_lock,buffs)	
            elseif setting.scherzo ~= 0 and spell_recasts[470] <= recast_minimum and 
            (not timers.self['Sentinel\'s Scherzo'] or os.time() - timers.self['Sentinel\'s Scherzo'] + 20 > 0) then
                cast_song('Sentinel\'s Scherzo','<me>',JA_WS_lock,buffs)
            end
        end
    end
end)

windower.register_event('addon command', function(command,...)
--assert(loadstring(table.concat({...}, ' ')))()
    local args = {...}
    if command then
        command = command:lower()
        if command == 'on' then
            find_extra_song_harp()
            setting.actions = true
        elseif command == 'off' then
            setting.actions = false
        elseif command == 'save' then
            setting:save()
            windower.add_to_chat(207, 'settings saved.')
        elseif command == 'eval' then
             assert(loadstring(table.concat(args, ' ',1)))()
        elseif type(setting[command]) == 'number' and tonumber(args[1]) then
            setting[command] = tonumber(args[1])
        elseif type(setting[command]) == 'string' then
            setting[command] = table.concat(args, ' ',1):lower()	
        elseif type(setting[command]) == 'boolean' then
            if not args[1] and setting[command] == true or args[1] and args[1]:lower() == 'off' then
                setting[command] = false
            elseif not args[1] or args[1] and args[1]:lower() == 'on' then
                setting[command] = true 
            end
        --elseif type(setting[command]) == type(args[1]) then
        --		setting[command] = tonumber(args[1]) or table.concat(args, ' ',1):lower()
        end
    end
    windower.add_to_chat(207, 'March x%s  Minuet x%s  Madrigal x%s Prelude x%s Ballad x %s Scherzo x%s\nactions %s clarion [%s] marcato [%s] delay %s':format(setting.march,setting.minuet,setting.madrigal,setting.prelude,setting.ballad,setting.scherzo,setting.actions == true and '[on]' or '[off]',setting.clarion,setting.marcato,setting.delay))
end)

function calculate_buffs(curbuffs)
    local buffs = {}
    for i,v in pairs(curbuffs) do
        if res.buffs[v] and res.buffs[v].english then
            buffs[res.buffs[v].english:lower()] = (buffs[res.buffs[v].english:lower()] or 0) + 1
        end
    end
    return buffs
end

function use_JA(str)
    windower.send_command(str)
    del = JA_delay
end

function use_MA(str,ta)
    windower.send_command('input /ma "%s" %s':format(str,ta))
    del = setting.delay
end

function cast_song(str,ta,JA_WS_lock,buffs)
    if not JA_WS_lock and not buffs.nightingale and windower.ffxi.get_ability_recasts()[109] <= recast_minimum then
        use_JA('input /ja "Nightingale" <me>')
    elseif not JA_WS_lock and not buffs.troubadour and windower.ffxi.get_ability_recasts()[110] <= recast_minimum then
        use_JA('input /ja "Troubadour" <me>')
    elseif not JA_WS_lock and str:lower() == setting.marcato and not buffs.marcato and not buffs['soul voice'] and windower.ffxi.get_ability_recasts()[48] <= recast_minimum then
        use_JA('input /ja "Marcato" <me>')
    else
        use_MA(str,ta)
    end
end

function get_song(song)
    if tonumber(song) then
        for k,v in pairs(song_id) do
            if k == song then
                return v
            end
        end
    elseif tostring(song) then
        for k,v in pairs(song_id) do
            if v:lower() == song:lower() then
                return k
            end
        end
    end
end

function find_item(id)
    local items = windower.ffxi.get_items()
    for i,v in ipairs(items.inventory) do
        if v and v.id == id then
        return true
        end
    end
    for i,v in ipairs(items.wardrobe) do
        if v and v.id == id then
        return true
        end
    end
    return false
end

function find_extra_song_harp()
    if find_item(21407) or find_item(18575) or find_item(18576) then
        base_songs = 3
    elseif find_item(18571) or find_item(18839) then
        base_songs = 4
    else
        base_songs = 2
    end
end
find_extra_song_harp()
function equip(slot)
    local item = windower.ffxi.get_items().equipment
    return windower.ffxi.get_items(item[slot..'_bag'],item[slot]).id
end

function calculate_duration(name,buffs)
    local mult = 1
    if equipment[equip('range')] == 'Daurdabla' then mult = mult + 0.3 end -- change to 0.25 with 90 Daur
    if equipment[equip('range')] == 'Gjallarhorn' then mult = mult + 0.4 end -- change to 0.3 with 95 Gjall
    if equipment[equip('main')] == 'Carnwenhan' then mult = mult + 0.5 end -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
    if equipment[equip('main')] == 'Legato Dagger' then mult = mult + 0.05 end
    if equipment[equip('sub')] == "Legato Dagger" then mult = mult + 0.05 end
    if equipment[equip('neck')] == 'Aoidos\' Matinee' then mult = mult + 0.1 end
    if equipment[equip('body')] == 'Aoidos\' Hngrln. +2' then mult = mult + 0.1 end
    if equipment[equip('legs')] == 'Mdk. Shalwar +1' then mult = mult + 0.1 end
    if equipment[equip('feet')] == "Brioso Slippers" then mult = mult + 0.1 end
    if equipment[equip('feet')] == "Brioso Slippers +1" then mult = mult + 0.11 end
    if string.find(name,'March') and equipment[equip('hands')] == 'Ad. Mnchtte. +2' then mult = mult + 0.1 end
    if string.find(name,'Minuet') and equipment[equip('body')] == 'Aoidos\' Hngrln. +2' then mult = mult + 0.1 end
    if string.find(name,'Madrigal') and equipment[equip('head')] == 'Aoidos\' Calot +2' then mult = mult + 0.1 end
    if string.find(name,'Ballad') and equipment[equip('legs')] == 'Aoidos\' Rhing. +2' then mult = mult + 0.1 end
    if string.find(name,'Scherzo') and equipment[equip('feet')] == 'Aoidos\' Cothrn. +2' then mult = mult + 0.1 end
    if string.find(name,'Paeon') and equipment[equip('head')] == "Brioso Roundlet" then mult = mult + 0.1 end
    if string.find(name,'Paeon') and equipment[equip('head')] == "Brioso Roundlet +1" then mult = mult + 0.1 end
    if buffs.troubadour then
        mult = mult*2
    end
    if string.find(name,'Scherzo') and buffs['soul voice'] then
        mult = mult*2
    elseif string.find(name,'Scherzo') and buffs.marcato then
        mult = mult*1.5
    end
    --print(mult*120, math.floor(mult*120))
    return math.floor(mult*120)
end

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        --table.vprint(packet)
        local play = windower.ffxi.get_player()
        local actor_name = windower.ffxi.get_mob_by_id(packet['Actor'])['name']
        local targ_name = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])['name']
        if packet['Category'] == 8 and actor_name == play.name then
            if (packet['Param'] == 24931) then
            -- Begin Casting
                casting = true
            elseif (packet['Param'] == 28787) then
            -- Failed Casting
                casting = false
                del = 1
            end
        elseif packet['Category'] == 4 and actor_name == play.name then
            -- Finish Casting
            casting = false
            del = setting.delay
            if not song_id[packet['Param']] then return end
            local dur = calculate_duration(song_id[packet['Param']],calculate_buffs(play.buffs))
            local spell_name = song_id[packet['Param']]
            if targ_name == actor_name then
                adjust_timers(spell_name,dur,'self')
            --else
            --	adjust_timers(spell_name,dur,targ_name)
            end
        elseif packet['Category'] == 7 and actor_name == play.name then
            casting = true
        elseif packet['Category'] == 9 and actor_name == play.name then
            casting = true
        elseif packet['Category'] == 3 and actor_name == play.name then
            casting = false
        elseif packet['Category'] == 5 and actor_name == play.name then
            casting = false
        end
    --[[elseif id == 0x029 then
        local packet = packets.parse('incoming', original)
        table.vprint(packet)
        if (packet.Message) == 206 then
        lost buff
        ]]--res.buffs[packet['Param 1']].english:lower()
        --end
    end
end)

function update_timers(targ)
    if not timers[targ] then timers[targ] = {} end
    local current_time = os.time()
    local temp_timer_list = {}
    for song_name,expires in pairs(timers[targ]) do
        if expires < current_time then
            temp_timer_list[song_name] = true
        end
    end
    for song_name,expires in pairs(temp_timer_list) do
        timers[targ][song_name] = nil
    end
end

function adjust_timers(spell_name,dur,targ)
    local current_time = os.time()
    local buffs = calculate_buffs(windower.ffxi.get_player().buffs)
    update_timers(targ)
    if timers[targ][spell_name] then
        if timers[targ][spell_name] < (current_time + dur) then
            timers[targ][spell_name] = current_time + dur
            --windower.send_command('timers create "'..spell_name..' ['..targ..']" '..dur..' down')
            windower.send_command('timers create "'..spell_name..'" '..dur..' down')
        end
    else
        local maxsongs = 2
        if equipment[equip('range')] == 'Daurdabla' then
            maxsongs = maxsongs + 2
        elseif equipment[equip('range')] == 'Terpander' then
            maxsongs = maxsongs + 1
        end
        if buffs['Clarion Call'] then
            maxsongs = maxsongs + 1
        end
        if maxsongs < table.length(timers[targ]) then
            maxsongs = table.length(timers[targ])
        end
        if table.length(timers[targ]) < maxsongs then
            timers[targ][spell_name] = current_time + dur
            --windower.send_command('timers create "'..spell_name..' ['..targ..']" '..dur..' down')
            windower.send_command('timers create "'..spell_name..'" '..dur..' down')
        else
            local rep,repsong
            for song_name,expires in pairs(timers[targ]) do
                if current_time + dur > expires then
                    if not rep or rep > expires then
                        rep = expires
                        repsong = song_name
                    end
                end
            end
            if repsong then
                timers[targ][repsong] = nil
                timers[targ][spell_name] = current_time + dur
                --windower.send_command('timers delete "'..repsong..' ['..targ..']";timers create "'..spell_name..' ['..targ..']" '..dur..' down')
                windower.send_command('timers delete "'..repsong..'";timers create "'..spell_name..'" '..dur..' down')
            end
        end
    end
end

function reset_timers()
    for k,targ in pairs(timers) do
        for i,v in pairs(targ) do
            --windower.send_command('timers delete "'..i..' ['..k..']"')
            windower.send_command('timers delete "'..i..'"')
        end
    end
    timers = {}
    timers['self'] = {}
    casting = false
end

function status_change(new,old)
    casting = false
    if new == 2 or new == 3 then
        reset_timers()
    end
end
windower.register_event('unload', reset_timers)
windower.register_event('zone change', reset_timers)
windower.register_event('status change', status_change)
