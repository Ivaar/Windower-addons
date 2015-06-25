_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.15.06.24'
require('luau')
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
    buffs={['haste']=L{},['refresh']=L{}},
    marcato='Sentinel\'s Scherzo',
    clarion={aoe='minuet'},
    actions=false,
    pianissimo=false,
    recast={song={min=20,max=25},buff={min=5,max=10}},
    active=true,
    timers=true,
    ignore=L{},
    song={},
    songs={march=2},
    min_ws=20,
    max_ws=99,
    box={text={size=10}}
    }

settings = config.load(default)

nexttime = os.clock()
del = 0
timers = {AoE={},buffs={Haste={},Refresh={}}}

local display_box = function()
    local str
    if settings.actions then
        str = 'Singer: Actions [On]'
    else
        str = 'Singer: Actions [Off]'
    end
    if not settings.active then return str end
    for k,v in pairs(settings.songs) do
        str = str..'\n %s:[x%d]':format(k:ucfirst(),v)
    end
    str = str..'\n Clarion:[%s]\n Marcato:\n   [%s]':format(settings.clarion.aoe:ucfirst(),settings.marcato)
    str = str..'\n Dummy (Songs):\n   1:[%s]\n   2:[%s]\n Pianissimo:[%s]':format(settings.dummy[1],settings.dummy[2],settings.pianissimo and 'On' or 'Off')
    for k,v in pairs(settings.song) do
        str = str..'\n %s:':format(k:ucfirst())
        for i,t in pairs(v) do
            str = str..'\n   %s:[x%d]':format(i:ucfirst(),t)
        end
        if settings.clarion[k] then
            str = str..'\n   Clarion:[%s]':format(settings.clarion[k]:ucfirst())
        end
    end
    for k,v in ipairs(settings.ignore) do
        str = str..'\n Ignore:[%s]':format(v:ucfirst())
    end
    for k,v in ipairs(settings.buffs.haste) do
       str = str..'\n Haste:[%s]':format(v:ucfirst())
    end
    for k,v in ipairs(settings.buffs.refresh) do
        str = str..'\n Refresh:[%s]':format(v:ucfirst())
    end
    for k,v in pairs(settings.recast) do
        str = str..'\n Recast %s:[%d-%d]':format(k:ucfirst(),v.min,v.max)
    end
    str = str..'\n Delay:[%d] \n WS:[ > %d%%][ < %d%%]':format(settings.delay,settings.min_ws,settings.max_ws)
    return str
end

bard_status = texts.new(display_box(),settings.box,settings)
bard_status:show()

