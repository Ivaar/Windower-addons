_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.15.06.16'

require('pack')
packets = require('packets')
texts = require('texts')
song_id = require('spells')
config = require('config')

default = {
    delay=4,
    dummy1='Knight\'s Minne',
    dummy2='Knight\'s Minne II',
    marcato='valor minuet v',
    clarion={aoe='minuet'},
    actions=false,
    pianissimo=false,
    recast=20,
    display = true,
    aoe={},
    song={},
    songs={march=2},
    min_ws_hp=20,
    max_ws_hp=99,
    text={}
    }

setting = config.load(default)

nexttime = os.clock()
del = 0
timers = {AoE = {},}

equipment = L{
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
    [26758] = 'Fili Calot',
    [26759] = 'Fili Calot +1',
    [26916] = 'Fili Hongreline',
    [26917] = 'Fili Hongreline +1',
    [27070] = 'Fili Manchettes',
    [27071] = 'Fili Manchettes +1',
    [27255] = 'Fili Rhingrave',
    [27256] = 'Fili Rhingrave +1',
    [27429] = 'Fili Cothurnes',
    [27430] = 'Fili Cothurnes +1',
    }

buff_ids = L{
    [195] = 'Paeon',
    [196] = 'Ballad',
    [197] = 'Minne',
    [198] = 'Minuet',
    [199] = 'Madrigal',
    [200] = 'Prelude',
    [201] = 'Mambo',
    [202] = 'Aubade',
    [203] = 'Pastoral',
    [205] = 'Fantasia',
    [206] = 'Operetta',
    [207] = 'Capriccio',
    [209] = 'Round',
    [210] = 'Gavotte',
    [214] = 'March',
    [215] = 'Etude',
    [216] = 'Carol',
    [218] = 'Hymnus',
    [219] = 'Mazurka',
    [220] = 'Sirvente',
    [221] = 'Dirge',
    [222] = 'Scherzo',
    }

buff_songs = {
    paeon = {[1]='Army\'s Paeon VI',[2]='Army\'s Paeon V',[3]='Army\'s Paeon IV',[4]='Army\'s Paeon III',[5]='Army\'s Paeon II',[6]='Army\'s Paeon'},
    ballad = {[1]='Mage\'s Ballad III',[2]='Mage\'s Ballad II',[3]='Mage\'s Ballad'},
    minne = {[1]='Knight\'s Minne V',[2]='Knight\'s Minne IV',[3]='Knight\'s Minne III',[4]='Knight\'s Minne II',[5]='Knight\'s Minne'},
    minuet = {[1]='Valor Minuet V',[2]='Valor Minuet IV',[3]='Valor Minuet III',[4]='Valor Minuet II',[5]='Valor Minuet'}, 
    madrigal = {[1]='Blade Madrigal',[2]='Sword Madrigal'},
    prelude = {[1]='Archer\'s Prelude',[2]='Hunter\'s Prelude'},
    mambo = {[1]='Dragonfoe Mambo',[2]='Sheepfoe Mambo'},
    aubade = {[1]='Fowl Aubade'},
    pastoral = {[1]='Herb Pastoral'},
    fantasia = {[1]='Shining Fantasia'},
    operetta = {[1]='Puppet\'s Operetta',[2]='Scop\'s Operetta'},
    capriccio = {[1]='Gold Capriccio'},
    round = {[1]='Warding Round'},
    gavotte = {[1]='Shining Fantasia'},
    march = {[1]='Victory March',[2]='Advancing March'},
    hymnus = {[1]='Goddess\'s Hymnus'},
    mazurka = {[1]='Chocobo Mazurka'},
    sirvente = {[1]='Foe Sirvente'},
    dirge = {[1]='Adventurer\'s Dirge'},
    scherzo = {[1]='Sentinel\'s Scherzo'},
    }

display_box = function()
    if setting.actions then
        return ' Singer [On] '
    else
        return ' Singer [Off] '
    end
end

bard_status = texts.new(display_box(),setting.text,setting)
bard_status:show()

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

