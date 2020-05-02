_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.20.05.01'

require('luau')
require('pack')
packets = require('packets')
texts = require('texts')
config = require('config')

get = require('sing_get')
cast = require('sing_cast')
song_timers = require('song_timers')

default = {
    delay=4,
    dummy=L{'Knight\'s Minne','Knight\'s Minne II'},
    buffs=T{['haste']=L{},['refresh']=L{},['aurorastorm']=L{},['firestorm']=L{}},
	debuffs=L{'Carnage Elegy','Pining Nocturne'},
    marcato='Sentinel\'s Scherzo',
    clarion={aoe='minuet'},
    actions=false,
    pianissimo=false,
    nightingale=true,
    troubadour=true,
	debuffing=false,
    recast={song={min=20,max=25},buff={min=5,max=10}},
    active=true,
    timers=true,
    aoe = {['p1'] = true,['p2'] = true,['p3'] = true,['p4'] = true,['p5'] = true},
    song={},
    songs={march=2},
    use_ws=false,
    min_ws=20,
    max_ws=99,
    box={bg={visible=false},text={size=10}},
}

settings = config.load(default)

del = 0
counter = 0
interval = 0.1
timers = {AoE={}, buffs={}}
last_coords = 'fff':pack(0,0,0)
buffs = get.buffs()
debuffed = {}

do
    local time = os.time()
    local vana_time = time - 1009810800

    bufftime_offset = math.floor(time - (vana_time * 60 % 0x100000000) / 60)
end

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
    str = str..'\n Dummy (Songs):\n   1:[%s]\n   2:[%s]':format(settings.dummy[1],settings.dummy[2])
    str = str..'\n Nightingale:[%s]':format(settings.nightingale and 'On' or 'Off')
    str = str..'\n Troubadour:[%s]':format(settings.troubadour and 'On' or 'Off')
    str = str..'\n Pianissimo:[%s]':format(settings.pianissimo and 'On' or 'Off')
    for k,v in pairs(settings.song) do
        str = str..'\n %s:':format(k:ucfirst())
        for i,t in pairs(v) do
            str = str..'\n   %s:[x%d]':format(i:ucfirst(),t)
        end
        if settings.clarion[k] then
            str = str..'\n   Clarion:[%s]':format(settings.clarion[k]:ucfirst())
        end
    end
    str = str..'\n AoE:'
    local party = windower.ffxi.get_party()
    for x = 1, 5 do
        local slot = 'p' .. x
        local member = party[slot]
        member = member and member.name or ''
        str = str..'\n <%s> [%s] %s':format(slot, settings.aoe[slot] and 'On' or 'Off', member)
    end
	if settings.debuffing then
		str = str..'\n Debuffing:[On]':format(settings.debuffing and 'On' or 'Off', settings.debuffing)
	end
    for k,v in ipairs(settings.debuffs) do
        str = str..'\n   %d:[%s]':format(k, v)
    end
    for k,v in ipairs(settings.buffs.haste) do
       str = str..'\n Haste:[%s]':format(v:ucfirst())
    end
    for k,v in ipairs(settings.buffs.refresh) do
        str = str..'\n Refresh:[%s]':format(v:ucfirst())
    end
    for k,v in ipairs(settings.buffs.aurorastorm) do
        str = str..'\n Aurorastorm:[%s]':format(v:ucfirst())
    end
    for k,v in ipairs(settings.buffs.firestorm) do
        str = str..'\n Firestorm:[%s]':format(v:ucfirst())
    end
    for k,v in pairs(settings.recast) do
        str = str..'\n Recast %s:[%d-%d]':format(k:ucfirst(),v.min,v.max)
    end
    str = str..'\n Delay:[%s]':format(settings.delay)
    if settings.use_ws then
        str = str..'\n WS:[ > %d%%][ < %d%%]':format(settings.min_ws,settings.max_ws)
    end
    return str
end

bard_status = texts.new(display_box(),settings.box,settings)
bard_status:show()