windower.register_event('prerender',function ()
    if not settings.actions then return end
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
        local recast = math.random(settings.recast.song.min,settings.recast.song.max)+math.random()
        if moving or casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end
        if not JA_WS_lock and play.status == 1 and equip('main') == 'Carnwenhan' then
            local targ = windower.ffxi.get_mob_by_target('t')
            if not AM_start and buffs['aftermath: lv.3'] then AM_start = curtime end
            if buffs['aftermath: lv.3'] and AM_start and curtime - AM_start <= 140 then goal_tp = 1000 else goal_tp = 3000 end
            if (get.eye_sight(windower.ffxi.get_mob_by_target('me'),targ) and play.vitals.tp >= goal_tp and 
            targ and targ.valid_target and targ.is_npc and targ.hpp < settings.max_ws and targ.hpp > settings.min_ws and  
            math.sqrt(targ.distance) <= 4) and ((goal_tp == 3000 and not buffs['aftermath: lv.3']) or goal_tp == 1000) then
                if goal_tp == 3000 then AM_start = curtime end
                windower.send_command('input /ws "Mordant Rime" <t>')
                del = 4.2
                return
            end
        end
        if buffs.silence or buffs.mute or buffs.omerta then return end     
        if get.aoe_range() then
            local song = cast.check_song(settings.songs,'AoE',buffs,spell_recasts,recast) 
            if song then cast.song(song,'<me>',buffs,ability_recasts,JA_WS_lock) return end
        end
        if settings.pianissimo then
            for targ,songs in pairs(settings.song) do
                if get.valid_target(targ,20) then
                    local targ = targ:ucfirst()
                    local song = cast.check_song(songs,targ,buffs,spell_recasts,recast) 
                    if song then cast.song(song,targ,buffs,ability_recasts,JA_WS_lock) return end
                end
            end
        end
        if table.length(settings.buffs.haste)+table.length(settings.buffs.refresh) == 0 then return end
        local recast = math.random(settings.recast.buff.min,settings.recast.buff.max)+math.random()
        for key,targets in pairs(settings.buffs) do
            local spell = get.spell(key)
            for k,targ in ipairs(targets) do
                if targ and spell and spell_recasts[spell.id] <= 0 and get.valid_target(targ,20) and play.vitals.mp >= 40 and
                (not timers.buffs or not timers.buffs[spell.enl] or not timers.buffs[spell.enl][targ] or 
                os.time() - timers.buffs[spell.enl][targ]+recast > 0) then
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
        if not play then return end
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
            del = settings.delay
            local spell = ids.spells[packet['Param']]
            if spell then timers.buffs[spell.enl][targ:lower()] = os.time()+spell.dur return end
            if not ids.songs[packet['Param']] then return end
            local buffs = get.buffs(play.buffs)
            local spell_name = ids.songs[packet['Param']]
            if packet['Target Count'] > 1 or targ == play.name and get.aoe_range() then
                song_timers.adjust(spell_name,'AoE',buffs)
            end
            for x = 1,packet['Target Count'] do
                local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                if not settings.ignore:contains(targ:lower()) then
                    song_timers.adjust(spell_name,targ_name,buffs)
                end
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
            if buff and not settings.ignore:contains(targ:lower()) then 
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
            settings.actions = not settings.actions
        elseif commands[1] == 'on' then
            settings.actions = true
        elseif commands[1] == 'off' then
            settings.actions = false
        end
        addon_message('Actions %s':format(settings.actions and 'On' or 'Off'))
    else
        if commands[1] == 'save' then
            settings:save()
            addon_message('settingss Saved.')
        elseif commands[1] == 'ignore' and commands[3] then
            local ind = settings.ignore:find(commands[2])
            if ind and (not commands[3] or commands[3] and commands[3] == '-') then
                settings.ignore:remove(ind)
                addon_message('Will no longer ignore %s.':format(commands[2]:ucfirst()))
           elseif not ind then
                settings.ignore:append(commands[2])
                addon_message('%s will now be ignored.':format(commands[2]:ucfirst()))
            end
        elseif commands[1] == 'recast' and commands[2] and S{'buff','song'}:contains(commands[2]) then
            if commands[3] and tonumber(commands[3]) then
                settings.recast[commands[2]].min = tonumber(commands[3])
            end
            if commands[4] and tonumber(commands[4]) then
                settings.recast[commands[2]].max = tonumber(commands[4])
            end
            addon_message('%s recast set to min: %s max: %s':format(commands[2],settings.recast[commands[2]].min,settings.recast[commands[2]].max))
        elseif commands[1] == 'clarion' and commands[2] and get.songs[commands[2]] then
            if commands[3] and settings.song[commands[3]] then
                settings.clarion[commands[3]] = commands[2]
                addon_message('Clarion song for %s set to %s':format(commands[3],commands[2]))
            else
                settings.clarion.aoe = commands[2]
                addon_message('Clarion AoE song set to %s':format(commands[2]))
            end
        elseif commands[1] == 'ws' and commands[3] and tonumber(commands[3]) then
            if commands[2] == '<' then
                settings.max_ws = tonumber(commands[3])
            elseif commands[2] == '>' then
                settings.min_ws = tonumber(commands[3])
            end
       elseif commands[1]:startswith('dummy') then
            local ind = tonumber(commands[1]:sub(6)) or 1
            local song = get.song(table.concat(commands, ' ',2))
            if song and ind <= 2 then
                settings.dummy[ind] = song.enl
                addon_message('Dummy song #%d set to %s':format(ind,song.enl))
            else
                addon_message('Invalid song name.')
            end
        elseif S{'haste','refresh'}:contains(commands[1]) and commands[2] then
            local ind = settings.buffs[commands[1]]:find(commands[2])
            if not commands[3] then
                if ind then
                   settings.buffs[commands[1]]:remove(ind)
                else
                    settings.buffs[commands[1]]:append(commands[2])
                end
            elseif commands[3] == 'on' then
                settings.buffs[commands[1]]:append(commands[2])
            elseif commands[3] == 'off' then
               settings.buffs[commands[1]]:remove(ind)
            end
        elseif get.songs[commands[1]] and commands[2] then
            local n = tonumber(commands[2])
            if n and n ~= 0 and n <= #get.songs[commands[1]] then
                if commands[3] then
                    if not settings.song[commands[3]] then settings.song[commands[3]] = {} end
                    settings.song[commands[3]][commands[1]] = n
                    addon_message('Will now Pianissimo %s x%d for %s.':format(commands[1],n,commands[3]))
                else
                    settings.songs[commands[1]] = n
                    addon_message('%s x%d':format(commands[1],n))
                end
            elseif commands[2] == '0' or commands[2] == 'off' then
                if not commands[3] then              
                    settings.songs[commands[1]] = nil
                    addon_message('%s Off':format(commands[1]))
                elseif settings.song[commands[3]] then 
                    settings.song[commands[3]][commands[1]] = nil
                    if table.length(settings.song[commands[3]]) == 0 then settings.song[commands[3]] = nil end
                    addon_message('Will no longer Pianissimo %s for %s.':format(commands[1],commands[3]))
                end
            elseif n then
                addon_message('Error: %d exceeds the maximum value for %s.':format(n,commands[1]))
            end
        elseif type(settings[commands[1]]) == 'string' and commands[2] then
            local song = get.song(table.concat(commands, ' ',2))
            if song then
                settings[commands[1]] = song.enl
                addon_message('%s is now set to %s':format(commands[1],song.enl))
            else
                addon_message('Invalid song name.')
            end
       elseif type(settings[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
            settings[commands[1]] = tonumber(commands[2])
            addon_message('%s is now set to %d':format(commands[1],settings[commands[1]]))
        elseif type(settings[commands[1]]) == 'boolean' then
            if (not commands[2] and settings[commands[1]] == true) or (commands[2] and commands[2] == 'off') then
                settings[commands[1]] = false
                if commands[1] == 'timers' then reset_timers(true) end
            elseif (not commands[2]) or (commands[2] and commands[2] == 'on') then
                settings[commands[1]] = true
            end
            addon_message('%s %s':format(commands[1],settings[commands[1]] and 'On' or 'Off'))
        elseif commands[1] == 'eval' then
            assert(loadstring(table.concat(commands, ' ',2)))()
        end
    end
    bard_status:text(display_box())
end)

function event_change()
    settings.actions = false
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
