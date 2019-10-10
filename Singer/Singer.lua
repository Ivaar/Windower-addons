_addon.author = 'Ivaar'
_addon.commands = {'Singer','sing'}
_addon.name = 'Singer'
_addon.version = '1.19.10.09'

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
    buffs={['haste']=L{},['refresh']=L{}},
    marcato='Sentinel\'s Scherzo',
    clarion={aoe='minuet'},
    actions=false,
    pianissimo=false,
    nightingale=true,
    troubadour=true,
    recast={song={min=20,max=25},buff={min=5,max=10}},
    active=true,
    timers=true,
    ignore=L{},
    song={},
    songs={march=2},
    use_ws=false,
    min_ws=20,
    max_ws=99,
    box={text={size=10}}
    }

settings = config.load(default)

del = 0
counter = 0
interval = 0.1
timers = {AoE={},buffs={Haste={},Refresh={}}}
last_coords = 'fff':pack(0,0,0)
buffs = get.buffs()

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
    str = str..'\n Delay:[%s]':format(settings.delay)
    if settings.use_ws then
        str = str..'\n WS:[ > %d%%][ < %d%%]':format(settings.min_ws,settings.max_ws)
    end
    return str
end

bard_status = texts.new(display_box(),settings.box,settings)
bard_status:show()

function do_stuff()
    if not settings.actions then return end
    counter = counter + interval
    if counter >= del then
        counter = 0
        del = interval
        for k,v in pairs(timers) do song_timers.update(k) end
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        local JA_WS_lock,goal_tp
        local spell_recasts = windower.ffxi.get_spell_recasts()
        local ability_recasts = windower.ffxi.get_ability_recasts()
        local recast = math.random(settings.recast.song.min,settings.recast.song.max)+math.random()
        if is_moving or is_casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end
        if use_ws and not JA_WS_lock and play.status == 1 then
            local targ = windower.ffxi.get_mob_by_target('t')
            if not buffs['aftermath: lv.3'] or buffs['aftermath: lv.3'] <= 5 then
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
end

do_stuff:loop(interval)

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
                del = 2.5
            end
        elseif packet['Category'] == 4 then
            -- Finish Casting
            is_casting = false
            del = settings.delay
            local spell = get.spell_by_id(packet['Param'])
            local song = get.song_name(packet['Param'])
            if spell then
                timers.buffs[spell.enl][windower.ffxi.get_mob_by_id(packet['Target 1 ID']).name:lower()] = os.time()+spell.dur
            elseif song then
                if packet['Target Count'] > 1 or packet['Target 1 ID'] == packet['Actor'] and get.aoe_range() then
                    song_timers.adjust(song,'AoE',buffs)
                end
                for x = 1,packet['Target Count'] do
                    local targ_name = windower.ffxi.get_mob_by_id(packet['Target '..x..' ID']).name
                    song_timers.adjust(song,targ_name,buffs)
                end
            end
        elseif L{3,5}:contains(packet['Category']) then
            is_casting = false
        elseif L{7,9}:contains(packet['Category']) then
            is_casting = true
        end
    elseif id == 0x029 then
        local packet = packets.parse('incoming', original)
        --table.vprint(packet)
        if (packet.Message) == 206 and packet['Actor'] == windower.ffxi.get_mob_by_target('me').id then
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
                    set_buff[buff_en] = math.floor(buff_ts/60+1510890320)
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
        if settings.actions then
            del = 0
            initialize()
            do_stuff()
        end
        addon_message('Actions %s':format(settings.actions and 'On' or 'Off'))
    elseif commands[1] == 'save' then
        settings:save('all')
        addon_message('settings Saved.')
    elseif commands[1] == 'ignore' and commands[3] then
        local ind = settings.ignore:find(commands[2])
        if not ind and commands[3] == '-' then
            settings.ignore:append(commands[2])
            addon_message('%s will now be ignored.':format(commands[2]:ucfirst()))
        elseif ind and commands[3] == '+' then
            settings.ignore:remove(ind)
            addon_message('Will no longer ignore %s.':format(commands[2]:ucfirst()))
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
        local ind = tonumber(commands[1]:sub(6)) or 1
        local song = get.song_by_name(table.concat(commands, ' ',2))
        if song and ind <= 2 then
            settings.dummy[ind] = song.enl
            addon_message('Dummy song #%d set to %s':format(ind,song.enl))
        else
            addon_message('Invalid song name.')
        end
    elseif S{'haste','refresh'}:contains(commands[1]) and commands[2] then
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
    elseif type(settings[commands[1]]) == 'string' and commands[2] then
        local song = get.song_by_name(table.concat(commands, ' ',2))
        if song then
            settings[commands[1]] = song.enl
            addon_message('%s is now set to %s':format(commands[1],song.enl))
        else
            addon_message('Invalid song name.')
        end
   elseif type(settings[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
        settings[commands[1]] = tonumber(commands[2])
        addon_message('%s is now set to %s':format(commands[1],settings[commands[1]]))
    elseif type(settings[commands[1]]) == 'boolean' then
        if commands[1] == 'actions' then
            initialize()
        end
        if not commands[1] then
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
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
    bard_status:text(display_box())
end)

function event_change()
    settings.actions = false
    is_casting = false
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