function do_stuff()
    bard_status:text(display_box())
    if not settings.actions then return end
    counter = counter + interval
    if counter >= del then
        counter = 0
        del = interval
        local play = windower.ffxi.get_player()

        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        if is_moving or is_casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end

        local JA_WS_lock = buffs.amnesia or buffs.impairment

        if use_ws and not JA_WS_lock and play.status == 1 then
            local targ = windower.ffxi.get_mob_by_target('t')
            local goal_tp
            if not buffs['aftermath: lv.3'] or os.time() - buffs['aftermath: lv.3'] <= 5 then
                goal_tp = 3000
            else
                goal_tp = 1000
            end
            if (get.eye_sight(windower.ffxi.get_mob_by_target('me'),targ) and play.vitals.tp >= goal_tp and 
                targ and targ.valid_target and targ.is_npc and targ.hpp < settings.max_ws and targ.hpp > settings.min_ws and  
                math.sqrt(targ.distance) <= 4) and (goal_tp == 1000 or not buffs['aftermath: lv.3']) then

                windower.send_command('input /ws "Mordant Rime" <t>')
                del = 4.2
                return
            end
        end

        if buffs.silence or buffs.mute or buffs.omerta then return end

        local spell_recasts = windower.ffxi.get_spell_recasts()
        local ability_recasts = windower.ffxi.get_ability_recasts()
        local recast = math.random(settings.recast.song.min,settings.recast.song.max)+math.random()
--[[
        for k, v in pairs(timers) do
            song_timers.update(k)
        end
]]
        if get.aoe_range() then
            local song = cast.check_song(settings.songs,'AoE',buffs,spell_recasts,recast) 

            if song then
                cast.song(song,'<me>',buffs,ability_recasts,JA_WS_lock)
                return
            end
        end

        if settings.pianissimo then
            for targ,songs in pairs(settings.song) do
                if get.valid_target(targ:lower(), 20) then
                    local targ = targ:ucfirst()
                    local song = cast.check_song(songs,targ,buffs,spell_recasts,recast)

                    if song then
                        cast.song(song,targ,buffs,ability_recasts,JA_WS_lock)
                        return
                    end
                end
            end
        end

        local recast = math.random(settings.recast.buff.min,settings.recast.buff.max)+math.random()
        for key,targets in pairs(settings.buffs) do
            local spell = get.spell(key)
            for k,targ in ipairs(targets) do
                if targ and spell and spell_recasts[spell.id] <= 0 and get.valid_target(targ:lower(), 20) and play.vitals.mp >= 40 and
                (not timers.buffs or not timers.buffs[spell.enl] or not timers.buffs[spell.enl][targ] or 
                os.time() - timers.buffs[spell.enl][targ]+recast > 0) then
                    cast.MA(spell.enl,targ)
                    return
                end
            end
        end
        if settings.debuffing then
            local targ = windower.ffxi.get_mob_by_target('bt')

            if targ and targ.hpp > 0 and targ.valid_target and targ.distance < 20 then
                for _,song in ipairs(settings.debuffs) do
                    local effect
                    for k,v in pairs(get.debuffs) do
                        if table.find(v, song) then
                            effect =  k
                            break
                        end
                    end

                    if effect and (not debuffed[targ.id] or not debuffed[targ.id][effect]) and spell_recasts[get.song_by_name(song).id] == 0 then
                        cast.MA(song,'<bt>')
						break
                    end
                end
            end
        end	
    end
end

do_stuff:loop(interval)

start_categories = S{7,9}
finish_categories = S{3,5}
buff_lost_messages = S{204,206}
death_messages = {[6]=true,[20]=true,[113]=true,[406]=true,[605]=true,[646]=true}

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        if packet['Actor'] ~= windower.ffxi.get_mob_by_target('me').id then return false end
        if packet['Category'] == 8 then
            if (packet['Param'] == 24931) then
            -- Begin Casting
                is_casting = true
            elseif (packet['Param'] == 28787) then
            -- Failed Casting
                is_casting = false
                del = 2.2
            end
        elseif packet['Category'] == 4 then
            -- Finish Casting
            is_casting = false
            del = settings.delay
            local spell = get.spell_by_id(packet['Param'])

            if spell then
                local targ = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])

                if targ then
                    timers.buffs[spell.enl] = timers.buffs[spell.enl] or {}
                    timers.buffs[spell.enl][targ.name:lower()] = os.time() + spell.dur
                end
                return
            end

            local song = get.song_name(packet['Param'])

            if song then
                local buff_id = packet['Target 1 Action 1 Param']
                if song_buffs[buff_id] and packet['Target Count'] > 1 and get.aoe_range() then
                --if song_buffs[buff_id] and packet['Target Count'] > 1 and packet['Target 1 ID'] == packet['Actor'] and get.aoe_range() then
                    song_timers.adjust(song,'AoE',buffs)
                end
                for x = 1, packet['Target Count'] do
                    local buff_id = packet['Target '..x..' Action 1 Param']
                    if buff_id ~= 0 then
                        local targ = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID'])

                        if song_buffs[buff_id] then
                            song_timers.adjust(song,targ.name,buffs)
                        elseif song_debuffs[buff_id] then
                            local effect = song_debuffs[buff_id]
                            debuffed[targ.id] = debuffed[targ.id] or {}
                            debuffed[targ.id][effect] = true
                        end
                    end
                end
            end
        elseif finish_categories:contains(packet['Category']) then
            is_casting = false
        elseif start_categories:contains(packet['Category']) then
            is_casting = true
        end
    elseif id == 0x029 then
        local packet = packets.parse('incoming', original)

        if death_messages[packet.Message] then
            debuffed[packet.Target] = nil
        elseif buff_lost_messages:contains(packet.Message) and packet['Actor'] == windower.ffxi.get_mob_by_target('me').id then
            song_timers.buff_lost(packet['Target'],packet['Param 1']) 
        end
    elseif id == 0x63 and original:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff_id = original:unpack('H', n*2+7)
            local buff_ts = original:unpack('I', n*4+69)
            if buff_ts == 0 then
                break
            elseif buff_id ~= 255 then
                local buff_en = res.buffs[buff_id].en:lower()
                if buff_id == 272 then
                    set_buff[buff_en] = math.floor(buff_ts/60+bufftime_offset)
                else
                    set_buff[buff_en] = (set_buff[buff_en] or 0) + 1
                end
            end
        end
        buffs = set_buff
    end
