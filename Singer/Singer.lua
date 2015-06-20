_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.15.06.18'

require('pack')
packets = require('packets')
texts = require('texts')
config = require('config')

ids = require('sing_ids')
get = require('sing_get')
cast = require('sing_cast')
song_timers = require('song_timers')

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

windower.register_event('prerender',function ()
    if not setting.actions then return end
    local curtime = os.clock()
    if nexttime + del <= curtime then
        nexttime = curtime
        del = 0.1
        for k,v in pairs(timers) do song_timers.update(k) end
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        local JA_WS_lock,AM_start,goal_tp
        local moving = get.moving()
        local buffs = get.buffs(play.buffs)
        local spell_recasts = windower.ffxi.get_spell_recasts()
        local ability_recasts = windower.ffxi.get_ability_recasts()
        local recast = math.random(setting.recast,setting.recast+10)+math.random()
        if moving or casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end
        if not JA_WS_lock and play.status == 1 and equip('main') == 'Carnwenhan' then
            local targ = windower.ffxi.get_mob_by_target('t')
            if not AM_start and buffs['aftermath: lv.3'] then AM_start = curtime end
            if buffs['aftermath: lv.3'] and AM_start and curtime - AM_start <= 140 then goal_tp = 1000 else goal_tp = 3000 end
            if (get.eye_sight(windower.ffxi.get_mob_by_target('me'),targ) and play.vitals.tp >= goal_tp and 
            targ and targ.valid_target and targ.is_npc and targ.hpp < setting.max_ws and targ.hpp > setting.min_ws and  
            math.sqrt(targ.distance) <= 4) and ((goal_tp == 3000 and not buffs['aftermath: lv.3']) or goal_tp == 1000) then
                if goal_tp == 3000 then AM_start = curtime end
                windower.send_command('input /ws "Mordant Rime" <t>')
                del = 4.2
                return
            end
        end
        if buffs.silence or buffs.mute or buffs.omerta then return end     
        if get.aoe_range() then
            local song = cast.check_song(setting.songs,'AoE',buffs,spell_recasts,recast) 
            if song then cast.song(song,'<me>',buffs,ability_recasts,JA_WS_lock) return end
        end
        if setting.pianissimo then
            for targ,songs in pairs(setting.song) do
                if get.valid_target(targ,20) then
                    local targ = targ:ucfirst()
                    local song = cast.check_song(songs,targ,buffs,spell_recasts,recast) 
                    if song then cast.song(song,targ,buffs,ability_recasts,JA_WS_lock) return end
                end
            end
        end
        if table.length(setting.buffs.haste)+table.length(setting.buffs.refresh) == 0 then return end
        local rebuff = math.random(8,24)+math.random()
        for key,targets in pairs(setting.buffs) do
            local spell = get.spell(key)
            for targ,v in pairs(targets) do
                if v and spell and spell_recasts[spell.id] <= 0 and get.valid_target(targ,20) and play.vitals.mp >= 40 and
                (not timers.buffs or not timers.buffs[spell.enl] or not timers.buffs[spell.enl][targ] or 
                os.time() - timers.buffs[spell.enl][targ]+rebuff > 0) then
                    cast.MA(spell.enl,targ)
                    return
                end
            end
        end
    end
end)

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
            local spell = ids.spells[packet['Param']]
            if spell then timers.buffs[spell.enl][targ:lower()] = os.time()+spell.dur return end
            if not ids.songs[packet['Param']] then return end
            local buffs = get.buffs(play.buffs)
            local spell_name = ids.songs[packet['Param']]
            
            if packet['Target Count'] > 1 then--or targ == play.name and table.length(timers['AoE']) < base_songs then
                song_timers.adjust(spell_name,'AoE',buffs)
            end
            for x = 1,packet['Target Count'] do
                local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                song_timers.adjust(spell_name,targ_name,buffs)
            end
            
        elseif L{3,5}:contains(packet['Category']) and actor == play.name then
            casting = false   
        elseif L{7,9}:contains(packet['Category']) and actor == play.name then
            casting = true
        end
    elseif id == 0x029 then
        local packet = packets.parse('incoming', original)
        --table.vprint(packet)
        local play = windower.ffxi.get_player().name
        local targ = windower.ffxi.get_mob_by_id(packet['Target']).name
        local actor = windower.ffxi.get_mob_by_id(packet['Actor']).name
        if (packet.Message) == 206 and actor == play then
            local buff = ids.buffs[packet['Param 1']]
            --print(targ_name,res.buffs[packet['Param 1']].en)
            if buff then 
                song_timers.buff_lost(targ,buff) 
            end
        end
    end
end)

function addon_message(str)
    windower.add_to_chat(207, _addon.name..': '..str)
end

windower.register_event('addon command', function(...)
    local commands = {...}
    for x=1,#commands do commands[x] = windower.convert_auto_trans(commands[x]):lower() end
    if not commands[1] or S{'on','off'}:contains(commands[1]) then
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
            local song = get.song(table.concat(commands, ' ',2))
            if song and ind <= 2 then
                setting.dummy[ind] = song
                addon_message('Dummy song #%d set to %s':format(ind,song))
            else
                addon_message('Invalid song name.')
            end
        elseif S{'haste','refresh'}:contains(commands[1]) and commands[2] then
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
        elseif buff_songs[commands[1]] and commands[2] then
            local n = tonumber(commands[2])
            if n and n ~= 0 and n <= #buff_songs[commands[1]] then
                if commands[3] then
                    if not setting.song[commands[3]] then setting.song[commands[3]] = {} end
                    setting.song[commands[3]][commands[1]] = n
                    addon_message('Will now Pianissimo %s x%d for %s.':format(commands[1],n,commands[3]))
                else
                    setting.songs[commands[1]] = n
                    addon_message('%s x%d':format(commands[1],n))
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
            local song = get.song(table.concat(commands, ' ',2))
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
        elseif commands[1] == 'eval' then
            assert(loadstring(table.concat(commands, ' ',2)))()
        end
    end
    bard_status:text(display_box())
end)

function event_change()
    setting.actions = false
    casting = false
    song_timers.reset()
    bard_status:text(display_box())
end

function status_change(new,old)
    casting = false
    if new == 2 or new == 3 then
        event_change()
    end
end

windower.register_event('unload', song_timers.reset)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', event_change)
