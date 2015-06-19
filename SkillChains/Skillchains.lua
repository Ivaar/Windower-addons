_addon.author = 'Ivaar'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '1.15.06.15'

texts = require('texts')
packets = require('packets')
config = require('config')
weapon_skills = require('resources').weapon_skills

default = {
    display = {
        text={size=10,font='Consolas'},
        pos={x=0,y=0},
        },
    }
  
settings = config.load(default)
skill_props = texts.new('',settings.display,settings)

skillchains = L{
    [288] = 'Light',
    [289] = 'Darkness',
    [290] = 'Gravitation',
    [291] = 'Fragmentation',
    [292] = 'Distortion',
    [293] = 'Fusion',
    [294] = 'Compression',
    [295] = 'Liquefaction',
    [296] = 'Induration',
    [297] = 'Reverberation',
    [298] = 'Transfixion',
    [299] = 'Scission',
    [300] = 'Detonation',
    [301] = 'Impaction',
    [385] = 'Light',
    [386] = 'Darkness',
    [387] = 'Gravitation',
    [388] = 'Fragmentation',
    [389] = 'Distortion',
    [390] = 'Fusion',
    [391] = 'Compression',
    [392] = 'Liquefaction',
    [393] = 'Induration',
    [394] = 'Reverberation',
    [395] = 'Transfixion',
    [396] = 'Scission',
    [397] = 'Detonation',
    [398] = 'Impaction',
    }

prop_info = {
    Light = {elements={'Fire','Wind','Lightning','Light'},properties={[1]={Light='Light'}},level=3},
    Darkness = {elements={'Earth','Ice','Water','Dark'},properties={[1]={Darkness='Darkness'}},level=3},
    Gravitation = {elements={'Earth','Dark'},properties={[1]={Distortion='Darkness'},[2]={Fragmentation='Fragmentation'}},level=2},
    Fragmentation = {elements={'Wind','Lightning'},properties={[1]={Fusion='Light'},[2]={Distortion='Distortion'}},level=2},
    Distortion = {elements={'Ice','Water'},properties={[1]={Gravitation='Darkness'},[2]={Fusion='Fusion'}},level=2},
    Fusion = {elements={'Fire','Light'},properties={[1]={Fragmentation='Light'},[2]={Gravitation='Gravitation'}},level=2},
    Compression = {elements={'Dark'},properties={[1]={Transfixion='Transfixion'},[2]={Detonation='Detonation'}},level=1},
    Liquefaction = {elements={'Fire'},properties={[1]={Impaction='Fusion'},[2]={Scission='Scission'}},level=1},
    Induration = {elements={'Ice'},properties={[1]={Reverberation='Fragmentation'},[2]={Compression='Compression'},[3]={Impaction='Impaction'}},level=1},
    Reverberation = {elements={'Water'},properties={[1]={Induration='Induration'},[2]={Impaction='Impaction'}},level=1},
    Transfixion = {elements={'Light'},properties={[1]={Scission='Distortion'},[2]={Reverberation='Reverberation'},[3]={Compression='Compression'}},level=1},
    Scission = {elements={'Earth'},properties={[1]={Liquefaction='Liquefaction'},[2]={Reverberation='Reverberation'},[3]={Detonation='Detonation'}},level=1},
    Detonation = {elements={'Wind'},properties={[1]={['Compression']='Gravitation'},[2]={['Scission']='Compression'}},level=1},
    Impaction = {elements={'Lightning'},properties={[1]={Liquefaction='Liquefaction'},[2]={Detonation='Detonation'}},level=1},
    }
    
resonating = {}

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        if packet['Category'] == 3 then
            if packet['Target 1 Action 1 Has Added Effect'] and skillchains[packet['Target 1 Action 1 Added Effect Message']] then
                --print('%s > %s %s':format(packet['Target 1 ID'],skillchains[packet['Target 1 Action 1 Added Effect Message']],os.clock()))
                local ws = weapon_skills[packet['Param']]
                local reson = resonating[packet['Target 1 ID']]
                local prop = skillchains[packet['Target 1 Action 1 Added Effect Message']]
                local closed
                --if not ws then print(packet['Param'],prop) end
                if S{'Darkness','Light'}:contains(prop) and reson and not reson.closed and reson.active[1] == prop then 
                    if not reson.skillchain and weapon_skills[reson.ws.id].skillchain_a == ws.skillchain_a then
                        closed = true   
                    elseif reson.skillchain then
                        closed = true
                    end
                end
                resonating[packet['Target 1 ID']] = {
                    active={prop},
                    timer=os.clock(),
                    ws=ws,
                    skillchain=true,
                    closed = closed,
                    }
            elseif L{185,187}:contains(packet['Target 1 Action 1 Message']) then
                --print('%s > %s %s':format(packet['Target 1 ID'],weapon_skills[packet['Param']].en,os.clock()))              
                local ws = weapon_skills[packet['Param']]
                --if not ws then print(packet['Param']) end
                resonating[packet['Target 1 ID']] = {
                    active={ws.skillchain_a,ws.skillchain_b,ws.skillchain_c},
                    timer=os.clock(),
                    ws=ws,
                    skillchain=false,
                    }
            end
        end
    end
end)

windower.register_event('prerender', function()
    local targ = windower.ffxi.get_mob_by_target('t')
    local now = os.clock()
    for k,v in pairs(resonating) do
        if now-v.timer > 10 then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] then
        skill_props:text(display_skills(targ.id))
        skill_props:show()
    else
        skill_props:hide()        
    end
end)

function display_skills(targ)
    if resonating[targ].closed then return '' end
    local str = ''
    local now = os.clock()
    if now-resonating[targ].timer < 3 then
        str = ' wait %s \n':format(math.abs(math.floor(now-resonating[targ].timer-3)))
    elseif now-resonating[targ].timer < 10 then
        str = ' GO! %s \n':format(math.abs(math.floor(now-resonating[targ].timer-10)))
    end
    str = str..' >>  %s >>':format(resonating[targ].ws.en)
    for k,element in pairs(resonating[targ].active) do
        if element ~= '' then str = str..' %s >>':format(element) else resonating[targ].active[k] = nil end
        if resonating[targ].skillchain then
            str = str..get_elements(element)
        end
    end

    local strn = #str
    
    local skills = chain_res(resonating[targ].active)
    for x = -3,-1 do
        x = math.abs(x)
        for i,v in pairs(skills[x]) do
            if v then
                str = str..'\n %s  >> Lv.%d %s ':format(i,x,v)
            end
        end
    end
    
    if #str == strn then str = '' end
    return str
end

function get_elements(element)
    str = '('
    for k,v in pairs(prop_info[element].elements) do
        str = str..'%s ':format(v)
    end
    str = str:trim()
    return str..')'
end

function chain_res(reson)
    local skills = {[1]={},[2]={},[3]={}}
    for i,t in ipairs(windower.ffxi.get_abilities().weapon_skills) do
        local ws = weapon_skills[t]
        for key,element in ipairs(reson) do
            local props = prop_info[element].properties
            for x=1,#props do
                for k,v in pairs(props[x]) do
                    if S{ws.skillchain_a,ws.skillchain_b,ws.skillchain_c}:contains(k) and not skills[prop_info[v].level][ws.en] then
                        skills[prop_info[v].level][ws.en] = v
                    end
                end
            end
        end
    end
    return skills
end

windower.register_event('addon command', function(...)
    local commands = {...}
    if commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
end)
