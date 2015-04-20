--[[Copyright Â© 2015, Ivaar
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
_addon.name = 'ChatManager'
_addon.commands = {'chatman', 'cm'}
_addon.version = '1.0.0.1'
_addon.author = 'Ivaar'

packets = require('packets')
config = require('config')

defaults = {gm={sound=true,delay=5},tell={sound=true,delay=5},talk={sound=true,delay=5},emote={sound=true,delay=5},invite={sound=true,delay=5},examine={sound=true,delay=5}}
settings = config.load(defaults)
last_chat = {gm=0,tell=0,talk=0,emote=0,invite=0,examine=0}

On = '\31\204on\30\1'
Off = '\31\167off\30\1'

function check_setting(chat)
    if settings[chat].sound and os.clock()-settings[chat].delay >= last_chat[chat] then
        windower.play_sound(windower.addon_path .. '%s.wav':format(chat))
        last_chat[chat] = os.clock()
    end
end

windower.register_event('incoming chunk', function(id,data)
    if id == 0x017 then
        local chat = packets.parse('incoming', data)
        if chat['Mode'] == 12 or chat['gm'] then
            check_setting('gm')
        elseif chat['Mode'] == 3 and chat['Sender Name'] ~= windower.ffxi.get_player().name then
            check_setting('tell')
        elseif chat['Message']:lower():contains(windower.ffxi.get_player().name:lower()) and (chat['Mode'] == 0 or chat['Mode'] == 1 or chat['Mode'] == 4 or chat['Mode'] == 5 or chat['Mode'] == 26) then
            check_setting('talk')
        end
    elseif id == 0x0DC then
        check_setting('invite')
    end
end)

windower.register_event('emote', function(emote_id,sender_id,target_id)
    if target_id == windower.ffxi.get_player().id and sender_id ~= windower.ffxi.get_player().id then
        check_setting('emote') 
    end
end)

windower.register_event('examined', function(sender_name,sender_index)
    if sender_name ~= windower.ffxi.get_player().name then
        check_setting('examine')
    end
end)

windower.register_event('addon command', function(command,arg1,arg2)
    if settings[command] then
        if tonumber(arg1) then
            settings[command:lower()].delay = tonumber(arg1)
        elseif tonumber(arg2) then
            settings[command:lower()].delay = tonumber(arg2)
        end
        if arg1 and arg1 == 'on' or arg2 == 'on' then
            settings[command:lower()].sound = true
        elseif arg1 and arg1 == 'off' or arg2 == 'off' then
            settings[command:lower()].sound = false
        end
        config.save(settings, 'all')
    elseif command == 'save' then
        settings:save()
        print('Settings saved to %s':format(windower.ffxi.get_player().name))
    else
        print('valid commands: tell talk invite emote examine\ncommand arguments: [on] or [off] and or [replay delay(seconds)]\ne.g //cm tell on 5')
    end
    windower.add_to_chat(207, 'Sound/Replay delay [GM %s/%s] [Tell %s/%s] [Talk %s/%s] [Emote %s/%s] [Examine %s/%s] [Invite %s/%s]':format(settings.gm.sound and On or Off, settings.gm.delay, settings.tell.sound and On or Off, settings.tell.delay, settings.talk.sound and On or Off, settings.talk.delay, settings.emote.sound and On or Off, settings.emote.delay, settings.examine.sound and On or Off, settings.examine.delay, settings.invite.sound and On or Off, settings.invite.delay))
end)
