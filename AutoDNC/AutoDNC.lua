--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of AutoDNC nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'AutoDNC'
_addon.version = '1.20.05.19'
_addon.author = 'Ivaar'
_addon.commands = {'AutoDNC','DNC'}

res = require('resources')
config = require('config')
packets = require('packets')

_static = {
    default = {
        actions = 0,
        ja = 0,
        ws = 0,
        setws = 'Rudra\'s Storm',
        setws2 = 'Cyclone',
        distance = 4.0,
        waltzhp = 75,
        minwshp = 30,
        maxwshp = 100,
        samba = 1,
        --waltz = {p0=true,p1=true,p2=true,p3=true,p4=true,p5=true}
        waltz = 0,
        waltzpt = 0,
        na = 0,
        proc = 0,
        posx = 10,
        posy = 200
    },
    base = T{['off']=0,['on']=1},
    samba = T{['off']=0,['haste']=1,['drain']=2},
    proc = T{['off']=0,['ja']=1,['ws']=2},
    dual_toggle = S{'actions','ja','ws','waltz','waltzpt','na','silent'}
}

setting = config.load(_static.default)

clock = os.clock()
time = clock
delay = 0
JA_del = 1.2
WS_del = 4
    
function target_change()
    local mob = windower.ffxi.get_mob_by_target('t')
    local targ = windower.ffxi.get_mob_by_target('st', 't')
    if not setting.silent and setting.proc ~= 0 then
        windower.text.set_visibility('proc_box', false)
        if targ then
            for i,v in ipairs(staggered) do
                if v == targ.id then
                    windower.text.set_visibility('proc_box', true)
                    windower.text.set_text('proc_box',' Mob Staggered '..targ.id)
                end
            end
        end
    end
    if setting.proc == 1 then
        if mob then
            for i,v in ipairs(staggered) do
                if v == mob.id then
                    setting.ja = 0
                    setting.ws = 1
                    return true
                end
            end
        end
        setting.ja = 1
        setting.ws = 0
    elseif setting.proc == 2 then
        if mob then
            for i,v in ipairs(staggered) do
                if v == mob.id then
                    setting.ws = 0
                    return true
                end
            end
        end
        setting.ws = 1
    end
end
windower.register_event('target change', target_change)

windower.register_event('incoming text', function(old,new,color,newcolor)   
    if proc ~= 0 then
        local play = windower.ffxi.get_player()
        if play and string.find(old,(play.name).. '\'s attack staggers the fiend%p') then
            local targ = windower.ffxi.get_mob_by_target('t')
            local ltarg = windower.ffxi.get_mob_by_target('lastst')
            if targ then
                for k, v in ipairs(staggered) do
                    if v == targ.id and ltarg then
                        targ = ltarg
                    end
                end
            elseif ltarg then
                targ = ltarg
            end
            table.insert(staggered, targ.id)
            target_change()
            windower.send_ipc_message('add'..targ.id)
        end
    end
end)

function get_FM(buffs)
    if buffs['finishing move 1'] then
        return 1
    elseif buffs['finishing move 2'] then
        return 2
    elseif buffs['finishing move 3'] then
        return 3
    elseif buffs['finishing move 4'] then
        return 4
    elseif buffs['finishing move 5'] then
        return 5
    end
    return 0
end

