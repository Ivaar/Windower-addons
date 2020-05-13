_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.20.05.12'

require('luau')
require('pack')
packets = require('packets')
texts = require('texts')
config = require('config')

get = require('sing_get')
cast = require('sing_cast')
song_timers = require('song_timers')

default = {
    interval = 0.1,
    delay=4,
    marcato='Sentinel\'s Scherzo',
    soul_voice=false,
    clarion=false,
    actions=false,
    pianissimo=false,
    nightingale=true,
    troubadour=true,
    debuffing=false,
    recast={song={min=20,max=25},buff={min=5,max=10}},
    active=true,
    timers=true,
    aoe={['party']=true, ['p1'] = true,['p2'] = true,['p3'] = true,['p4'] = true,['p5'] = true},
    min_ws=20,
    max_ws=99,
    box={bg={visible=false},text={size=10},pos={x=650,y=0}},
}

settings = config.load(default)

setting = T{
    buffs = T{
        haste = L{},
        refresh = L{},
        firestorm = L{},
        aurorastorm = L{},
    },
    debuffs = L{},
    debuffs = L{"Carnage Elegy","Pining Nocturne",},
    dummy = L{"Knight's Minne","Knight's Minne II",},
    songs = L{"Advancing March","Victory March","Blade Madrigal","Sword Madrigal","Valor Minuet V",},
    song = {},
    playlist = T{
        clear = L{}
    },
}

local save_file

do
    local file_path = windower.addon_path..'data/settings.lua'
    local table_tostring

    table_tostring = function(tab, padding) 
        local str = ''
        for k, v in pairs(tab) do
            if class(v) == 'List' then
                str = str .. '':rpad(' ', padding) .. '%s = L{':format(k) .. table_tostring(v, padding+4) .. '},\n'
            elseif class(v) == 'Table' then
                str = str .. '':rpad(' ', padding) .. '%s = T{\n':format(k) .. table_tostring(v, padding+4) .. '':rpad(' ', padding) .. '},\n'
            elseif class(v) == 'table' then
                str = str .. '':rpad(' ', padding) .. '%s = {\n':format(k) .. table_tostring(v, padding+4) .. '':rpad(' ', padding) .. '},\n'
            elseif class(v) == 'string' then
                str = str .. '"%s",':format(v)
            end
        end
        return str
    end

    save_file = function()
        local make_file = io.open(file_path, 'w')
        
        local str = table_tostring(setting, 4)

        make_file:write('return {\n' .. str .. '}\n')
        make_file:close()
    end

    if windower.file_exists(file_path) then
        setting = setting:update(dofile(file_path))
    else
        save_file()
        notice('New file: data/settings.lua')
    end

    local time = os.time()
    local vana_time = time - 1009810800

    bufftime_offset = math.floor(time - (vana_time * 60 % 0x100000000) / 60)
end

del = 0
counter = 0
timers = {AoE={}, buffs={}}
last_coords = 'fff':pack(0,0,0)
buffs = get.buffs()
times = {}
debuffed = {}
color = {}

function colorize(row, str)
    if not color[row] then return str end
    return '\\cs(0,255,0)%s\\cr':format(str)
end

local buttons = {'active','actions','nightingale','troubadour','pianissimo','debuffing','party','p1','p2','p3','p4','p5'}

local display_box = function()
    local str = colorize(1, 'Singer')
    str = str .. colorize(2, '\n Actions: [%s]':format(settings.actions and 'On' or 'Off'))

    if not settings.active then return str end

    str = str..colorize(3, '\n Nightingale:[%s]':format(settings.nightingale and 'On' or 'Off'))
    str = str..colorize(4, '\n Troubadour:[%s]':format(settings.troubadour and 'On' or 'Off'))
    str = str..colorize(5, '\n Pianissimo:[%s]':format(settings.pianissimo and 'On' or 'Off'))
    str = str..colorize(6, '\n Debuffing:[%s]':format(settings.debuffing and 'On' or 'Off'))
    str = str..colorize(7, '\n AoE: [%s]':format(settings.aoe.party and 'On' or 'Off'))

    local party = windower.ffxi.get_party()
    local members = {player_name=true}
    for x = 1, 5 do
        local slot = 'p' .. x
        local member = party[slot]
        if member then
            member = member.name
            members[member] = true
        else
            member = ''
        end
        str = str..colorize(x + 7,'\n <%s> [%s] %s':format(slot, settings.aoe[slot] and 'On' or 'Off', member))
    end

    str = str..'\n Marcato:\n  [%s]':format(settings.marcato)
    for k,v in ipairs(setting.songs) do
        str = str..'\n   %d:[%s]':format(k, v)
    end

    for k,v in pairs(setting.song) do
        str = str..'\n %s:':format(k)
        for i, t in ipairs(v) do
            str = str..'\n  %d:[%s]':format(i,t)
        end
    end

    str = str .. '\n Debuffs:'
    for k,v in ipairs(setting.debuffs) do
        str = str..'\n  %d:[%s]':format(k, v)
    end
