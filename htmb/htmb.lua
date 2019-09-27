_addon.name = 'htmb'
_addon.author = 'Ivaar'
_addon.version = '1.0.0.0'
_addon.command = 'htmb'

require('luau')
require('pack')
bit = require('bit')

local state = 0
local last_attempt = os.time()

buy_list = {10,2,5,9,3} -- key items will be purchased in this order until you are unable to buy more

htmb_map = {
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

math.has_bit = function(mask, offset)
    return math.floor(mask/2^offset)%2 == 1
end

function get_option_index(menu_options, merit_points)
    for x = 1, #buy_list do
        local option = buy_list[x]
        if htmb_map[option] and htmb_map[option].cost <= merit_points and menu_options:has_bit(option) then
            return 0x100 * option + 0x02
        end
    end
    return 0x40000000
end

function initiate_npc(name)
    local target = windower.ffxi.get_mob_by_name(name)
    if target and math.sqrt(target.distance) < 6 and target.valid_target and target.is_npc and bit.band(target.spawn_type, 0xDF) == 2 then
        windower.packets.inject_outgoing(0x1A, 'I2H2d2':pack(0xE1A,target.id,target.index,0,0,0))
    end
    state = 1
end

local function inject_option(npc_id, npc_index, zone_id, menu_id, option_index, bool)
    windower.packets.inject_outgoing(0x5B, 'I3H4':pack(0, npc_id, option_index, npc_index, bool, zone_id, menu_id))
    state = 2
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x034 and state == 1 and os.time()-last_attempt < 3 then
        local zone_id, menu_id = data:unpack('H2', 0x2A+1)
        if htmb_npcs[zone_id] and menu_id == htmb_npcs[zone_id].menu_id then
            inject_option(data:unpack('I', 0x04+1), data:unpack('H', 0x28+1), zone_id, menu_id, get_option_index(data:unpack('I2', 13)), 0)
            return true
        end
    end
end)

windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
    if id == 0x05B and state ~= 0 and (data:byte(15) == 0 or not injected)  then
        state = 0
        local zone_id, menu_id = data:unpack('H2', 17)
        if htmb_npcs[zone_id] and menu_id == htmb_npcs[zone_id].menu_id and data:unpack('I', 9) ~= 0x40000000 then
            initiate_npc(htmb_npcs[zone_id].name)
        end
    end
end)

windower.register_event('addon command', function()
    local zone = windower.ffxi.get_info().zone
    local player = windower.ffxi.get_player()
    if not player or not htmb_npcs[zone] then
        return
    elseif state == 1 and player.status == 0 and os.time()-last_attempt > 3 then
        state = 0
    end
    initiate_npc(htmb_npcs[zone].name)
end)
