require 'lists'
require 'tables'
packets = require('packets')
res_items = require('resources').items

_addon.command = 'SellNPC'
_addon.version = '1.0.0.1'
_addon.author = 'Ivaar'

sales_que = L{}

function get_item_res(item)
	for k,v in pairs(res_items) do
		if v.en:lower() == item:lower() or v.enl:lower() == item:lower() then
			return v
		end
	end
	return nil
end

function find_item(item_id)
	local items = windower.ffxi.get_items(0)
	for ind,item in ipairs(items) do
		if item and item.id == item_id and item.status == 0 then
			return ind,item.count
		end
	end
	return false
end

function check_que(item)
	local ind = sales_que:find(item)
	if ind then
		table.remove(sales_que, ind)
	end
	if sales_que[1] then
		return sell_npc_item(sales_que[1])
	else
		print('Selling Finished')
	end
end

function check_item(name)
	local item = get_item_res(name)
	if not item then actions=false,print('Error: %s not a valid item name.':format(name)) return check_que() end
	if item.flags['No NPC Sale'] == true then actions=false,print('Error: Cannot sell %s to npc vendors':format(item.en)) return check_que(item.id) end
	table.insert(sales_que, item.id)
	if not actions then actions = true return sell_npc_item(item.id) end
end

function sell_npc_item(item)
	if not appraised then actions = false return end
	local index,count = find_item(item)
	if not index then 
		actions=false
		if not appraised[item] then
			print('Error: %s not found in inventory.':format(res_items[item].en)) 
		end
		return check_que(item) 
	end
	if not appraised[item] then count = 1 end
	windower.packets.inject_outgoing(0x084,string.char(0x084,0x06,0,0,(count%256),0,0,0,(item%256),(math.floor((item/256)%256)),(index%256),0))
	if not appraised[item] then appraised[item]=true,coroutine.sleep((1+math.random())) return sell_npc_item(item) end
	windower.packets.inject_outgoing(0x085,string.char(0x085,0x04,0,0,0x01,0,0,0))
	coroutine.sleep((1+math.random()))
	return sell_npc_item(item)
end

function cmd(...)
	local commands = {...}
	if not commands[1] then return end
	if commands[1] then
		check_item(table.concat(commands,' ',1))
	elseif appraised then
		check_que()
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
	--[[elseif id == 0x03D then
		local packet = packets.parse('incoming',original)
		windower.add_to_chat(207, 'Incoming  %s >>   %s':format(id:hex(),original:hex()))
	elseif id ~= 0x00D and id ~= 0x00E and id ~= 0x67 and id ~= 0x063 and id ~= 0x04F and id ~= 0x051 and id ~= 0x050 and id ~= 0x01E and id ~= 0x01D and id ~= 0x01F and id ~= 0x061 and id ~= 0x05B and id ~= 0x062 and id ~= 0x0DF and id ~= 0x037 and id ~= 0x119 then
	--]]	--print(id:hex())
	end
end)


	-- sell_pack = string.char(0x084,0x06,0,0,(count%256),0,0,0,(item%256),(math.floor((item/256)%256)),(index%256),0))
	-- print('Modified packet 0x084: %s\n%s bytes':format(space_hex(sell_pack:hex()),#sell_pack))

	-- sell_confirm = string.char(0x085,0x04,0,0,0x01,0,0,0))
	-- print('Modified packet 0x085: %s\n%s bytes':format(space_hex(sell_confirm:hex()),#sell_confirm))

function space_hex(n)
	local left,num,right = string.match(n,'^([^%x]*%x)(%x*)(.-)$')
	return left..(num:reverse():gsub('(%x%x)','%1 '):reverse())..right
end

windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
	if id == 0x084 then
		local packet = packets.parse('outgoing',original)
		--print('Original: %s':format(original:hex()))
		--windower.add_to_chat(207, 'Outgoing  %s >>   %s':format(id:hex(),original:hex()))
	elseif id == 0x085 then
		local packet = packets.parse('outgoing',original)	
		--windower.add_to_chat(207, 'Outgoing  %s >>   %s':format(id:hex(),original:hex()))
	elseif id ~= 0x015 then
		--print(id:hex())
	elseif id ~= 0x05B then
		--windower.add_to_chat(207, 'Outgoing  %s >>   %s':format(id:hex(),original:hex()))
	end
end)
