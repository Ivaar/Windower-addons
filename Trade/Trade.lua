_addon.author = 'Ivaar'
_addon.command = 'trade'
_addon.name = 'Trade'
_addon.version = '1.18.04.02'

require('luau')
require('pack')

default = {}
default.whitelist = S{}

settings = config.load(default)

setkeys = 'setkey enter;wait .2;setkey enter up;wait .4;setkey up;wait .2;setkey up up;wait .2;setkey up;wait .2;setkey up up;setkey enter;wait .2;setkey enter up;wait .2;keyboard_blockinput 0;'

windower.register_event('addon command', function(name, command)
    name = name and name:lower():ucfirst()
    command = command and command:lower()

    if command == 'add' then
        if not settings.whitelist:contains(name) then
            settings.whitelist:add(name)
            settings:save('all')
        end
        windower.add_to_chat(207, '%s: %s added to whitelist':format(_addon.name, name))
        return
    elseif command == 'remove' then
        if settings.whitelist:contains(name) then
            settings.whitelist:remove(name)
            settings:save('all')
        end
        windower.add_to_chat(207, '%s: %s removed from whitelist':format(_addon.name, name))
        return
    end

    if command ~= 'ok' and name ~= 'Ok' and not settings.whitelist:contains(name) then return end

    local targ = name ~= 'Ok' and windower.ffxi.get_mob_by_name(name) or windower.ffxi.get_mob_by_target('t')

    if not targ or targ.is_npc or math.sqrt(targ.distance) > 6 then return end

    windower.send_command('keyboard_blockinput 1')
    windower.chat.input('/target %s':format(targ.name))
    coroutine.sleep(0.2)
    windower.send_command(setkeys)

    --[[
    local play = windower.ffxi.get_mob_by_target('me')

    if play.status > 1 and play.status < 5 then return end

    if targ.status > 1 and targ.status < 5 then return end

    if play.id == targ.id then return end

    windower.packets.inject_incoming(0x21, 'I2H2':pack(0x621, targ.id, targ.index, 0))
    coroutine.sleep(0.1)
    windower.packets.inject_outgoing(0x32, 'I2H2':pack(0x632, targ.id, targ.index, 0))
    ]]
end)

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x021 then
        local trader = windower.ffxi.get_mob_by_id(data:unpack('I', 5))
        if not injected and trader and settings.whitelist:contains(trader.name) then
            local status = windower.ffxi.get_mob_by_target('me').status
            if (status < 2 or status > 4) then
                windower.packets.inject_outgoing(0x33, 'I3':pack(0x633, 0, 0))
            end
        end
    elseif id == 0x022 then
        if data:byte(9) == 0x02 then
            if trade_count and settings.whitelist:contains(windower.ffxi.get_mob_by_id(data:unpack('I', 5)).name) then
                windower.packets.inject_outgoing(0x33, 'I2H2':pack(0x633, 0x02, trade_count, 0))
            end
        else
            trade_count = 0
        end
    elseif id == 0x023 then
        trade_count = data:unpack('H', 9)
    end
end)