windower.register_event('prerender',function ()
    local now = os.clock()
    if clock + delay <= now then
        time = clock
        clock = now
        delay = 0.1
        local play = windower.ffxi.get_player()
        local mob = windower.ffxi.get_mob_by_target('t')
        local recast = windower.ffxi.get_ability_recasts()

        if not play then return end

        local buffs = S(play.buffs):map(string.lower .. table.get-{'english'} .. table.get+{res.buffs})

        if buffs.sleep or buffs.petrification or buffs.stun or buffs.charm or buffs.amnesia or buffs.terror or buffs.lullaby or buffs.impairment then
            return
        end

        if play.status == 1 and setting.actions == 1 and mob and mob.valid_target and mob.is_npc then
            Engaged = true
        else
            Engaged = false
        end

        if play.status <= 1 and waltz(play, recast, buffs) or play.vitals.hpp < 50 then return end

        if Engaged then
            local FM = get_FM(buffs)

            if recast[216] and recast[216] == 0 and setting.samba ~= 0 then
                if not buffs['Haste samba'] and play.vitals.tp >= 350 and setting.samba == 1 then
                    return autoJA('Haste samba', '<me>')
                elseif setting.samba == 2 and not buffs['Drain samba'] then
                    if play.main_job == 'DNC' and play.vitals.tp >= 400 then
                        return autoJA('Drain samba III', '<me>')
                    elseif play.sub_job == 'DNC' and play.vitals.tp >= 250 then
                        return autoJA('Drain samba II', '<me>')
                    end
                end
            end
            if play.vitals.tp >= 1000 and setting.ws == 1 and mob.hpp >= setting.minwshp and mob.hpp <= setting.maxwshp and math.sqrt(mob.distance) <= setting.distance then
                if play.main_job == 'DNC' and FM >= 1 and recast[226] == 0 then
                    autoJA('Climactic Flourish', '<me>')
                else
                    autoWS(setting.setws)
                end
            elseif play.sub_job == 'DNC' and setting.ja == 1 then
                if recast[220] == 0 and play.vitals.tp >= 100 then
                    autoJA('Box Step', '<t>')
                elseif recast[221] == 0 and FM >= 2 then
                    autoJA('Violent Flourish', '<t>')
                elseif recast[222] == 0 and play.vitals.tp <= 400 and FM >= 4 then 
                    autoJA('Reverse Flourish', '<me>')
                elseif play.main_job == 'THF' and recast[240] == 0 then
                    autoJA('Bully', '<t>')
                end
            elseif play.main_job == 'DNC' and setting.ja == 1 then
                if recast[220] == 0 and play.vitals.tp >= 100 then
                    if recast[236] == 0 and FM < 3 then
                        autoJA('Presto', '<me>')
                    end
                    autoJA('Feather Step', '<t>')
                elseif recast[223] == 0 and FM < 2 then
                    autoJA('No Foot Rise', '<me>')
                elseif recast[221] == 0 and FM >= 1 then
                    autoJA('Violent Flourish', '<t>')
                elseif recast[222] == 0 and FM >= 2 then
                    autoJA('Wild Flourish', '<t>')	
                end
            end
        end
    end
end)

function waltz(play, recast, buffs)
    if (play.main_job ~= 'DNC' and play.sub_job ~= 'DNC') or (buffs.invisible) then return false else end
    if setting.waltz == 1 and play.vitals.hpp < setting.waltzhp and play.vitals.tp >= 500 and recast[217] == 0 then
        autoJA('Curing waltz III', '<me>')
        return true
    elseif setting.waltzpt == 1 then
        for i,member in pairs(windower.ffxi.get_party()) do
            if type(member) == 'table' and member.mob and member.hpp ~= 0 then
                if play.main_job == 'DNC' and member.hpp < 30 and play.vitals.tp >= 800 and recast[217] == 0 then
                    autoJA('Curing waltz V', member.mob.name)
                    return true
                elseif play.main_job == 'DNC' and member.hpp < 50 and play.vitals.tp >= 650 and recast[217] == 0 then
                    autoJA('Curing waltz IV', member.mob.name)
                    return true
                elseif member.hpp < setting.waltzhp and play.vitals.tp >= 500 and recast[217] == 0 then
                    autoJA('Curing waltz III', member.mob.name)
                    return true
                elseif member.hpp < 85 and play.vitals.tp >= 350 and recast[217] == 0 then
                    autoJA('Curing waltz II', member.mob.name)
                    return true
                elseif member.hpp < 95 and play.vitals.tp >= 200 and recast[217] == 0 then
                    autoJA('Curing waltz', member.mob.name)
                    return true
                end
            end
        end
    end
    if (play.vitals.tp >= 200 and setting.Hwaltz == 1 and recast[215] == 0) and
    ((play.status == 1) and (buffs.paralysis or buffs.blind or buffs.disease or buffs.slow)) or 
    ((play.status == 0) and (buffs.paralysis or buffs.bind)) then
        autoJA('Healing waltz', '<me>')
        return true
    end
    return false
