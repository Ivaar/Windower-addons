_addon.command = 'trade' 

packets = require('packets')

whitelist = L{
    'names',
}
windower.register_event('addon command', function(name,bool)
    local targ = name and windower.ffxi.get_mob_by_name(name) or windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t')
    if not bool and targ and math.sqrt(targ.distance) <= 6 and not targ.is_npc and whitelist:contains(targ.name) and targ.id ~= windower.ffxi.get_player().id then
        windower.send_command('keyboard_blockinput 1;input /target %s;wait .2;setkey enter;wait .2;setkey enter up;wait .4;setkey up;wait .2;setkey up up;wait .2;setkey up;wait .2;setkey up up;setkey enter;wait .2;setkey enter up;wait .2;keyboard_blockinput 0;':format(name))
    --elseif bool and targ and math.sqrt(targ.distance) < 6 and not targ.is_npc and whitelist:contains(targ.name) and targ.id ~= windower.ffxi.get_player().id then
        --trade window opens for target but not for player
        --print((targ.id%256):hex(), math.floor((targ.id/256)%256):hex(), math.floor((targ.id/65536)%256):hex(), math.floor((targ.id/16777216)%256):hex(), (targ.index%256):hex(), math.floor((targ.index/256)%256):hex())
        --windower.packets.inject_outgoing(0x32,string.char(0x32,0x06,0,0, (targ.id%256), math.floor((targ.id/256)%256), math.floor((targ.id/65536)%256), math.floor((targ.id/16777216)%256), (targ.index%256), math.floor((targ.index/256)%256),0,0))
    end
end)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if id == 0x021 then
        local packet = packets.parse('incoming',original)
        trader_name = windower.ffxi.get_mob_by_id(packet['Player']).name
        if whitelist:contains(trader_name) then
            windower.packets.inject_outgoing(0x33,string.char(0x33,0x06,0,0,0,0,0,0,0,0,0,0))
        end
    elseif id == 0x022 then
        local packet = packets.parse('incoming',original)
            if packet['Type'] == 2 then
            trader_name = windower.ffxi.get_mob_by_id(packet['Player']).name
            if trade_count and whitelist:contains(trader_name) then
                windower.packets.inject_outgoing(0x33,string.char(0x33,0x06,0,0,0x02,0,0,0, (trade_count%256), math.floor(trade_count/256),0,0))
            end
        else
            trade_count = 0
        end
    elseif id == 0x023 then
        trade_count = original:byte(9)+original:byte(10)*256
    end
end)