--[[
    for buff, targets in pairs(setting.buffs) do
        for target in targets:it() do
            local targ = target
            if members[targ] then
                str = str .. '\n %s:[%s]':format(buff, targ)
            end
        end
    end
]]
    str = str..'\n Dummy Songs:[%d]':format(setting.dummy:length())

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
    counter = counter + settings.interval
    if counter >= del then
        counter = 0
        del = settings.interval
        local play = windower.ffxi.get_player()

        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        if is_moving or is_casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end

        local JA_WS_lock = buffs.amnesia or buffs.impairment

        if use_ws and not JA_WS_lock and play.status == 1 then
            local targ = windower.ffxi.get_mob_by_target('t')
            local goal_tp
            if not times['aftermath: lv.3'] or os.time() - times['aftermath: lv.3'] <= 5 then
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
        local recast = settings.recast.song.min

        for k, v in pairs(timers) do
            song_timers.update(k)
        end

        if not settings.aoe.party or get.aoe_range() then
            if cast.check_song(setting.songs,'AoE',buffs,spell_recasts,ability_recasts,JA_WS_lock,recast) then
                return
            end
        end

        if settings.pianissimo then
            for targ, songs in pairs(setting.song) do
                if get.valid_target(targ, 20) then
                    if cast.check_song(songs,targ,buffs,spell_recasts,ability_recasts,JA_WS_lock,recast) then
                        return
                    end
                end
            end
        end

        local recast = math.random(settings.recast.buff.min,settings.recast.buff.max)+math.random()
        for key,targets in pairs(setting.buffs) do
            local spell = get.spell(key)
            for k,targ in ipairs(targets) do
                if targ and spell and spell_recasts[spell.id] <= 0 and get.valid_target(targ, 20) and play.vitals.mp >= 40 and
                (not timers.buffs or not timers.buffs[spell.enl] or not timers.buffs[spell.enl][targ] or 
                os.time() - timers.buffs[spell.enl][targ]+recast > 0) then
                    cast.MA(spell.enl,targ)
                    return
                end
            end
        end

        if settings.debuffing then
            local targ = windower.ffxi.get_mob_by_target('bt')

            if targ and targ.hpp > 0 and targ.valid_target and targ.distance:sqrt() < 20 then
                for song in setting.debuffs:it() do
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

do_stuff:loop(settings.interval)

