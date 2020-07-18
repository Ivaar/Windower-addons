_addon.name = 'htmb'
_addon.author = 'Ivaar'
_addon.version = '1.0.0.2'
_addon.command = 'htmb'

require('tables')
require('logger')
require('pack')
bit = require('bit')

buy_list = {10,2,5,9,3} -- key items will be purchased in this order until you are unable to buy more

htmb_map = T{
     [0] = {name = 'Shadow Lord phantom gem',      cost = 10},
     [1] = {name = 'Stellar Fulcrum phantom gem',  cost = 10},
     [2] = {name = 'Celestial Nexus phantom gem',  cost = 10},
     [3] = {name = 'Phantom gem of apathy',        cost = 15},
     [4] = {name = 'Phantom gem of arrogance',     cost = 15},
     [5] = {name = 'Phantom gem of envy',          cost = 15},
     [6] = {name = 'Phantom gem of cowardice',     cost = 15},
     [7] = {name = 'Phantom gem of rage',          cost = 15},
     [8] = {name = 'P. Perpetrator phantom gem',   cost = 20},
     [9] = {name = 'Savage\'s phantom gem',        cost = 10},
    [10] = {name = 'Warrior\'s Path phantom gem',  cost = 10},
    [11] = {name = 'Puppet in Peril phantom gem',  cost = 10},
    [12] = {name = 'Legacy phantom gem',           cost = 10},
    [13] = {name = 'Head wind phantom gem',        cost = 10},
    [14] = {name = 'Avatar phantom gem',           cost = 10},
    [15] = {name = 'Moonlit Path phantom gem',     cost = 10},
    -- page 2
    [16] = {name = 'Waking the Beast phantom gem', cost = 10},
    [17] = {name = 'Waking Dream phantom gem',     cost = 10},
    [18] = {name = 'Feared One phantom gem',       cost = 10},
    [19] = {name = 'Dawn phantom gem',             cost = 10},
    [20] = {name = 'Stygian Pact phantom gem',     cost = 10},
    [21] = {name = 'Champion phantom gem',         cost = 10},
    [22] = {name = 'Divine phantom gem',           cost = 10},
    [23] = {name = 'Maiden phantom gem',           cost = 10},
}

htmb_npcs = {
    [231] = {name = 'Trisvain',       menu_id = 892}, -- Northern San d'Oria (J-7)
    [236] = {name = 'Raving Opossum', menu_id = 429}, -- Port Bastok (J-11)
    [240] = {name = 'Mimble-Pimble',  menu_id = 895}, -- Port Windurst (L-5)
}

local retries = 0
local state = 0

math.has_bit = function(mask, offset)
    return math.floor(mask/2^offset)%2 == 1
end

function get_option_index(menu_options, merit_points)
    local buy = buy_key_item or buy_list
    for x = 1, #buy do
        local option = buy[x]
        if htmb_map[option] and htmb_map[option].cost <= merit_points and menu_options:has_bit(option) then
            return 0x100 * option + 0x02
        end
    end
    return 0x40000000
end

function interact_npc(name)
    local me = windower.ffxi.get_mob_by_target('me')
    local npc = windower.ffxi.get_mob_by_name(name)
    if me and me.status == 0 and npc and math.sqrt(npc.distance) < 6 and npc.valid_target and npc.is_npc and bit.band(npc.spawn_type, 0xDF) == 2 then
        windower.packets.inject_outgoing(0x1A, 'I2H2d2':pack(0, npc.id, npc.index, 0, 0, 0))
        state = 1
    end
end

function purchase(message)
    local zone = windower.ffxi.get_info().zone
    if not htmb_npcs[zone] then
        state = 0
        return
    end
    if state ~= 0 then
        return
    end
    if message then
        if message ~= '' then
            buy_key_item = {tonumber(message)}
        else
            buy_key_item = nil
        end
        retries = 5
    end
    interact_npc(htmb_npcs[zone].name)
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x034 and state == 1 then
        state = 2
        local npc_id = data:unpack('I', 0x04+1)
        local npc_index, zone_id, menu_id = data:unpack('H3', 0x28+1)
        if htmb_npcs[zone_id] and menu_id == htmb_npcs[zone_id].menu_id then
            local option_index = get_option_index(data:unpack('I2', 0x0C+1))
            windower.packets.inject_outgoing(0x5B, 'I3H4':pack(0, npc_id, option_index, npc_index, 0, zone_id, menu_id))
            return true
        end
    elseif id == 0x52 and state ~= 0 then
        state = 0
        if data:byte(0x04+1) == 0 then
            retries = retries - 1
            if retries > 0 then
                purchase()
            else
                notice('npc is not responding')
            end
        end
    end
end)

windower.register_event('addon command', function(...)
    local command = arg[1] and arg[1]:lower()
    local message = ''
    local send_all
    if command == 'all' then
        table.remove(arg,1)
        send_all = true
    elseif command == 'help' then
        notice('//htmb [all] [key item]')
        notice('[all] - send command to all instances')
        notice('[key item] - defaults to buylist if not specified, supports wildcards')
        return
    end
    if command then
        local str = _raw.table.concat(arg, ' ')
        local matches = htmb_map:filter(windower.wc_match-{str} .. table.get-{'name'})
        message = next(matches)
        if not message then
            error('Unknown key item: ' .. str)
            return
        elseif matches:length() > 1 then
            for match in matches:it() do
                notice(match.name)
            end
            error('Too many key items match: ' .. str)
            return
        end
        notice('Buying ' .. matches[message].name)
    end
    purchase(message)
    if send_all then
        windower.send_ipc_message(message)
    end
end)

windower.register_event('ipc message', purchase)
