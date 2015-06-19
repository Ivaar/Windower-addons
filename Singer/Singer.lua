_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.15.06.18'

require('pack')
packets = require('packets')
texts = require('texts')
song_id = require('spells')
config = require('config')

default = {
    delay=4,
    dummy=L{'Knight\'s Minne','Knight\'s Minne II'},
    buffs={['haste']={},['refresh']={}},
    marcato='Sentinel\'s Scherzo',
    clarion={aoe='minuet'},
    actions=false,
    pianissimo=false,
    recast=20,
    active=true,
    timers=true,
    aoe={},
    song={},
    songs={march=2},
    min_ws=20,
    max_ws=99,
    box={text={size=10}}
    }

setting = config.load(default)

nexttime = os.clock()
del = 0
timers = {AoE={},buffs={Haste={},Refresh={}}}

equipment = L{
    [18571] = 'Daurdabla',--99
    [18572] = 'Gjallarhorn',--99
    [18575] = 'Daurdabla',--90
    [18576] = 'Daurdabla',--95
    [18839] = 'Daurdabla',--99-2
    [18840] = 'Gjallarhorn',--99-2
    [20561] = 'Carnwenhan',--119
    [20562] = 'Carnwenhan',--119-2
    [20629] = 'Legato Dagger',
    [27672] = 'Brioso Roundlet',
    [27693] = 'Brioso Roundlet +1',
    [28074] = 'Mdk. Shalwar +1',
    [28232] = 'Brioso Slippers',
    [28253] = 'Brioso Slippers +1',
    [11073] = 'Aoidos\' Calot +2',
    [11093] = 'Aoidos\' Hngrln. +2',
    [11113] = 'Ad. Mnchtte. +2',
    [11133] = 'Aoidos\' Rhing. +2',
    [11153] = 'Aoidos\' Cothrn. +2',
    [11618] = 'Aoidos\' Matinee',
    [21400] = 'Blurred Harp',
    [21401] = 'Blurred Harp +1',    
    [21407] = 'Terpander',
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
    
buff_spells = L{
    [57] = {id=57,enl='Haste',dur=180},
    [109] = {id=109,enl='Refresh',dur=150},
    }
    
buff_songs = {
    paeon = {[1]='Army\'s Paeon VI',[2]='Army\'s Paeon V',[3]='Army\'s Paeon IV',[4]='Army\'s Paeon III',[5]='Army\'s Paeon II',[6]='Army\'s Paeon'},
    ballad = {[1]='Mage\'s Ballad III',[2]='Mage\'s Ballad II',[3]='Mage\'s Ballad'},
    minne = {[1]='Knight\'s Minne V',[2]='Knight\'s Minne IV',[3]='Knight\'s Minne III',[4]='Knight\'s Minne II',[5]='Knight\'s Minne'},
    march = {[1]='Victory March',[2]='Advancing March'},
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
    hymnus = {[1]='Goddess\'s Hymnus'},
    mazurka = {[1]='Chocobo Mazurka'},
    sirvente = {[1]='Foe Sirvente'},
    dirge = {[1]='Adventurer\'s Dirge'},
    scherzo = {[1]='Sentinel\'s Scherzo'},
    }

local display_box = function()
    local str
    if setting.actions then
        str = 'Singer: Actions [On]'
    else
        str = 'Singer: Actions [Off]'
    end
    if not setting.active then return str end
    for k,v in pairs(setting.songs) do
        str = str..'\n %s:[x%d]':format(k:ucfirst(),v)
    end
    str = str..'\n Clarion:[%s]\n Marcato:\n   [%s]':format(setting.clarion.aoe:ucfirst(),setting.marcato)
    str = str..'\n Dummy Songs:\n   1:[%s]\n   2:[%s]\n Pianissimo:[%s]':format(setting.dummy[1],setting.dummy[2],setting.pianissimo and 'On' or 'Off')
    for k,v in pairs(setting.song) do
        str=str..'\n %s:':format(k:ucfirst())
        for i,t in pairs(v) do
            str = str..'\n   %s:[x%d]':format(i:ucfirst(),t)
        end
        if setting.clarion[k] then
            str = str..'\n   Clarion:[%s]':format(setting.clarion[k]:ucfirst())
        end
    end
    for k,v in pairs(setting.aoe) do
        str = v and str..'\n AoE Target:[%s]':format(k:ucfirst()) or str
    end
    for k,v in pairs(setting.buffs.haste) do
        if v then str = str..'\n Haste:[%s]':format(k:ucfirst()) end
    end
    for k,v in pairs(setting.buffs.refresh) do
        if v then str = str..'\n Refresh:[%s]':format(k:ucfirst()) end
    end
    str = str..'\n Delay:[%s] Recast:[%s]\n WS:[ > %d%%][ < %s%%]':format(setting.delay,setting.recast,setting.min_ws,setting.max_ws)
    return str
end

bard_status = texts.new(display_box(),setting.box,setting)
bard_status:show()

function find_item(...)
    local ids = L{...}
    local items = windower.ffxi.get_items()
    for i,v in ipairs(items.inventory) do
        if ids:contains(v.id) then
            return true
        end
    end
    for i,v in ipairs(items.wardrobe) do
        if ids:contains(v.id) then
            return true
        end
    end
    return false
end

function find_extra_song_harp()
    if find_item(18571,18839) then
        base_songs = 4
    elseif find_item(21407,18575,18576,21400,21401) then
        base_songs = 3
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
        for k,v in pairs(timers) do update_timers(k) end
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        local JA_WS_lock,AM_start,goal_tp
        local moving = is_moving()
        local buffs = calculate_buffs(play.buffs)
        local spell_recasts = windower.ffxi.get_spell_recasts()
        local ability_recasts = windower.ffxi.get_ability_recasts()
        local recast = math.random(setting.recast,setting.recast+10)+math.random()
        if moving or casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end
        if not JA_WS_lock and play.status == 1 and equip('main') == 'Carnwenhan' then
            local targ = windower.ffxi.get_mob_by_target('t')
            if not AM_start and buffs['aftermath: lv.3'] then AM_start = curtime end
            if buffs['aftermath: lv.3'] and AM_start and curtime - AM_start <= 140 then goal_tp = 1000 else goal_tp = 3000 end
            if (eye_sight(windower.ffxi.get_mob_by_target('me'),targ) and play.vitals.tp >= goal_tp and 
            targ and targ.valid_target and targ.is_npc and targ.hpp < setting.max_ws and targ.hpp > setting.min_ws and  
            math.sqrt(targ.distance) <= 4) and ((goal_tp == 3000 and not buffs['aftermath: lv.3']) or goal_tp == 1000) then
                if goal_tp == 3000 then AM_start = curtime end
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
        if setting.pianissimo then
            for targ,songs in pairs(setting.song) do
                if valid_target(targ,20) then
                    local targ = targ:ucfirst()
                    local song = check_song(songs,targ,buffs,spell_recasts,recast) 
                    if song then cast_song(song,targ,buffs,ability_recasts,JA_WS_lock) return end
                end
            end
        end
        if table.length(setting.buffs.haste)+table.length(setting.buffs.refresh) == 0 then return end
        local rebuff = math.random(8,24)+math.random()
        for key,targets in pairs(setting.buffs) do
            local spell = get_spell(key)
            for targ,v in pairs(targets) do
                if v and spell and spell_recasts[spell.id] <= 0 and valid_target(targ,20) and play.vitals.mp >= 40 and
                (not timers.buffs or not timers.buffs[spell.enl] or not timers.buffs[spell.enl][targ] or 
                os.time() - timers.buffs[spell.enl][targ]+rebuff > 0) then
                    use_MA(spell.enl,targ)
                    return
                end
            end
        end
    end
end)