start_categories = S{7,9}
finish_categories = S{3,5}
buff_lost_messages = S{64,204,206,350,531}
death_messages = {[6]=true,[20]=true,[113]=true,[406]=true,[605]=true,[646]=true}

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        if packet['Actor'] ~= get.player_id then return false end
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
                    timers.buffs[spell.enl][targ.name] = os.time() + spell.dur
                end
                return
            end

            local song = get.song_name(packet['Param'])

            if not song then return end

            local buff_id = packet['Target 1 Action 1 Param']
            if song_buffs[buff_id] and packet['Target Count'] > 1 and (not settings.aoe.party or get.aoe_range()) then
                song_timers.adjust(song, 'AoE', buffs)
            end
            for x = 1, packet['Target Count'] do
                local buff_id = packet['Target '..x..' Action 1 Param']
                if song_buffs[buff_id] then
                    song_timers.adjust(song, windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name, buffs)
                elseif song_debuffs[buff_id] then
                    local effect = song_debuffs[buff_id]
                    debuffed[targ] = debuffed[targ.id] or {}
                    debuffed[targ][effect] = true
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
        elseif buff_lost_messages:contains(packet.Message) and packet['Actor'] == get.player_id then
            song_timers.buff_lost(packet['Target'],packet['Param 1']) 
        end

    elseif id == 0x63 and original:byte(5) == 9 then
        -- appears # of copies are not checked anymore and times may only ever be used for afermath, I keep forgetting we dont getno party buff timers
        local set_buff = {}
        local set_time = {}
        for n=1,32 do
            local buff_id = original:unpack('H', n*2+7)
            local buff_ts = original:unpack('I', n*4+69)

            if buff_ts == 0 then
                break
            elseif buff_id ~= 255 then
                local buff_en = res.buffs[buff_id].en:lower()

                set_buff[buff_en] = (set_buff[buff_en] or 0) + 1
                set_time[buff_en] = math.floor(buff_ts / 60 + bufftime_offset)
            end
        end
        buffs = set_buff
        times = set_time

    elseif id == 0x00A then
        local packet = packets.parse('incoming', original)

        get.player_id = packet.Player
        get.zone_id = packet.Zone
        get.player_name = packet.Name
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
    recast = S{'buff','song'},
    clear = S{'remove','clear'},
}

short_commands = {
    ['p'] = 'pianissimo',
    ['n'] = 'nightingale',
    ['t'] = 'troubadour',
    ['play'] = 'playlist',
}

local function save_playlist(commands)
    if not commands[2] or commands[2] == 'clear' then
        return false
    end

    local song_list = setting.song[commands[3] and commands[3]:ucfirst()] or setting.songs

    if song_list and not song_list:empty() then
        setting.playlist[commands[2]] = song_list:copy()
        addon_message('Playlist set: "%s" %s':format(commands[2], song_list:tostring())) 
        return true
    end
end

