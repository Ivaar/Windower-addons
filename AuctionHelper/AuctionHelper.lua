--[[
Copyright © 2015, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
require('lists')
texts = require('texts')
config = require('config')
packets = require('packets')
res_items = require('resources').items
res_zones = require('resources').zones

windower.send_command('unload bidder')

_addon.command = 'AH'
_addon.name = 'AuctionHelper'
_addon.version = '1.0.0.3'
_addon.author = 'Ivaar'

default = {
    text = {size = 10,font = 'Consolas',pos = {x = 390,y = 50}},
    auction_list = {
        visibility=true,
        timer=true,
        date=true,
        price=false,
        empty=true,
        slot=true,
    },
}

settings = config.load(default)
auction_list = texts.new(settings)

zones = {}
zones.ah = L{'Bastok Mines', 'Bastok Markets', 'Norg', 'Southern San d\'Oria', 'Port San d\'Oria', 'Raboa', 'Windurst Woods', 'Windurst Walls', 'Kazham', 'Lower Jueno', 'Ru\'Lude Gardens', 'Port Jueno', 'Upper Jueno', 'Aht Urhgan Whitegate', 'Al Zahbi', 'Nashmau', 'Tavnazian Safehold', 'Western Adoulin', 'Eastern Adoulin'}
zones.mh = {}

function timef(ts)
    --return string.format('%.2d:%.2d:%.2d',ts/(60*60), ts/60%60, ts%60);
    return string.format('%d days %.2d:%.2d:%.2d',ts/(60*60*24), ts/(60*60)%24, ts/60%60, ts%60);
end;

local display_box = function()
    local outstr = '';
    for x = 0,6 do
        if (auction_box[x] ~= nil) then
            local str = '';
            if (settings.auction_list.empty == true or auction_box[x].status ~= 'Empty') then
                if (settings.auction_list.slot) == true then
                    str = str..string.format(' Slot:%s', x+1)
                end
                str = str..string.format(' %s',auction_box[x].status);
            end	
            if (auction_box[x].status ~= 'Empty') then
                local timer = auction_box[x].status == 'On auction' and auction_box[x].timestamp+248836 or auction_box[x].timestamp
                if (settings.auction_list.timer) then
                    str = str..string.format(' %s',(auction_box[x].status == 'On auction' and os.time()-timer > 0) and 'Expired' or timef(math.abs(os.time()-timer)))
                end
                if (settings.auction_list.date) then
                    str = str..string.format(' [%s]',os.date('%c', timer))
                end
                str = str..string.format(' %s ',res_items[auction_box[x].item].en)
                if (auction_box[x].count ~= 1) then
                    str = str..string.format('x%d ',auction_box[x].count)
                end
                if (settings.auction_list.price) then
                    str = str..string.format('[%s] ',comma_value(auction_box[x].price));
                end
            end
            if (str ~= '') then 
                outstr = outstr ~= '' and outstr .. '\n' .. str or str
            end
        end
    end
    return outstr;
end;

windower.register_event('prerender', function()
    if auction_box and settings.auction_list.visibility then
        auction_list:text(display_box())
        auction_list:show()
    --else
    --	auction_list:hide()
    end
end)

windower.register_event('logout', function(name)
    auction_box = nil
    auction_list:hide()
end)

windower.register_event('addon command', function(...)
    local commands = {...}
    local now = os.clock()
    if zones.ah:contains(res_zones[windower.ffxi.get_info().zone].name) and (not lclock or lclock < now) then	
        if not commands[1] then
            lclock = now+1
            open_menu_command()
            return 
        end
        commands[1] = commands[1]:lower()
        if (commands[1] == 'buy' or commands[1] == 'sell') and commands[4] then
            if ah_proposal(commands[1],table.concat(commands, ' ',2,#commands-2):lower(),commands[#commands-1]:lower(),commands[#commands]) then lclock = now+3 end
        elseif commands[1] == 'clear' and commands[2] and commands[2]:lower() == 'sold' and auction_box then
            lclock = now+1
            for x=0,6 do
                if auction_box[x] and(auction_box[x].status == 'Sold' or auction_box[x].status == 'Not Sold') then
                    print(x)
                    remove_sold(x)
                    coroutine.sleep(1+math.random())
                    lclock = lclock+1
                end
            end
        end
    end
    if commands[1] == 'hide' then
        if #commands == 1 then
            settings.auction_list.visibility = false
            auction_list:visible(false)
        elseif default.auction_list[commands[2]:lower()] ~= nil then
            settings.auction_list[commands[2]:lower()] = false
        end
        return
    elseif commands[1] == 'show' then
        if #commands == 1 then
            settings.auction_list.visibility = true
            auction_list:visible(true)
        elseif default.auction_list[commands[2]:lower()] ~= nil then
            settings.auction_list[commands[2]:lower()] = true
        end
        return
    elseif commands[1] == 'save' then
        config.save(settings, 'all')
        return
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
        return
    end
end)

windower.register_event('unhandled command', function(...)
    local commands = {...}
    commands[1] = commands[1]:lower()
    if commands[1] ~= 'buy' and commands[1] ~= 'sell' and commands[1] ~= 'inbox' and commands[1] ~= 'outbox' and commands[1] ~= 'ibox' and commands[1] ~= 'obox' then return end
    if not zones.ah:contains(res_zones[windower.ffxi.get_info().zone].name) then return end
    local now = os.clock()
    if not lclock or lclock < now then
        if (commands[1] == 'outbox' or commands[1] == 'obox') then	
            lclock = now+3
            local obox = string.char(0x4B,0x0A,0x00,0x00,0x0D,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x01,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF)
            --print('Modified packet 0x04B: %s\n%s bytes':format(space_hex(obox:hex()),#obox))
            windower.packets.inject_incoming(0x4B,obox)
        elseif (commands[1] == 'inbox' or commands[1] == 'ibox') then
            lclock = now+3
            local ibox = string.char(0x4B,0x0A,0x00,0x00,0x0E,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x01,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF)
            --print('Modified packet 0x04B: %s\n%s bytes':format(space_hex(ibox:hex()),#ibox))
            windower.packets.inject_incoming(0x4B,ibox)
        elseif (commands[1] == 'buy' or commands[1] == 'sell') and commands[4] then
            if ah_proposal(commands[1],table.concat(commands, ' ',2,#commands-2):lower(),commands[#commands-1]:lower(),commands[#commands]) then lclock = now+3 end
        end
    end
end)

function update_sales_status(packet)
    if auction_box and packet.Slot ~= 7 and packet['Sale status'] ~= 0x02 and packet['Sale status'] ~= 0x04 and packet['Sale status'] ~= 0x10 then
        if packet['Sale status'] == 0 then
            auction_box[packet.Slot] = {}
            auction_box[packet.Slot].status = 'Empty'	
        else
            if packet['Sale status'] == 0x03 then
                auction_box[packet.Slot].status = 'On auction'
            elseif packet['Sale status'] == 0x0A or packet['Sale status'] == 0x0C or packet['Sale status'] == 0x15 then
                auction_box[packet.Slot].status = 'Sold'	
            elseif packet['Sale status'] == 0x0B or packet['Sale status'] == 0x0D or packet['Sale status'] == 0x16 then
                auction_box[packet.Slot].status = 'Not Sold'
            end
            auction_box[packet.Slot].timestamp = packet['Timestamp']
            auction_box[packet.Slot].price = packet['Price']
            auction_box[packet.Slot].item = packet['Item']
            auction_box[packet.Slot].count = packet['Count']
            --auction_box[packet.Slot].category = packet['AH Category']
        end
    end
end	--packet['Name'])

function find_empty_slot()
    if auction_box then
        for x = 0,6 do
            if auction_box[x] and auction_box[x].status == 'Empty' then
                return x
            end
        end
    end
    return nil
end

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if id == 0x04C then
        local packet = packets.parse('incoming',original)
        if packet['Type'] == 0x04 then
            local last_4e = windower.packets.last_outgoing(0x04E)
            local slot = find_empty_slot()
            local price = last_4e:sub(9,12)
            local fee = original:byte(9)+original:byte(10)*256+original:byte(11)*256^2+original:byte(12)*256^3
            if last_4e:byte(3)+last_4e:byte(4) == 0 and slot and packet['Success'] == 1 and last_4e:byte(5) == 0x04 and original:sub(13,17) == last_4e:sub(13,17) and windower.ffxi.get_items().gil >= fee then
                local sell_confirm = string.char(0x4E,0x1E,0,0,0x0B,slot,0,0)..last_4e:sub(9,12)..original:sub(13,14)..string.char(0,0)..last_4e:sub(17)	
                coroutine.sleep(math.random())
                --print('Modified packet 0x04E: %s\n%s bytes':format(space_hex(sell_confirm:hex()),#sell_confirm))
                windower.packets.inject_outgoing(0x4E,sell_confirm)
            end	
        elseif packet['Type'] == 0x0A then
            if original:byte(7) == 1 then
                if not auction_box then auction_box = {} end
                if not auction_box[packet.Slot] then auction_box[packet.Slot] = {} end
                update_sales_status(packet)
            end
        elseif packet['Type'] == 0x0B or packet['Type'] == 0x0D then
            if original:byte(7) == 1 then
                update_sales_status(packet)
            end
        elseif packet['Type'] == 0x0C or packet['Type'] == 0x10 then
            if original:byte(7) == 1 then
                update_sales_status({['Slot']=original:byte(6),['Sale status']=0})
            end
        elseif packet['Type'] == 0x0E then
            if original:byte(7) == 1 then
                windower.add_to_chat(207, 'Bid Success')
            elseif original:byte(7) == 0xC5 then
                windower.add_to_chat(207, 'Bid Failed')
            end
        end
    end
end)

function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function space_hex(n)
    local left,num,right = string.match(n,'^([^%x]*%x)(%x*)(.-)$')
    return left..(num:reverse():gsub('(%x%x)','%1 '):reverse())..right
end

function get_item_res(item)
    for k,v in pairs(res_items) do
        if v.en:lower() == item:lower() or v.enl:lower() == item:lower() then
            return v
        end
    end
    return nil
end

function find_item(item_id,item_count)
    local items = windower.ffxi.get_items(0)
    for ind,item in ipairs(items) do
        if item and item.id == item_id and item.count >= item_count and item.status == 0 then
            return ind
        end
    end
    return false
end

function open_menu_command()
    if windower.ffxi.get_info().logged_in then
        local o_menu = string.char(0x4C,0x1E,0,0,0x02,0,0x01,0)..string.char(0,0,0,0,0,0,0,0)
        o_menu = o_menu..string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)
        o_menu = o_menu..string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)
        o_menu = o_menu..string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0)
        --print('Modified packet 0x04C: %s\n%s bytes':format(space_hex(o_menu:hex()),#o_menu))
        windower.packets.inject_incoming(0x4C,o_menu)
    end
end

function remove_sold(slot)
    if auction_box and slot and auction_box[slot] and (auction_box[slot].status == 'Sold' or auction_box[slot].status == 'Not Sold') then
        local i_sold = string.char(0x4E,0x1E,0,0,0x10,slot,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        --print('Modified packet 0x04E: %s\n%s bytes':format(space_hex(i_sold:hex()),#i_sold))
        windower.packets.inject_outgoing(0x4E,i_sold)
    end
end

function ah_proposal(bid, item_name, vol, price)
    item_name = windower.convert_auto_trans(item_name)
    local item = get_item_res(item_name)
    if not item then 
        print('AHPack Error: %s not a valid item name.':format(item_name)) 
        return false
    end
    
    if item.flags['No Auction'] == true then 
        print(item.flags) 
        return false
    end
    
    local single
    if (item.stack ~= 1) and (vol == '1' or vol == 'stack') then
        single = 0
    elseif vol == '0' or vol == 'single' then
        single = 1
    else print('AHPack Error: Specify Stack or Single') return false end
    local trans = string.char(0x4E,0x1E,0,0)
    
    price = price:gsub('%p', '')
    if (not price) or
      (string.match(price,'%a')) or
      (not tonumber(price)) or
      (tonumber(price) < 1) or
      (bid == 'sell' and tonumber(price) > 999999999) or
      (bid == 'buy' and tonumber(price) > windower.ffxi.get_items().gil) then
        print('AH Error: Invalid price.')
        return false
    end
    price = tonumber(price)
    
    if bid == 'buy' then
        local slot = find_empty_slot() == nil and 0x07 or find_empty_slot()
        trans = trans..string.char(0x0E,slot,0,0, (price%256), (math.floor((price/256)%256)), (math.floor((price/65536)%256)), (math.floor((price/16777216)%256)), (item.id%256), (math.floor((item.id/256)%256)),0,0)
        --print('%s "%s" %s %s ID:%s':format(bid, item.en, comma_value(price),single == 1 and '[Single]' or '[Stack]',item.id))
    elseif bid == 'sell' then
        if not auction_box then print('AH Error: Click auction counter or use /ah to initialize sales.') return	end
        if not find_empty_slot() then print('AHPack Error: No Empty Slots Available.') return end
        trans = trans.. string.char(0x04,0,0,0, (price%256), (math.floor((price/256)%256)), (math.floor((price/65536)%256)), (math.floor((price/16777216)%256)))
        local index = find_item(item.id, single == 1 and single or item.stack)
        if not index then print('AHPack Error: %s of %s not found in inventory.':format(single == 1 and 'Single' or 'Stack',item.en)) return end
        trans = trans..string.char((index%256), (math.floor((index/256)%256)), (item.id%256), (math.floor((item.id/256)%256)))
        --print('%s "%s" %s %s ID:%s Ind:%s':format(bid, item.en, comma_value(price),single == 1 and '[Single]' or '[Stack]',item.id,index))
    else return false end
    
    trans = trans..string.char(single,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    --print('Modified packet 0x04E: %s\n%s bytes':format(space_hex(trans:hex()),#trans))	
    windower.packets.inject_outgoing(0x4E,trans)
    return true
end
