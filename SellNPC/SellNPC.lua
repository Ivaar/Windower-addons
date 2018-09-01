_addon.command = 'SellNPC'
_addon.version = '1.0.0.5'
_addon.author = 'Ivaar'

require('sets')
config = require('config')
profiles = require('profiles')
res_items = require('resources').items

default = {
    delay = 1,
    randomize_delay = true,
    }

settings = config.load(default)

sales_que = {}

function get_item_res(item)
    for k,v in pairs(res_items) do
        if v.en:lower() == item or v.enl:lower() == item then
            return v
        end
    end
    return nil
end

function check_item(name)
    local name = windower.convert_auto_trans(name):lower()
    local item = get_item_res(name)
    if not item then
        print('Error: %s not a valid item name.':format(name))
        return
    end
    if item.flags['No NPC Sale'] then
        print('Error: Cannot sell %s to npc vendors':format(item.en))
    else
        sales_que[item.id] = true
        print('%s added to sales queue':format(item.en))
    end
end

function sell_appraised_items()
    for index = 1, 80 do local item = windower.ffxi.get_items(0,index)
        if item and appraised[item.id] and item.status == 0 then
            windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,item.count,0,0,0,item.id%256,math.floor(item.id/256)%256,index,0))
            windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
            if settings.delay > 0 then
                coroutine.sleep(settings.delay + (settings.randomize_delay and math.random() or 0))
            end
        end
    end
    sales_que = {}
    appraised = nil
    requested = nil
end

function incoming_shop_packets(id, data)
    if id == 0x03C then
        appraised = {}
        requested = {}
        if not actions or coroutine.status(actions) == 'dead' then
            for index = 1, 80 do local item = windower.ffxi.get_items(0,index)
                if item and sales_que[item.id] and not requested[item.id] and item.status == 0 then
                    requested[item.id] = true
                    windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,1,0,0,0,item.id%256,math.floor(item.id/256)%256,index,0))
                end
            end
        end
    elseif id == 0x03D and appraised then
        local item_id = windower.ffxi.get_items(0,data:byte(9)).id
        if requested[item_id] and not appraised[item_id] then
            appraised[item_id] = true
            if not actions or coroutine.status(actions) == 'dead' then
                actions = coroutine.schedule(sell_appraised_items, 1)
            end
        end
    end
end

function reset()
    coroutine.close(actions)
    actions = nil
    appraised = nil
    requested = nil
end

function cmd(...)
    local commands = {...}
    if not commands[1] then
    elseif commands[1] == 'delay' and tonumber(commands[2]) then
        settings.delay = tonumber(commands[2])
        settings:save('all')
    elseif profiles[commands[1]] then
        for name in pairs(profiles[commands[1]]) do
            check_item(name)
        end
    else
        check_item(table.concat(commands,' '))
    end
end

windower.register_event('incoming chunk', incoming_shop_packets)
windower.register_event('zone change','logout','unload',  reset)
windower.register_event('addon command', cmd)