function get_spell(spell)
    for k,v in pairs(buff_spells) do
        if buff_spells[k] and v.enl:lower() == spell:lower() then
            return v
        end
    end
    return nil
end

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

function aug_songs(songs,targ,maxsongs)
    local song_list = {}
    local clarion = setting.clarion[targ:lower()]
    for k,v in pairs(songs) do
        song_list[k] = v
    end
    if clarion and maxsongs > base_songs then
        song_list[clarion] = (song_list[clarion] or 0) + 1 
    end
    return song_list
end

function check_song(songs,targ,buffs,spell_recasts,recast)
    local maxsongs = aug_maxsongs(targ,buffs)
    local song_list = aug_songs(songs,targ,maxsongs)
    for k,song in ipairs(setting.dummy) do
        if base_songs >= k+2 and timers[targ] and table.length(timers[targ]) == maxsongs-k and spell_recasts[get_song_id(song)] <= 0 then
            return song
        end
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

function valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and 
        member.mob.in_party and member.mob.hpp > 0 and 
        member.mob.name:lower() == targ:lower() and 
        math.sqrt(member.mob.distance) < dst and 
        not member.mob.charmed then
           return true
        end
    end
    return false
end


function aoe_range()
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and 
        member.mob.in_party and member.mob.hpp > 0 and 
        setting.aoe[member.mob.name:lower()] and 
        math.sqrt(member.mob.distance) >= 10 and
        not member.mob.charmed then
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

