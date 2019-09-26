require('pack')
bit = require('bit')
res_items = require('resources').items

_addon.name = 'TradeNPC'
_addon.author = 'Ivaar'
_addon.version = '1.19.09.26'
_addon.command = 'tradenpc'

function get_item_res(item)
    for k,v in pairs(res_items) do
        if v.en:lower() == item or v.enl:lower() == item then
            return v
        end
    end
    return nil
end

function find_item(inventory, item_id, count, exclude)
    for k, v in ipairs(inventory) do
        if v.id == item_id and v.count >= count and v.status == 0 and not exclude[k] then
            return k
        end
    end
    return nil
end

function format_price(price)
    price = not string.match(price,'%a') and price:gsub('%p', '')
    price = price and tonumber(price)
    if price and price > 0 then
        return price
    end
    return nil
end

windower.register_event('addon command', function(...)
    local args = {...}
    if #args < 2 then
        print('tradenpc <quantity> <item name>\ne.g. //tradenpc 100 "1 byne bill"')
        return
    end
    if windower.ffxi.get_mob_by_target('me').status ~= 0 then return end
    local target = windower.ffxi.get_mob_by_target('t')
    
    if #args%2 == 1 then
        target = windower.ffxi.get_mob_by_name(args[#args])
        args[#args] = nil
    end
    
    if target and target.is_npc and bit.band(target.spawn_type, 2) == 2 and target.valid_target and target.distance <= 35.9 then
        local ind = {}
        local qty = {}
        local start = 1
        if args[2]:lower() == 'gil' then
            local units = format_price(args[1])
            if not units or units > windower.ffxi.get_items('gil') then
                print('Invalid gil amount')
                return
            end
            ind[1] = 0
            qty[1] = units
            start = 2
        end
        local inventory = windower.ffxi.get_items(0)
        if not inventory then return end
        local exclude = {}
        for x = start, 9 do
            if not args[x*2] then
                break
            end
            local units = tonumber(args[x*2-1])
            local name = windower.convert_auto_trans(args[x*2]):lower()
            local item = get_item_res(name)
            if not item or item.flags['Linkshell'] == true then
                print('"%s" not a valid item name: arg %d':format(name, x*2))
                return
            end
            if not units or units < 1 then
                print('Invalid quantity: arg %d':format(x*2-1))
                return
            end
            while units > 0 do
                local count = units > item.stack and item.stack or units
                local index = find_item(inventory, item.id, count, exclude)
                if not index then
                    print('%s x%s not found in inventory.':format(item.name, args[x*2-1]))
                    return
                end
                exclude[index] = true
                ind[#ind+1] = index
                qty[#qty+1] = count
                units = units - count
            end
        end
        local num = #ind
        if num > 0 and num < start+8 then
            for x = num, 8 do
                ind[x+1] = 0
                qty[x+1] = 0
            end
            local menu_item = 'C4I11C10HI':pack(0x36,0x20,0x00,0x00,target.id,
                qty[1],qty[2],qty[3],qty[4],qty[5],qty[6],qty[7],qty[8],qty[9],0x00,
                ind[1],ind[2],ind[3],ind[4],ind[5],ind[6],ind[7],ind[8],ind[9],0x00,
                target.index,num)
            windower.packets.inject_outgoing(0x36, menu_item)
        else
            print('Too many items')
        end
    else
        print('No target or too far away.')
    end
end)
--[[
Copyright © 2018, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of TradeNPC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