windower.register_event('prerender',function ()
    if not setting.actions then return end
    local curtime = os.clock()
    if nexttime + del <= curtime then
        nexttime = curtime
        del = 0.1
        for k,v in pairs(timers) do
            update_timers(k)
        end
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        local JA_WS_lock
        local moving = is_moving()
        local buffs = calculate_buffs(play.buffs)
        local spell_recasts = windower.ffxi.get_spell_recasts()
        local ability_recasts = windower.ffxi.get_ability_recasts()
        local recast = math.random(setting.recast,setting.recast+10)+math.random()
        if moving or casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end
        if play.status == 1 and equip('main') == 'Carnwenhan' and not JA_WS_lock then
            local targ = windower.ffxi.get_mob_by_target('t')
            local Eye_Sight = eye_sight(windower.ffxi.get_mob_by_target('me'),targ)
            if not AM_start and buffs['aftermath: lv.3'] then
                AM_start = curtime
            end
            if buffs['aftermath: lv.3'] and AM_start and curtime - AM_start <= 140 then
                goal_tp = 1000
            else
                goal_tp = 3000
            end
            if Eye_Sight and play.vitals.tp >= goal_tp and targ and targ.valid_target and targ.hpp < setting.max_ws_hp and targ.hpp > setting.min_ws_hp and targ.is_npc and math.sqrt(targ.distance) <= 4 and ((goal_tp == 3000 and not buffs['aftermath: lv.3']) or goal_tp == 1000) then
                if goal_tp == 3000 then
                    AM_start = curtime
                end
                windower.send_command('input /ws "Mordant Rime" <t>')
                del = 4.2
                return
            end
        end
        if buffs.silence or buffs.mute or buffs.omerta then return end     
        if aoe_range() then
            local song = check_song(setting.songs,'AoE',buffs,spell_recasts,recast) 
            if song then cast_song(song,'<me>',buffs,ability_recasts,JA_WS_lock) return end
        end
        if not setting.pianissimo then return end
        for targ,songs in pairs(setting.song) do
            if valid_target(targ,20) then
                local song = check_song(songs,targ:ucfirst(),buffs,spell_recasts,recast) 
                if song then cast_song(song,targ:ucfirst(),buffs,ability_recasts,JA_WS_lock) return end
            end
        end
    end
end)

function use_JA(str)
    windower.send_command(str)
    del = 1.2
end

function use_MA(str,ta)
    windower.send_command('input /ma "%s" %s':format(str,ta))
    del = setting.delay
end

function cast_song(str,ta,buffs,recasts,JA_WS_lock)
    if not JA_WS_lock and not buffs.nightingale and recasts[109] <= 0 then
        use_JA('input /ja "Nightingale" <me>')
    elseif not JA_WS_lock and not buffs.troubadour and recasts[110] <= 0 then
        use_JA('input /ja "Troubadour" <me>')
    elseif not JA_WS_lock and str:lower() == setting.marcato and not buffs.marcato and not buffs['soul voice'] and recasts[48] <= 0 then
        use_JA('input /ja "Marcato" <me>')
    elseif ta ~= '<me>' and not buffs.pianissimo then 
        if not JA_WS_lock and recasts[112] <= 0 then
            use_JA('input /ja "Pianissimo" <me>')
        end
    else
        use_MA(str,ta)
    end
end

function aug_songs(songs,targ,maxsongs)
    local song_list = {}
    local clarion = setting.clarion[targ:lower()]
    for k,v in pairs(songs) do
        song_list[k] = v
    end
    if clarion and maxsongs > base_songs then
        song_list[clarion] = (song_list[clarion] or 0)+1 
    end
    return song_list
end

function check_song(songs,targ,buffs,spell_recasts,recast)
    local maxsongs = aug_maxsongs(targ,buffs)
    local song_list = aug_songs(songs,targ,maxsongs)
    if base_songs == 4 and timers[targ] and table.length(timers[targ]) == maxsongs-2 and spell_recasts[get_song_id(setting.dummy2)] <= 0 then
        return setting.dummy2
    elseif base_songs >= 3 and timers[targ] and table.length(timers[targ]) == maxsongs-1 and spell_recasts[get_song_id(setting.dummy1)] <= 0 then
        return setting.dummy1
    end
    for buff,num in pairs(song_list) do
        for x = 1,num do
            local song = get_song(buff_songs[buff][x])
            if song and spell_recasts[get_song_id(song)] <= 0 and
            (not timers[targ] or not timers[targ][song] or os.time()-timers[targ][song].ts+recast>0 or 
            (buffs.troubadour and not timers[targ][song].nt) or 
            (buffs['soul voice'] and not timers[targ][song].sv)) then
                return song
            end
        end
    end
    return false
