_addon.name = 'QuestLog'
_addon.author = 'Ivaar'
_addon.commands = {'quest','ql'}
_addon.version = '1.0.0.1'

require('sets')
packets = require('packets')

local cmds = {
    abyssea = S{'abyssea','aby'},
    adoulin = S{'adoulin','soa'},
    coalition = S{'coalition','ca'},
}

local maps = {
    abyssea = require('maps/abyssea'),
    adoulin = require('maps/adoulin'),
    coalition = require('maps/coalition'),
    other = require('maps/other'),
}

local red = 167
local green = 158
local blue = 207
local yellow = 159

local quest_logs = {
    [0x0070] = {type='current', area='other'},
    [0x00B0] = {type='completed', area='other'},
    [0x00E0] = {type='current', area='abyssea'},
    [0x00E8] = {type='completed', area='abyssea'},
    [0x00F0] = {type='current', area='adoulin'},
    [0x00F8] = {type='completed', area='adoulin'},
    [0x0100] = {type='current', area='coalition'},
    [0x0108] = {type='completed', area='coalition'},
}

local quests = {completed={},current={}}

function to_set(data)
    return {data:unpack('q64':rep(#data/4))}
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x056 then
        local p = packets.parse('incoming', data)
        local log = quest_logs[p.Type]

        if log then
            quests[log.type][log.area] = p['Quest Flags']
        end
    end
end)

function addon_error(str)
    windower.add_to_chat(red, 'You must change areas or complete %s quests before using this command.':format(str))
end

function log_quests(quest_type,start,finish)
    if not quests.completed[quest_type] then
        addon_error(quest_type)
        return true
    end
    local completed = to_set(quests.completed[quest_type])
    local current = to_set(quests.current[quest_type])
    local complete, total = 0, 0
    for x = start, finish do
        if maps[quest_type][x] then
            total = total + 1
            if completed[x+1] then
                complete = complete + 1
            else
                windower.add_to_chat(current[x+1] and red or blue, maps[quest_type][x])
            end
        end
    end
    windower.add_to_chat(green, '-- %s Quests %d/%d Completed --\31\207 Inactive\31\167 Current':format(quest_type:ucfirst(),complete,total))
end

windower.register_event('addon command', function(...)
    if arg[1] == 'eval' then
        assert(loadstring(table.concat(arg, ' ',2)))()
    elseif cmds.abyssea:contains(arg[1]) then
        log_quests('abyssea',0,86)
    elseif cmds.adoulin:contains(arg[1]) then
        log_quests('adoulin',0,143)
        log_quests('other',200,209)
    elseif cmds.coalition:contains(arg[1]) then
        if not quests.completed.coalition then
            addon_error('coalition assignment')
            return
        end
        local complete_count,current_count = 0,0
        local current_coalition = to_set(quests.current.coalition)
        local completed_coalition = to_set(quests.completed.coalition)
        windower.add_to_chat(blue, 'Inactive\31\158 Completed\31\167 Current\31\159 Completed + Current')
        for id = 0, #maps.coalition do
            if #maps.coalition[id] > 8 then
                local complete = completed_coalition[id+1]
                local current = current_coalition[id+1]
                if complete then
                    complete_count = complete_count + 1
                end
                if current then
                    current_count = current_count + 1
                end
                local color = complete and current and yellow or complete and green or current and red or blue
                windower.add_to_chat(color, maps.coalition[id])
            end
        end
        windower.add_to_chat(blue,'%d/95 Complete and %d Current assignments':format(complete_count, current_count))
    end
end)