function resolve_song(commands)
    local x = tonumber(commands[#commands], 7)

    if x then commands[#commands] = {'I','II','III','IV','V','VI'}[x] end

    return get.song_by_name(table.concat(commands, ' ',2))
end

windower.register_event('addon command', function(...)
    local commands = T(arg):map(windower.convert_auto_trans .. string.lower)

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
        if not commands[2] then
            settings:save('all')
            addon_message('settings Saved.')
        elseif not save_playlist(commands) then
           return
        end
        save_file()
    elseif commands[1] == 'playlist' then
        if commands[2] == 'save' then
            commands:remove(1)
            if save_playlist(commands) then
                save_file()
            end
        elseif setting.playlist:containskey(commands[2]) then
            local song_list = setting.playlist[commands[2]]
            local name = commands[3] and commands[3]:ucfirst()

            if name then
                setting.song[name] = song_list:copy()
            else
                setting.songs = song_list:copy()
            end
            addon_message('%s: %s':format(name or 'AoE', song_list:tostring()))
        else
            addon_message('Playlist not found: %s':format(commands[2]))
        end
    elseif tonumber(commands[1], 6) and commands[2] then
        local name = commands[#commands]:ucfirst()
        local ind = tonumber(commands[1])

        if get.party_member_slot(name) then
            commands:remove(#commands)
        else
            name = nil
        end

        if handled_commands.clear:contains(commands[2]) then
            if not name then
                setting.songs:remove(ind)
            elseif setting.song[name] then
                setting.song[name]:remove(ind)
                if setting.song[name]:empty() then
                    setting.song[name] = nil
                end
            end
        else
            local song = resolve_song(commands)

            if not song then
            elseif name then
                setting.song[name] = setting.song[name] or L{}
                setting.song[name][ind] = song.enl
            else
                setting.songs[ind] = song.enl
            end
        end
    elseif commands[1] == 'aoe' and commands[2] then
        local command = handled_commands.aoe[commands[#commands]]
        local slot = commands[2]:match('[1-5]')
        slot = slot and 'p' .. slot or get.party_member_slot(commands[2]:ucfirst())

        if not slot then
            if command and not commands[3] then
            elseif commands[2] ~= 'party' then
                return
            end
            slot = 'party'
        end
        if not command then
            settings.aoe[slot] = not settings.aoe[slot]
        elseif command == 'on' then
            settings.aoe[slot] = true
        elseif command == 'off' then
            settings.aoe[slot] = false
        end

        if settings.aoe[slot] then
            addon_message('Will now ensure <%s> is in AoE range.':format(slot))
        else
            addon_message('Ignoring <%s>':format(slot))
        end   
    elseif commands[1] == 'recast' and handled_commands.recast:contains(commands[2]) then
        settings.recast[commands[2]].min = tonumber(commands[3]) or settings.recast[commands[2]].min
        settings.recast[commands[2]].max = tonumber(commands[4]) or settings.recast[commands[2]].max
        addon_message('%s recast set to min: %s max: %s':format(commands[2], settings.recast[commands[2]].min, settings.recast[commands[2]].max))
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

        ind = tonumber(ind or 1, 5, 0)

        if commands[2] == 'remove' then
            setting.dummy:remove(ind)
            return
        end

        local song = resolve_song(commands)

        if song then
            setting.dummy[ind] = song.enl
            addon_message('Dummy song #%d set to %s':format(ind,song.enl))
        else
            addon_message('Invalid song name.')
        end
    elseif setting.buffs:containskey(commands[1]) and commands[2] then
        local name = commands[2]:ucfirst()
        local ind = setting.buffs[commands[1]]:find(name)

        if ind and not commands[3] or ind and commands[3] == 'off' then
            setting.buffs[commands[1]]:remove(ind)
            addon_message('Will stop buffing %s with %s':format(name, commands[1]:ucfirst()))
        elseif not ind and (not commands[3] or commands[3] == 'on') then
            setting.buffs[commands[1]]:append(name)
            addon_message('Will now buff %s with %s':format(name, commands[1]:ucfirst()))
        elseif commands[3] == 'on' then
            addon_message('Already buffing %s with %s':format(name, commands[1]:ucfirst()))
        end
    elseif get.songs[commands[1]] and commands[2] then
        local songs = get.ext_songs(commands[1], commands[2])

        if songs then
            commands:remove(2)
        else
            songs = get.songs[commands[1]]
        end

        commands:remove(1)

        local name = commands[#commands]:ucfirst()

        if get.party_member_slot(name) then
            commands:remove(#commands)
            setting.song[name] = setting.song[name] or L{}
        else
            name = nil
        end

        local song_list = setting.song[name] or setting.songs
        local n = commands[#commands]
        local n = tonumber({off=0}[n] or n or 1)

        if not n then
            return
        elseif #songs < n then
            addon_message('Error: %d exceeds the maximum value for %s.':format(n, commands[1]))
            return
        elseif n == 0 then
            for x = #songs, 1, -1 do
                local song = table.find(song_list, songs[x])

                if song then
                    song_list:remove(song)
                end
            end
        else
            for x = 1, n do
                local song = songs[x]

                if not table.find(song_list, song) then
                    if #song_list >= 5 then
                        song_list:remove(5)
                    end
                    song_list:insert(1, song)
                end
            end
        end

        if song_list:empty() then
            setting.song[name] = nil
        end
        addon_message('%s: %s':format(name or 'AoE', song_list:tostring()))
    elseif commands[1] == 'debuff' and commands[2] then
        local debuff = resolve_song(commands)

        if not debuff then
            return
        end

        local ind = setting.debuffs:find(debuff.enl)

        if ind then
            setting.debuffs:remove(ind)
        else
            setting.debuffs:append(debuff.enl)
        end
    elseif type(default[commands[1]]) == 'string' and commands[2] then
        local song = resolve_song(commands)

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

function mouse_event(type, x, y, delta, blocked)

    for row in ipairs(buttons) do
        color[row] = false
    end

    if bard_status:hover(x, y) and bard_status:visible() then
        local lines = bard_status:text():count('\n') + 1
        local _, _y = bard_status:extents()
        local pos_y = y - settings.box.pos.y
        local off_y = _y / lines
        local upper = 1
        local lower = off_y

        for row, button in ipairs(buttons) do
            if pos_y > upper and pos_y < lower then
                color[row] = true

                if type == 2 then
                    if default.aoe[button] then
                        settings.aoe[button] = not settings.aoe[button]
                    else
                        settings[button] = not settings[button]
                    end
                end
            end

            upper = lower
            lower = lower + off_y
        end
    end
end

windower.register_event('mouse', mouse_event)
windower.register_event('unload', song_timers.reset)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', event_change)