end

function get_coords()
    local play = windower.ffxi.get_mob_by_target('me')
    if play then
        return {play.x,play.z,play.y}
    else
        return {0,0,0}
    end 
end

function is_moving()
    local coords = get_coords()
    local clock = os.clock()
    lastcoords = lastcoords and lastcoords or coords
    for x=1,3 do if lastcoords[x] ~= coords[x] then lastcoords=coords ts=clock return true end end
    if ts and ts+1>clock then return true end
    return false
end

function valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.name:lower() == targ:lower() and math.sqrt(member.mob.distance) < dst and not member.mob.charmed and member.mob.hpp > 0 and member.mob.in_party then
           return true
        end
    end
    return false
end

function eye_sight(player,target)
    if not target then return false end
    local xdif = target.x - player.x -- Negative if target is west
    local ydif = target.y - player.y -- Negative if target is south
    if math.abs(-math.atan2(ydif,xdif)-player.facing) < 0.76 then
        return true
    else
        return false
    end
end

function addon_message(str)
    windower.add_to_chat(207, _addon.name..': '..str)
end

windower.register_event('addon command', function(...)
    local commands = {...}
    if commands[1] then
        commands[1] = commands[1]:lower()
        if commands[1] == 'on' then
            find_extra_song_harp()
            setting.actions = true
            addon_message('actions On')
        elseif commands[1] == 'off' then
            setting.actions = false
            addon_message('actions Off')
        elseif commands[1] == 'song' and commands[4] then
            local player = commands[2]:lower()
            local buff = commands[3]:lower()
            if not buff_songs[buff] then return end
            if not setting.song[player] then setting.song[player] = {} end
            if commands[4] ~= '0' and tonumber(commands[4]) then
                setting.song[player][buff] = tonumber(commands[4])
               addon_message('Will now Pianissimo %s x%d for %s.':format(buff,commands[4],player))
            elseif commands[4] == '0' or commands[4]:lower() == 'off' then
                setting.song[player][buff] = nil
                addon_message('Will no longer Pianissimo %s for %s.':format(buff,player))
            end
        elseif commands[1] == 'aoe' and commands[3] then
            local player = commands[2]:lower()
            if commands[3] == '+' and player then
                setting.aoe[player] = true
                addon_message('Will now ensure %s is in AoE casting range.':format(player))
            elseif commands[3] == '-' and player then
                setting.aoe[player] = false
                addon_message('%s will now be ignored for AoE.':format(player))
            end
        elseif commands[1] == 'clarion' and commands[2] then
            if commands[3] and setting.song[commands[2]:lower()] and buff_songs[commands[3]:lower()] then
                setting.clarion[commands[2]:lower()] = commands[3]:lower()
                addon_message('Clarion song for %s set to %s':format(commands[2],commands[3]))
            elseif buff_songs[commands[2]:lower()] then
                setting.clarion.aoe = table.concat(commands, ' ',2):lower()
                addon_message('Clarion AoE song set to %s':format(commands[2]):lower())
            end
        elseif commands[1] == 'save' then
            setting:save()
            addon_message('settings saved.')
        elseif commands[1] == 'active' then
            local str = 'Active Settings\n'
            for k,v in pairs(setting.songs) do
                str = str..'%s:[x%d] ':format(k:ucfirst(),v)
            end
            str = str..'Clarion:[%s] Marcaro:[%s]\nDummy1:[%s] Dummy2:[%s]':format(setting.clarion.aoe,setting.marcato,setting.dummy1,setting.dummy2)
            str = str..'\nPianissimo:[%s] ':format(setting.pianissimo and 'On' or 'Off')
            for k,v in pairs(setting.song) do
                str=str..'%s':format(k:ucfirst())
                for i,t in pairs(v) do
                    str = str..':[%s x%d]':format(i,t)
                end
                if setting.clarion[k] then
                    str = str..' Clarion:[%s]':format(setting.clarion[k])
                end
                str= str..'\n'
            end
            for k,v in pairs(default) do
                if type(v) == 'number' then
                    str = str..'%s:[%d] ':format(k:ucfirst(),setting[k])
                end
            end
            addon_message(str)
        elseif commands[1] == 'eval' then
             assert(loadstring(table.concat(commands, ' ',2)))()
        elseif buff_songs[commands[1]] and commands[2] then
            if commands[2] ~= '0' and tonumber(commands[2]) then
                setting.songs[commands[1]] = tonumber(commands[2])
                addon_message('%s x%d':format(commands[1],commands[2]))
            elseif commands[2] == '0' or commands[2]:lower() == 'off' then
                setting.songs[commands[1]] = nil
                addon_message('%s Off':format(commands[1]))
            end
        elseif type(setting[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
            setting[commands[1]] = tonumber(commands[2])
            addon_message('%s is now set to %d':format(commands[1],setting[commands[1]]))
        elseif type(setting[commands[1]]) == 'string' then
            setting[commands[1]] = table.concat(commands, ' ',2):lower()
             addon_message('%s is now set to %s':format(commands[1],setting[commands[1]]))
        elseif type(setting[commands[1]]) == 'boolean' then
            if not commands[2] and setting[commands[1]] == true or commands[2] and commands[2]:lower() == 'off' then
                setting[commands[1]] = false
            elseif not commands[2] or commands[2] and commands[2]:lower() == 'on' then
                setting[commands[1]] = true 
            end
            addon_message('%s %s':format(commands[1],setting[commands[1]] and 'On' or 'Off'))
        end
    end
    bard_status:text(display_box())
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

function aoe_range()
    for k,v in ipairs(setting.aoe) do
        if not valid_target(v,10) then
            return false
        end
    end
    return true
end

function song_to_buff(song,bool)
    for id,buff in ipairs(buff_ids) do
        if string.find(song,buff) then
            return bool and id,buff or buff
        end
    end
end

function get_song_id(song)
    for k,v in pairs(song_id) do
        if v:lower() == song:lower() then
            return k
        end
    end
    return nil
end

function get_song(song)
    for k,v in pairs(song_id) do
        if v:lower() == song:lower() then
            return v
        end
    end
    return nil
end

function equip(slot)
    local item = windower.ffxi.get_items().equipment
    return equipment[windower.ffxi.get_items(item[slot..'_bag'],item[slot]).id] or ''
end

function calculate_duration(name,buffs)
    local mult = 1
    if equip('range') == 'Daurdabla' then mult = mult + 0.3 end    -- 0.25 for 90, 0.3 for 99
    if equip('range') == 'Gjallarhorn' then mult = mult + 0.4 end  -- 0.3 for 95, 0.4 for 99
    if equip('main') == 'Carnwenhan' then mult = mult + 0.5 end    -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
    if equip('main') == 'Legato Dagger' then mult = mult + 0.05 end
    if equip('sub') == 'Legato Dagger' then mult = mult + 0.05 end
    if equip('neck') == 'Aoidos\' Matinee' then mult = mult + 0.1 end
    if equip('body') == 'Aoidos\' Hngrln. +2' then mult = mult + 0.1 end
    if equip('legs') == 'Mdk. Shalwar +1' then mult = mult + 0.1 end
    if equip('feet') == 'Brioso Slippers' then mult = mult + 0.1 end
    if equip('feet') == 'Brioso Slippers +1' then mult = mult + 0.11 end
    if equip('body') == 'Fili Hongreline' then mult = mult + 0.11 end
    if equip('body') == 'Fili Hongreline +1' then mult = mult + 0.12 end
    if string.find(name,'March') and (equip('hands') == 'Ad. Mnchtte. +2' or string.find(equip('hands'),'Fili Manchettes')) then mult = mult + 0.1 end
    if string.find(name,'Minuet') and (equip('body') == 'Aoidos\' Hngrln. +2' or string.find(equip('body'),'Fili Hongreline')) then mult = mult + 0.1 end
    if string.find(name,'Madrigal') and (equip('head') == 'Aoidos\' Calot +2' or string.find(equip('head'),'Fili Calot')) then mult = mult + 0.1 end
    if string.find(name,'Ballad') and (equip('legs') == 'Aoidos\' Rhing. +2' or string.find(equip('legs'),'Fili Rhingrave')) then mult = mult + 0.1 end
    if string.find(name,'Scherzo') and (equip('feet') == 'Aoidos\' Cothrn. +2' or string.find(equip('feet'),'Fili Cothurnes')) then mult = mult + 0.1 end
    if string.find(name,'Paeon') and string.find(equip('head'),'Brioso Roundlet') then mult = mult + 0.1 end
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
        local play = windower.ffxi.get_player()
        local targ = windower.ffxi.get_mob_by_id(packet['Target 1 ID']).name
        local actor = windower.ffxi.get_mob_by_id(packet['Actor']).name
        if packet['Category'] == 8 and actor == play.name then
            if (packet['Param'] == 24931) then
            -- Begin Casting
                casting = true
            elseif (packet['Param'] == 28787) then
            -- Failed Casting
                casting = false
                del = 2.5
            end
        elseif packet['Category'] == 4 and actor == play.name then
            -- Finish Casting
            casting = false
            del = setting.delay
            if not song_id[packet['Param']] then return end
            local buffs = calculate_buffs(play.buffs)
            local spell_name = song_id[packet['Param']]
            
            
            
            
            
            if packet['Target Count'] > 1 or targ == play.name and table.length(timers['AoE']) < base_songs then
                adjust_timers(spell_name,'AoE',buffs)
            end
            for x = 1,packet['Target Count'] do
                local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                adjust_timers(spell_name,targ_name,buffs)
            end
        elseif packet['Category'] == 7 and actor == play.name then
            casting = true
        elseif packet['Category'] == 9 and actor == play.name then
            casting = true
        elseif packet['Category'] == 3 and actor == play.name then
            casting = false
        elseif packet['Category'] == 5 and actor == play.name then
            casting = false
        end
    elseif id == 0x029 then
        local packet = packets.parse('incoming', original)
        --table.vprint(packet)
        local play = windower.ffxi.get_player().name
        local targ = windower.ffxi.get_mob_by_id(packet['Target']).name
        local actor = windower.ffxi.get_mob_by_id(packet['Actor']).name
        if (packet.Message) == 206 and actor == play then
            local buff = buff_ids[packet['Param 1']]
            --print(targ_name,res.buffs[packet['Param 1']].en)
            if buff then buff_lost(targ,buff) end
        end
    end
end)

function buff_lost(targ,buff)
    local buff = buff_songs[buff:lower()]
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
    if not setting.song[targ] then delete_timer(song,'AoE') end
    delete_timer(song,targ)
end

function update_timers(targ)
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

function aug_maxsongs(targ,buffs)
    local maxsongs = base_songs
    if buffs['clarion call'] then
        maxsongs = maxsongs + 1 
    end
    if maxsongs < table.length(timers[targ]) then
        maxsongs = table.length(timers[targ])
    end
    return maxsongs
end

function delete_timer(song,targ)
    timers[targ][song] = nil
    windower.send_command('timers delete "%s [%s]"':format(song,targ))
end

function create_timer(song,targ,dur,current_time,buffs)
    timers[targ][song] = {ts=current_time+dur,nt=buffs.troubadour,sv=buffs['soul voice']}
    if timers.AoE[song] and targ ~= 'AoE' or not setting.display then return end
    windower.send_command('timers create "%s [%s]" %s down':format(song,targ,dur))
end
              
function adjust_timers(spell_name,targ,buffs)
    local current_time = os.time()
    local dur = calculate_duration(spell_name,buffs)
    update_timers(targ)
    if timers[targ][spell_name] then
        if timers[targ][spell_name].ts < (current_time + dur) then
            create_timer(spell_name,targ,dur,current_time,buffs)
        end
    else
        if table.length(timers[targ]) < aug_maxsongs(targ,buffs) then
            create_timer(spell_name,targ,dur,current_time,buffs)
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
                delete_timer(repsong,targ)
                create_timer(spell_name,targ,dur,current_time,buffs)
            end
        end
    end
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

function change()
    setting.actions = false
    casting = false
    reset_timers()
    bard_status:text(display_box())
end

function status_change(new,old)
    casting = false
    if new == 2 or new == 3 then
        change()
    end
end

windower.register_event('unload', reset_timers)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', change)