end

function autoJA(str,ta)
    windower.send_command('input /ja "%s" %s':format(str,ta))
    delay = JA_del
end

function autoWS(str)
    windower.send_command('input /ws "%s" <t>':format(str))
    delay = WS_del
end

windower.register_event('incoming chunk', function(id, data)
    if id == 0x029 then
        action_message = packets.parse('incoming', data)
        if (action_message['Message'] == 6) or (action_message['Message'] == 20) then
            for k, v in ipairs(staggered) do
                if v == action_message['Target'] then
                    windower.send_ipc_message('rem'..action_message['Target'])
                    table.remove(staggered, k)
                    target_change()
                end
            end 
        end   
    end
end)

function proc_table(msg)
    local id = msg:slice(4)
    local msg = tonumber(msg:slice(1, 3))
    if msg == 'add' then
        for k,v in ipairs(staggered) do
            if v == id then
            return
            end
        end
        table.insert(staggered, id)
    elseif msg == 'rem' then
        for k,v in ipairs(staggered) do
            if v == id then
                table.remove(staggered, k)
            end
        end
    end
    target_change()
end
windower.register_event('ipc message', proc_table)

windower.register_event('load',function ()
    staggered = {}
    windower.text.create('proc_box')
    windower.text.set_bg_color('proc_box',200,30,30,30)
    windower.text.set_color('proc_box',255,200,200,200)
    windower.text.set_location('proc_box',setting.posx,setting.posy)
    windower.text.set_bg_visibility('proc_box',1)
    windower.text.set_font('proc_box','Arial')
    windower.text.set_font_size('proc_box',10)
end)

windower.register_event('unload',function ()
    windower.text.delete('proc_box')
end)

windower.register_event('zone change',function()
    staggered = {}
end)

function addon_message(msg)
    windower.add_to_chat(0,'%s: %s':format(_addon.name,msg))
end

