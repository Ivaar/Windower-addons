_addon.command = 'sing'
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
timers = {AoE = {},}
base_songs = 3

default = {
    march=2,
    minuet=1,
    madrigal=0,
    scherzo=0,
    prelude=0,
    ballad=0,
    mazurka=0,
    delay=3,
    marcato='valor minuet v',
    clarion='minuet',
    actions=false,
    pianissimo=false,
    precast=20,
    display = true,
    aoe = S{},
    song={
       }
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
bard_status = texts.new(setting)
bard_status :show()

display_box = function()
    if setting.actions then
        return 'Auto-Songs [ON]'
    else
        return 'Auto-Songs [OFF]'
    end
end

windower.register_event('prerender',function ()
    local curtime = os.clock()
    if nexttime + del <= curtime then
        lasttime = nexttime
        lastdel = del
        nexttime = curtime
        del = 0.1
        bard_status:text(display_box())
        if not setting.actions then return end
        local play = windower.ffxi.get_player()
        if not play or (play.status ~= 1 and play.status ~= 0) then return end
        local lock,JA_WS_lock,Magic_lock,Engaged
        local maxsongs = base_songs
        local moving = play_move()
        local buffs = calculate_buffs(play.buffs)
        local abil_recasts = windower.ffxi.get_ability_recasts()
        local spell_recasts = windower.ffxi.get_spell_recasts()
        local precast = math.random(setting.precast,setting.precast+10)+math.random()
        local aoe_range = aoe_check()
        if buffs.terror or buffs.stun or buffs.sleep or buffs.petrification or buffs.charm or casting or moving then return end
        if buffs.amnesia then
            JA_WS_lock = true
        end
        if buffs.silence or buffs.mute then
            Magic_lock = true
        end
        --if play.status == 1 then Engaged = true end
        for k,v in pairs(timers) do
            update_timers(k)
        end
       --[[ if buffs['clarion call'] or table.length(timers.AoE) > base_songs then
            maxsongs = maxsongs+1 
            song[setting.clarion] = setting[setting.clarion] + 1
        end--]]
        maxsongs = aug_maxsongs('AoE',maxsongs,buffs)
        if not Magic_lock then
            if base_songs == 4 and table.length(timers.AoE) == maxsongs-2 and aoe_range and not buffs.pastoral and spell_recasts[406] <= recast_minimum then
                cast_song('Herb Pastoral','<me>',JA_WS_lock,buffs)
            elseif base_songs == 3 and table.length(timers.AoE) == maxsongs-1 and aoe_range and not buffs.round and spell_recasts[414] <= recast_minimum then
                cast_song('Warding Round','<me>',JA_WS_lock,buffs)
            elseif setting.march == 2 and spell_recasts[419] <= recast_minimum and aoe_range and 
            (not timers.AoE['Advancing March'] or os.time() - timers.AoE['Advancing March'] + precast > 0) then
                cast_song('Advancing March','<me>',JA_WS_lock,buffs)
            elseif setting.march >= 1 and spell_recasts[420] <= recast_minimum and aoe_range and 
            (not timers.AoE['Victory March'] or os.time() - timers.AoE['Victory March'] + precast > 0) then
                cast_song('Victory March','<me>',JA_WS_lock,buffs)
            elseif setting.minuet == 4 and spell_recasts[395] <= recast_minimum and aoe_range and 
            (not timers.AoE['Valor Minuet II'] or os.time() - timers.AoE['Valor Minuet II'] + precast > 0) then
                cast_song('Valor Minuet II','<me>',JA_WS_lock,buffs)
            elseif setting.minuet == 3 and spell_recasts[396] <= recast_minimum and aoe_range and 
            (not timers.AoE['Valor Minuet III'] or os.time() - timers.AoE['Valor Minuet III'] + precast > 0) then
                cast_song('Valor Minuet III','<me>',JA_WS_lock,buffs)
            elseif setting.minuet >= 2 and spell_recasts[397] <= recast_minimum and aoe_range and 
            (not timers.AoE['Valor Minuet IV'] or os.time() - timers.AoE['Valor Minuet IV'] + precast > 0) then
                cast_song('Valor Minuet IV','<me>',JA_WS_lock,buffs)
            elseif setting.minuet >= 1 and spell_recasts[398] <= recast_minimum and aoe_range and 
            (not timers.AoE['Valor Minuet V'] or os.time() - timers.AoE['Valor Minuet V'] + precast > 0) then
                cast_song('Valor Minuet V','<me>',JA_WS_lock,buffs)
            elseif setting.madrigal == 2 and spell_recasts[399] <= recast_minimum and aoe_range and 
            (not timers.AoE['Sword Madrigal'] or os.time() - timers.AoE['Sword Madrigal'] + precast > 0) then
                cast_song('Sword Madrigal','<me>',JA_WS_lock,buffs)
            elseif setting.madrigal >= 1 and spell_recasts[400] <= recast_minimum and aoe_range and 
            (not timers.AoE['Blade Madrigal'] or os.time() - timers.AoE['Blade Madrigal'] + precast > 0) then
               cast_song('Blade Madrigal','<me>',JA_WS_lock,buffs)	
            elseif setting.prelude == 2 and spell_recasts[401] <= recast_minimum and aoe_range and 
            (not timers.AoE['Hunter\'s Prelude'] or os.time() - timers.AoE['Hunter\'s Prelude'] + precast > 0) then
                cast_song('Hunter\'s Prelude','<me>',JA_WS_lock,buffs)
            elseif setting.prelude >= 1 and spell_recasts[402] <= recast_minimum and aoe_range and 
            (not timers.AoE['Archer\'s Prelude'] or os.time() - timers.AoE['Archer\'s Prelude'] + precast > 0) then
               cast_song('Archer\'s Prelude','<me>',JA_WS_lock,buffs)	
            elseif setting.scherzo ~= 0 and spell_recasts[470] <= recast_minimum and aoe_range and 
            (not timers.AoE['Sentinel\'s Scherzo'] or os.time() - timers.AoE['Sentinel\'s Scherzo'] + precast > 0) then
                cast_song('Sentinel\'s Scherzo','<me>',JA_WS_lock,buffs)
            elseif setting.ballad == 3 and spell_recasts[386] <= recast_minimum and aoe_range and 
            (not timers.AoE['Mage\'s Ballad'] or os.time() - timers.AoE['Mage\'s Ballad'] + precast > 0) then
                cast_song('Mage\'s Ballad','<me>',JA_WS_lock,buffs)
            elseif setting.ballad >= 2 and spell_recasts[387] <= recast_minimum and aoe_range and 
            (not timers.AoE['Mage\'s Ballad  II'] or os.time() - timers.AoE['Mage\'s Ballad II'] + precast > 0) then
                cast_song('Mage\'s Ballad II','<me>',JA_WS_lock,buffs)
            elseif setting.ballad >= 1 and spell_recasts[388] <= recast_minimum and aoe_range and 
            (not timers.AoE['Mage\'s Ballad III'] or os.time() - timers.AoE['Mage\'s Ballad III'] + precast > 0) then
                cast_song('Mage\'s Ballad III','<me>',JA_WS_lock,buffs)               
            elseif setting.mazurka ~= 0 and spell_recasts[465] <= recast_minimum and aoe_range and 
            (not timers.AoE['Chocobo Mazurka'] or os.time() - timers.AoE['Chocobo Mazurka'] + precast > 0) then
                cast_song('Chocobo Mazurka','<me>',JA_WS_lock,buffs)
            elseif setting.pianissimo then
                for targ,songs in pairs(setting.song) do
                    for ind,song in ipairs(songs) do    
                        if base_songs == 4 and timers[targ] and table.length(timers[targ]) == maxsongs-2 and valid_target(targ,20) and spell_recasts[406] <= recast_minimum then
                            cast_song('Herb Pastoral',targ,JA_WS_lock,buffs)
                            return
                        elseif base_songs == 3 and timers[targ] and table.length(timers[targ]) == maxsongs-1 and valid_target(targ,20) and spell_recasts[414] <= recast_minimum then
                            cast_song('Warding Round',targ,JA_WS_lock,buffs)  
                            return
                        elseif setting.song[targ][ind] and spell_recasts[get_song(song)] <= recast_minimum and valid_target(targ,20) and
                          (not timers[targ] or not timers[targ][song] or os.time() - timers[targ][song] + precast > 0) then
                            cast_song(song,targ,JA_WS_lock,buffs)
                            return
                        end
                    end
                end
            end
        end
    end
end)

buff_song = {
    ballad={
        [1]='Mage\'s Ballad III',
        [2]='Mage\'s Ballad II',
        [3]='Mage\'s Ballad',
        },
    march={
        [1]='Victory March',
        [2]='Advancing March',
        },
    minuet={
        [1]='Valor Minuet V',
        [2]='Valor Minuet IV',
        [3]='Valor Minuet III',
        [4]='Valor Minuet II',
        [5]='Valor Minuet',
        },
    madrigal={
        [1]='Blade Madrigal',
        [2]='Sword Madrigal',
        },
    prelude={
        [1]='Archer\'s Prelude',
        [2]='Hunter\'s Prelude',
        },
    scherzo={
        [1]='Sentinel\'s Scherzo',
        },
    }

function get_coords()
    local play = windower.ffxi.get_mob_by_target('me')
    if play then
        return {play.x,play.z,play.y}
    else
        return {0,0,0}
    end 
end

function play_move()
    local coords = get_coords()
    local clock = os.clock()
    lastcoords = lastcoords and lastcoords or get_coords()
    if lastcoords[1] ~= coords[1] or lastcoords[2] ~= coords[2] or lastcoords[3] ~= coords[3] then
        lastcoords = coords
        ts = clock
        return true
    end
    if ts and ts+0.5>clock then
        return true
    end
    return false
end

function get_song_buff(song)
    for buff,songs in pairs(buff_song) do
        for ind,song_name in pairs(songs) do
            if song_name:lower() == song:lower() then
                return buff--,ind
            end
        end
    end
    return nil
end

function valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.name:lower() == targ:lower() and math.sqrt(member.mob.distance) < dst and not member.mob.charmed and member.mob.hpp > 0 then
           return true
        end
    end
    return false
end

windower.register_event('addon command', function(...)
    local commands = {...}
    if commands[1] then
        commands[1] = commands[1]:lower()
        if commands[1] == 'on' then
            find_extra_song_harp()
            setting.actions = true
        elseif commands[1] == 'off' then
            setting.actions = false
        elseif commands[1] == 'save' then
            setting:save()
            windower.add_to_chat(207, 'settings saved.')
        elseif commands[1] == 'eval' then
             assert(loadstring(table.concat(commands, ' ',1)))()
        elseif type(setting[commands[1]]) == 'number' and tonumber(commands[2]) then
            setting[commands[1]] = tonumber(commands[2])
        elseif type(setting[commands[1]]) == 'string' then
            setting[commands[1]] = table.concat(commands, ' ',1):lower()	
        elseif type(setting[commands[1]]) == 'boolean' then
            if not commands[2] and setting[commands[1]] == true or commands[2] and commands[2]:lower() == 'off' then
                setting[commands[1]] = false
            elseif not commands[2] or commands[2] and commands[2]:lower() == 'on' then
                setting[commands[1]] = true 
            end
        elseif commands[1] == 'song' then
            if commands[#commands] == '+' then
                local player = windower.ffxi.get_mob_by_name(commands[2]:ucfirst()).name
                local song = table.concat(commands,' ',3,#commands-1):lower()
                if not setting.song[player] then setting.song[player] = L{} end
                if not setting.song[player]:find(song) then
                    setting.song[player]:append(song)
                    windower.add_to_chat(207, 'Will now Pianissimo %s for %s.':format(song,player))
                else
                    windower.add_to_chat(207, '%s is already for %s.':format(song,player))
                end 
            elseif commands[#commands] == '-' then
                local player = windower.ffxi.get_mob_by_name(commands[2]:ucfirst()).name
                local song = table.concat(commands,' ',3,#commands-1):lower()
                if not setting.song[player] then return end
                local ind = setting.song[player]:find(song)
                if ind then
                    setting.song[player]:remove(ind)
                    windower.add_to_chat(207, 'Will no longer Pianissimo %s for %s.':format(song,player))
                else
                    windower.add_to_chat(207, 'Pianissimo %s is not set for %s.':format(song,player))
                end
            end
        elseif commands[1] == 'aoe' then
            if commands[#commands] == '+' then
                local player = windower.ffxi.get_mob_by_name(commands[2]:ucfirst()).name
                if not setting.aoe:find(player) then
                    setting.aoe:append(player)
                    windower.add_to_chat(207, 'Will now check if %s is in AoE range.':format(player))
                else
                    windower.add_to_chat(207, '%s is already being watched.':format(player))
                end
            elseif commands[#commands] == '-' then
                local player = windower.ffxi.get_mob_by_name(commands[2]:ucfirst()).name
                local ind = setting.aoe:find(player)
                if ind then
                    setting.aoe:remove(ind)
                    windower.add_to_chat(207, '%s will now be ignored for AoE.':format(player))
                else
                    windower.add_to_chat(207, '%s is not being watched.':format(player))
                end
            end
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
    elseif ta ~= '<me>' and not buffs.pianissimo then
         use_JA('input /ja "Pianissimo" <me>')
    else
        use_MA(str,ta)
    end
end

function aoe_check()
    for k,v in pairs(setting.aoe) do
        if not valid_target(v,10) then
            return false
        end
    end
    return true
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
    return nil
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
    if equipment[equip('range')] == 'Daurdabla' then mult = mult + 0.3 end    -- 0.25 for 90, 0.3 for 99
    if equipment[equip('range')] == 'Gjallarhorn' then mult = mult + 0.4 end  -- 0.3 for 95, 0.4 for 99
    if equipment[equip('main')] == 'Carnwenhan' then mult = mult + 0.5 end    -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
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
            if packet['Target Count'] > 1 then
                adjust_timers(spell_name,dur,'AoE')
            end
            for x = 1,packet['Target Count'] do
                local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                adjust_timers(spell_name,dur,targ_name)
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
    elseif id == 0x029 then
        local packet = packets.parse('incoming', original)
        local play = windower.ffxi.get_player()
        local actor_name = windower.ffxi.get_mob_by_id(packet['Actor'])['name']
        local targ_name = windower.ffxi.get_mob_by_id(packet['Target'])['name']
        if (packet.Message) == 206 and actor_name == play.name then
            print(targ_name,res.buffs[packet['Param 1']].english:lower())
            find_lost_buff(targ_name,res.buffs[packet['Param 1']].english:lower())
        end
    end
end)

function find_lost_buff(targ,buff)
    local buff = buff_song[buff]
    if not buff or not timers[targ] then return end
    local minimum,song
    for k,song_name in pairs(buff) do
        local song_timer = timers[targ][song_name]
        if song_timer and (not minimum or song_timer < minimum) then
            minimum = song_timer
            song = song_name
        end
    end
    if not song then return end
    if not setting.song[targ] then delete_timer(song,'AoE') end
    delete_timer(song,targ)
end

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

function aug_maxsongs(targ,maxsongs,buffs)
    if buffs['clarion call'] then
        maxsongs = maxsongs + 1 
    end
    if maxsongs < table.length(timers[targ]) then
        maxsongs = table.length(timers[targ])
    end
    return maxsongs
end

function adjust_timers(spell_name,dur,targ)
    local current_time = os.time()
    local buffs = calculate_buffs(windower.ffxi.get_player().buffs)
    update_timers(targ)
    if timers[targ][spell_name] then
        if timers[targ][spell_name] < (current_time + dur) then
            create_timer(spell_name,targ,dur,current_time)
        end
    else
        local maxsongs = 2
        if equipment[equip('range')] == 'Daurdabla' or equipment[equip('range')] == 'Terpander' then
            maxsongs = base_songs
        end
        maxsongs = aug_maxsongs(targ,maxsongs,buffs)
        if table.length(timers[targ]) < maxsongs then
            create_timer(spell_name,targ,dur,current_time)
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
                delete_timer(repsong,targ)
                create_timer(spell_name,targ,dur,current_time)
            end
        end
    end
end

function create_timer(song,targ,dur,current_time)
    timers[targ][song] = current_time + dur
    if timers.AoE[song] and targ ~= 'AoE' or not setting.display then return end
    windower.send_command('timers create "%s [%s]" %s down':format(song,targ,dur))
end

function delete_timer(song,targ)
    timers[targ][song] = nil
    windower.send_command('timers delete "%s [%s]"':format(song,targ))
end
              
function reset_timers()
    for k,targ in pairs(timers) do
        for i,v in pairs(targ) do
            windower.send_command('timers delete "%s [%s]"':format(i,k))
        end
    end
    timers = {}
    timers['AoE'] = {}
    casting = false
end

function status_change(new,old)
    casting = false
    if new == 2 or new == 3 then
        reset_timers()
        setting.actions = false
    end
end

function zone_change()
    setting.actions = false
    casting = false
    reset_timers()
end

windower.register_event('unload', reset_timers)
windower.register_event('zone change', zone_change)
windower.register_event('status change', status_change)