end)

windower.register_event('outgoing chunk', function(id,original,modified,is_injected,is_blocked)
    if id == 0x015 then
        local coords = modified:sub(0x04+1, 0x0F+1)
        is_moving = last_coords ~= coords
        last_coords = coords
    end
end)

function addon_message(str)
    windower.add_to_chat(207, _addon.name..': '..str)
end

handled_commands = T{
    actions = S{'on','off'},
    aoe = T{
        ['on'] = 'on',
        ['add'] = 'on',
        ['+'] = 'on',
        ['watch'] = 'on',
        ['off'] = 'off',
        ['remove'] = 'off',
        ['-'] = 'off',
        ['ignore'] = 'off',
    },
    recast = S{'buff','song'}
}

short_commands = {
    ['p'] = 'pianissimo',
    ['n'] = 'nightingale',
    ['t'] = 'troubadour',
}

windower.register_event('addon command', function(...)
    local commands = T{...}
    
    for x=1,#commands do commands[x] = windower.convert_auto_trans(commands[x]):lower() end
    
    commands[1] = short_commands[commands[1]] or commands[1]
    
    if commands[1] == 'actions' then
        commands:remove(1)
    end

    if not commands[1] or handled_commands.actions:contains(commands[1]) then
        if not commands[1] then
            settings.actions = not settings.actions
        elseif commands[1] == 'on' then
            settings.actions = true
        elseif commands[1] == 'off' then
            settings.actions = false
        end
        if settings.actions then
            del = 0
            initialize()
            do_stuff()
        end
        addon_message('Actions %s':format(settings.actions and 'On' or 'Off'))
    elseif commands[1] == 'save' then
        settings:save('all')
        addon_message('settings Saved.')
    elseif commands[1] == 'aoe' and commands[2] then
        local command = handled_commands.aoe[commands[3]]
        local slot = tonumber(commands[2], 6, 0) or commands[2]:match('[1-5]')
        slot = slot and 'p' .. slot or get.party_member_slot(commands[2])

        if not slot then
            return
        elseif not commands[3] or not command then
            settings.aoe[slot] = not settings.aoe[slot]
        elseif command == 'on' then
            settings.aoe[slot] = true
        elseif command == 'off' then
            settings.aoe[slot] = false
        end

        if settings.aoe[slot] then
            addon_message('Will now ensure <%s> is in AoE range.':format(slot))
        else
            addon_message('<%s> will now be ignored for AoE songs.':format(slot))
        end   
    elseif commands[1] == 'recast' and handled_commands.recast:contains(commands[2]) then
        settings.recast[commands[2]].min = tonumber(commands[3]) or settings.recast[commands[2]].min
        settings.recast[commands[2]].max = tonumber(commands[4]) or settings.recast[commands[2]].max
        addon_message('%s recast set to min: %s max: %s':format(commands[2], settings.recast[commands[2]].min, settings.recast[commands[2]].max))
    elseif commands[1] == 'clarion' and commands[2] and get.songs[commands[2]] then
        if commands[3] and settings.song[commands[3]] then
            settings.clarion[commands[3]] = commands[2]
            addon_message('Clarion song for %s set to %s':format(commands[3],commands[2]))
        else
            settings.clarion.aoe = commands[2]
            addon_message('Clarion AoE song set to %s':format(commands[2]))
        end
    elseif commands[1] == 'ws' and commands[3] then
        if commands[3] == 'on' then
            settings.use_ws = true
        elseif commands[3] == 'off' then
            settings.use_ws = false
        elseif tonumber(commands[3]) then
            if commands[2] == '<' then
                settings.max_ws = tonumber(commands[3])
            elseif commands[2] == '>' then
                settings.min_ws = tonumber(commands[3])
            end
        end
   elseif commands[1]:startswith('dummy') then
        local ind = tonumber(commands[1]:sub(6))

        if not ind and tonumber(commands[2]) then
            ind = commands[2]
            commands:remove(2)
        end

        ind = tonumber(ind or 1, 3, 0)

        if commands[2] == 'remove' then
            settings.dummy:remove(ind)
            return
        end

        local song = get.song_by_name(table.concat(commands, ' ',2))

        if song then
            settings.dummy[ind] = song.enl
            addon_message('Dummy song #%d set to %s':format(ind,song.enl))
        else
            addon_message('Invalid song name.')
        end
    elseif default.buffs:containskey(commands[1]) and commands[2] then
        local ind = settings.buffs[commands[1]]:find( commands[2])
        if not commands[3] then
            if ind then
               settings.buffs[commands[1]]:remove(ind)
            else
                settings.buffs[commands[1]]:append(commands[2])
            end
        elseif commands[3] == 'on' then
            settings.buffs[commands[1]]:append( commands[2])
        elseif commands[3] == 'off' then
           settings.buffs[commands[1]]:remove(ind)
        end
    elseif get.songs[commands[1]] and commands[2] then
        --[[
        if commands[1] == 'carol' then
            set_carol(commands[2])
            commands:remove(2)
        end
        ]]
        local n = tonumber(commands[2])
        local buff = commands[1]
        local name = commands[3]
        if n and n ~= 0 and n <= #get.songs[buff] then
            if commands[3] then
                if not settings.song[name] then settings.song[name] = {} end
                settings.song[name][buff] = n
                addon_message('Will now Pianissimo %s x%d for %s.':format(buff,n,name:ucfirst()))
            else
                settings.songs[buff] = n
                addon_message('%s x%d':format(buff,n))
            end
        elseif commands[2] == '0' or commands[2] == 'off' then
            if not name then              
                settings.songs[buff] = nil
                addon_message('%s Off':format(commands[1]))
            elseif settings.song[name] then 
                settings.song[name][buff] = nil
                if table.length(settings.song[name]) == 0 then settings.song[name] = nil end
                addon_message('Will no longer Pianissimo %s for %s.':format(buff,name:ucfirst()))
            end
        elseif n then
            addon_message('Error: %d exceeds the maximum value for %s.':format(n,commands[1]))
        end
    elseif commands[1] == 'debuff' and commands[2] then
        local debuff = get.song_by_name(table.concat(commands, ' ',2))

        if not debuff then
            return
        end

        local ind = settings.debuffs:find(debuff.enl)
        if ind then
            settings.debuffs:remove(ind)
        else
            settings.debuffs:append(debuff.enl)
        end
    elseif type(default[commands[1]]) == 'string' and commands[2] then
        local song = get.song_by_name(table.concat(commands, ' ',2))
        if song then
            settings[commands[1]] = song.enl
            addon_message('%s is now set to %s':format(commands[1],song.enl))
        else
            addon_message('Invalid song name.')
        end
   elseif type(default[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
        settings[commands[1]] = tonumber(commands[2])
        addon_message('%s is now set to %s':format(commands[1],settings[commands[1]]))
    elseif type(default[commands[1]]) == 'boolean' then
        if not commands[2] then
            settings[commands[1]] = not settings[commands[1]]
        elseif commands[2] == 'on' then
            settings[commands[1]] = true
        elseif commands[2] == 'off' then
            settings[commands[1]] = false
        end
        if commands[1] == 'timers' and not settings.timers then
            song_timers.reset(true)
        end
        addon_message('%s %s':format(commands[1],settings[commands[1]] and 'On' or 'Off'))
    elseif commands[1] == 'reset' then
        song_timers.reset()
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
    bard_status:text(display_box())
end)

function event_change()
    settings.actions = false
    is_casting = false
    debuffed = {}
    song_timers.reset()
    bard_status:text(display_box())
end

function status_change(new,old)
    is_casting = false
    if new == 2 or new == 3 then
        event_change()
    end
end

windower.register_event('unload', song_timers.reset)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', event_change)