function addon_message(str)
    windower.add_to_chat(207, _addon.name..': '..str)
end

windower.register_event('addon command', function(...)
    local commands = {...}
    for x=1,#commands do commands[x] = windower.convert_auto_trans(commands[x]):lower() end
    if not commands[1] or S{'on','off'}:contains(commands[1]) then
        find_extra_song_harp()
        if not commands[1] then
            setting.actions = not setting.actions
        elseif commands[1] == 'on' then
            setting.actions = true
        elseif commands[1] == 'off' then
            setting.actions = false
        end
        addon_message('Actions %s':format(setting.actions and 'On' or 'Off'))
    else
        if commands[1] == 'save' then
            setting:save()
            addon_message('Settings Saved.')
        elseif commands[1] == 'aoe' and commands[3] then
            if commands[3] == '+' then
                setting.aoe[commands[2]] = true
                addon_message('Will now ensure %s is in AoE range.':format(commands[2]))
            elseif commands[3] == '-' then
                setting.aoe[commands[2]] = false
                addon_message('%s will now be ignored for AoE.':format(commands[2]))
            end
        elseif commands[1] == 'clarion' and commands[2] and buff_songs[commands[2]] then
            if commands[3] and setting.song[commands[3]]then
                setting.clarion[commands[3]] = commands[2]
                addon_message('Clarion song for %s set to %s':format(commands[3],commands[2]))
            else
                setting.clarion.aoe = commands[2]
                addon_message('Clarion AoE song set to %s':format(commands[2]))
            end
        elseif commands[1] == 'ws' and commands[3] and tonumber(commands[3]) then
            if commands[2] == '<' then
                setting.max_ws = tonumber(commands[3])
            elseif commands[2] == '>' then
                setting.min_ws = tonumber(commands[3])
            end
       elseif commands[1]:startswith('dummy') then
            local ind = tonumber(commands[1]:sub(6)) or 1
            local song = get_song(table.concat(commands, ' ',2))
            if song and ind <= 2 then
                setting.dummy[ind] = song
                addon_message('Dummy song #%d set to %s':format(ind,song))
            else
                addon_message('Invalid song name.')
            end
       elseif buff_songs[commands[1]] and commands[2] then
            local n = tonumber(commands[2])
            if n and n ~= 0 and n <= #buff_songs[commands[1]] then
                if commands[3] then
                    if not setting.song[commands[3]] then setting.song[commands[3]] = {} end
                    setting.song[commands[3]][commands[1]] = n
                    addon_message('Will now Pianissimo %s x%d for %s.':format(commands[1],commands[2],commands[3]))
                else
                    setting.songs[commands[1]] = tonumber(commands[2])
                    addon_message('%s x%d':format(commands[1],commands[2]))
                end
            elseif commands[2] == '0' or commands[2] == 'off' then
                if commands[3] then
                    setting.song[commands[3]][commands[1]] = nil
                    addon_message('Will no longer Pianissimo %s for %s.':format(commands[1],commands[3]))
                else               
                    setting.songs[commands[1]] = nil
                    addon_message('%s Off':format(commands[1]))
                end
            elseif n then
                addon_message('Error: %d exceeds the maximum value for %s.':format(n,commands[1]))
            end
        elseif type(setting[commands[1]]) == 'string' and commands[2] then
            local song = get_song(table.concat(commands, ' ',2))
            if song then
                setting[commands[1]] = song
                addon_message('%s is now set to %s':format(commands[1],song))
            else
                addon_message('Invalid song name.')
            end
       elseif type(setting[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
            setting[commands[1]] = tonumber(commands[2])
            addon_message('%s is now set to %d':format(commands[1],setting[commands[1]]))
        elseif type(setting[commands[1]]) == 'boolean' then
            if (not commands[2] and setting[commands[1]] == true) or (commands[2] and commands[2] == 'off') then
                setting[commands[1]] = false
                if commands[1] == 'timers' then reset_timers(true) end
            elseif (not commands[2]) or (commands[2] and commands[2] == 'on') then
                setting[commands[1]] = true
            end
            addon_message('%s %s':format(commands[1],setting[commands[1]] and 'On' or 'Off'))
        elseif get_spell(commands[1]) and commands[2] then
            if not commands[3] then
                if setting.buffs[commands[1]][commands[2]] then
                    setting.buffs[commands[1]][commands[2]] = nil
                else
                    setting.buffs[commands[1]][commands[2]] = true
                end
            elseif commands[3] == 'on' then
                setting.buffs[commands[1]][commands[2]] = true
            elseif commands[3] == 'off' then
                setting.buffs[commands[1]][commands[2]] = nil
            end
        elseif commands[1] == 'eval' then
            assert(loadstring(table.concat(commands, ' ',2)))()
        end
    end
    bard_status:text(display_box())
end)

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
            local spell = buff_spells[packet['Param']]
            if spell then timers.buffs[spell.enl][targ:lower()] = os.time()+spell.dur return end
            if not song_id[packet['Param']] then return end
            local buffs = calculate_buffs(play.buffs)
            local spell_name = song_id[packet['Param']]
            
            --
            if packet['Target Count'] > 1 then--or targ == play.name and table.length(timers['AoE']) < base_songs then
                adjust_timers(spell_name,'AoE',buffs)
            end
            for x = 1,packet['Target Count'] do
                local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                adjust_timers(spell_name,targ_name,buffs)
            end
            --
            
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

function delete_timer(song,targ)
    timers[targ][song] = nil
    windower.send_command('timers delete "%s [%s]"':format(song,targ))
end

function create_timer(song,targ,dur,current_time,buffs)
    timers[targ][song] = {ts=current_time+dur,nt=buffs.troubadour,sv=buffs['soul voice']}
    if timers.AoE[song] and targ ~= 'AoE' or not setting.timers then return end
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

function reset_timers(bool)
    for k,targ in pairs(timers) do
        for i,v in pairs(targ) do
            windower.send_command('timers delete "%s [%s]"':format(i,k))
        end
    end
    if bool then return end
    timers = {AoE={},buffs={Haste={},Refresh={}}}
    casting = false
end

function event_change()
    setting.actions = false
    casting = false
    reset_timers()
    bard_status:text(display_box())
end

function status_change(new,old)
    casting = false
    if new == 2 or new == 3 then
        event_change()
    end
end

windower.register_event('unload', reset_timers)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', event_change)
