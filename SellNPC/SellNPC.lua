_addon.command = 'SellNPC'
_addon.version = '2.0.0.0'
_addon.author = 'Ivaar'

require('sets')
profiles = require('profiles')
res_items = require('resources').items

sales_que = {}
selling = false

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

function incoming_shop_open(id, data)
    if id == 0x03C then
        if not selling then
            selling = true
            for index = 1, 80 do local item = windower.ffxi.get_items(0,index)
                if item and sales_que[item.id] and item.status == 0 then
                    windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,item.count,0,0,0,item.id%256,math.floor(item.id/256)%256,index,0))
                    windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
                end
            end
            sales_que = {}
            selling = false
        end
    end
end

function cmd(...)
    local commands = {...}
    if not commands[1] then
    elseif profiles[commands[1]] then
        for name in pairs(profiles[commands[1]]) do
            check_item(name)
        end
    else
        check_item(table.concat(commands,' '))
    end
end

windower.register_event('incoming chunk', incoming_shop_open)
windower.register_event('addon command', cmd)