windower.register_event('addon command', function(...)
    local commands = {...}
    if not commands[1] then return end
    commands[1] = commands[1]:lower()
    if commands[1] == 'on' then
        setting.actions = 1
        addon_message('Actions On')
    elseif commands[1] == 'off' then
        setting.actions = 0
        addon_message('Actions Off')
    elseif commands[1] == 'load' then
        setting = config.load(defaults)			
        addon_message('Global Settings Loaded.')
    elseif commands[1]:lower() == 'save' then
        setting:save()			
        addon_message('Settings Saved.')		
        --config.save(setting, 'all')
        --addon_message('Global Settings Saved.')
    elseif setting[commands[1]] then
        if not commands[2] then
            if _static.dual_toggle[commands[1]] then
                if setting[commands[1]] == 0 then
                    setting[commands[1]] = 1
                    addon_message(commands[1]..' is now set to on')
                else
                    setting[commands[1]] = 0
                    addon_message(commands[1]..' is now set to off')
                end
            elseif _static[commands[1]] then
                if _static[commands[1]]:find(setting[commands[1]]+1) then
                    setting[commands[1]] = setting[commands[1]]+1
                else
                    setting[commands[1]] = 0
                end
                addon_message(commands[1]..' is now set to '..tostring(_static[commands[1]]:find(setting[commands[1]])))
            end
        else
            commands[2] = tonumber(commands[2]) or commands[2]:lower()
            if _static[commands[1]] or _static.dual_toggle[commands[1]] then
                if _static.base[commands[2]] then
                    setting[commands[1]] = _static.base[commands[2]]
                    addon_message(commands[1]..' is now set to '..commands[2])
                elseif _static[commands[1]] and _static[commands[1]][commands[2]] then
                    setting[commands[1]] = _static[commands[1]][commands[2]]
                    addon_message(commands[1]..' is now set to '..commands[2])
                end
            elseif type(setting[commands[1]]) == type(commands[2]) then
                setting[commands[1]] = tonumber(commands[2]) or table.concat(commands, ' ',2):lower()
                addon_message(commands[1]..' is now set to '..setting[commands[1]])
            end
            if commands[1] == 'proc' then
                if (commands[2]:lower() == 'ja' or commands[2]:lower() == 'on') then
                    setting.ja = 1
                    setting.ws = 0
                elseif commands[2]:lower() == 'ws' then
                    setting.ws = 1
                    setting.ja = 0
                elseif commands[2]:lower() == 'off' then
                    setting.ja = 0
                end
            end
        end
    elseif commands[1] == 'active' then
        addon_message((setting.actions == 1 and '[On]' or '[Off]')..' Weapon Skill: '..(setting.ws == 1 and '[On]' or '[Off]')..' Job Ability: ' .. (setting.ja == 1 and '[On]' or '[Off]')..' Proc Mode: '..(setting.proc == 1 and '[Job Ability]' or setting.proc == 2 and '[Weapon Skill]' or setting.proc == 0 and '[Off]')..'\nWeapon Skill: ['..(setting.setws)..'] HP: [>'..(setting.minwshp)..'% <'..(setting.maxwshp)..'%] Distance: ['..(setting.distance)..']\nWaltz Self: '..(setting.waltz == 1 and '[On]' or '[Off]')..' Party: '..(setting.waltzpt== 1 and '[On]' or '[Off]')..' HP: [<'..(setting.waltzhp)..'%] Healing Waltz: '..(setting.na== 1 and '[On]' or '[Off]')..'\nSamba: '..(setting.samba == 1 and '[Haste Samba]' or setting.samba == 2 and '[Drain Samba]' or setting.samba == 0 and '[Off]'))	
    elseif commands[1] == 'eval' then
            assert(loadstring(table.concat(commands, ' ',2)))()
    elseif commands[1] == 'help' then
        if not commands[2] then
            addon_message('//dnc help command.\nCommands: on | off | actions | ws | ja | samba | waltz | distance\nCommands: minwshp | maxwshp | setws | proc | active | save | load')
        elseif commands[2]:lower() == 'on' then
            addon_message('//dnc on - Turn Local Actions On')
        elseif commands[2]:lower() == 'off' then
            addon_message('//dnc off - Turn Local Actions Off')
        elseif commands[2]:lower() == 'actions' then
            addon_message('actions [ on | off ] - Toggle Global Actions')
        elseif commands[2]:lower() == 'ws' then
            addon_message('ws [ on | off ] - Toggle Weapon Skill\n//dnc ws | //dnc ws on //dnc ws off')
        elseif commands[2]:lower() == 'ja' then
            addon_message('ja [ on | off ] - Toggle Job Abilities\n//dnc ja | //dnc ja on | //dnc ja off')
        elseif commands[2]:lower() == 'samba' then
            addon_message('samba [ haste | drain | off ] -- Toggle samba Mode. Default: Haste samba')
        elseif commands[2]:lower() == 'waltz' then
            addon_message('waltz [ on | off | me | pt | na | hp [number]--]\nwaltz me [ on | off ] - Toggle waltz for self\nwaltz pt [ on | off ] - Toggle waltz for party\nwaltz na [ on | off ] - Toggle Healing waltz\nwaltz [ hp ] - Set HP% Threshold for waltzes\n//dnc waltzhp 75 - Default: 75')
        elseif commands[2]:lower() == 'set' then
            addon_message('setws [ weapon skill name ] - Set Weapon Skill\n//dnc setws Rudra\'s Storm')
        elseif commands[2]:lower() == 'maxwshp' then
            addon_message('maxwshp [ hpp ] -  //dnc maxwshp 100 - Sets Max Mob WS HP%.')
        elseif commands[2]:lower() == 'minwshp' then
            addon_message('minwshp [ hpp ] -  //dnc minwshp 30 - Sets Min Mob WS HP%.')
        elseif commands[2]:lower() == 'proc' then
            addon_message('proc [ ja | ws | off ] - Sets automatic stagger mode')
        elseif commands[2]:lower() == 'active' then
            addon_message('active [ actions | ws | ja | samba | min/maxwshp | setws | waltz | proc | silent ]- Displays Active setting.')
        end
    end
end)
