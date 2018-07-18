_addon.command = 'NPCit'
_addon.version = '1.18.07.07'
_addon.author = 'Ivaar'

res_items = require('resources').items

function get_item_res(item)
    for k,v in pairs(res_items) do
        if v.en:lower() == item or v.enl:lower() == item then
            return v
        end
    end
    return nil
end

function sell_item(item_id, index, count)
    if not appraised[item_id] then
        windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,1,0,0,0,item_id%256,math.floor(item_id/256)%256,index,0))
        coroutine.sleep(1)
        appraised[item_id] = true
    end
    windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,count,0,0,0,item_id%256,math.floor(item_id/256)%256,index,0))
    windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,1,0,0,0))
end

function sell_all(item_id)
    for index, item in ipairs(windower.ffxi.get_items(0)) do
        if item and item.id == item_id and item.status == 0 then
            sell_item(item_id, index, item.count)
        end
    end
    return false
end

function check_item(name)
    local item = get_item_res(windower.convert_auto_trans(name):lower())
    if not item then actions=false,print('Error: %s not a valid item name.':format(name)) return end
    if item.flags['No NPC Sale'] then actions=false,print('Error: Cannot sell %s to npc vendors':format(item.en)) return end
    if not actions then actions = true return sell_all(item.id) end
end

function cmd(...)
    local commands = {...}
    if commands[1] and appraised then
        check_item(table.concat(commands,' ',1))
    end
end
windower.register_event('addon command', cmd)

function reset()
    appraised = nil
end
windower.register_event('zone change','logout',  reset)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if id == 0x03C then
        appraised = {}
    --elseif id == 0x03D then
    --   windower.ffxi.get_items(data:byte(9),data:byte(10)).item_id
    end
end)
