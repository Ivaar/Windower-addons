_addon.author = 'Ivaar'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '1.15.06.23'

texts = require('texts')
packets = require('packets')
config = require('config')
res = require('resources')

default = {
    ws=true,
    ma=true,
    display = {
        text={size=10,font='Consolas'},
        pos={x=0,y=0},
        },
    }
  
settings = config.load(default)
skill_props = texts.new('',settings.display,settings)

lvl3 = S{'Darkness','Light'}

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
    
elements = L{
    [0]={mb='Fire',sc='Liquefaction'},
    [1]={mb='Ice',sc='Induration'},
    [2]={mb='Wind',sc='Detonation'},
    [3]={mb='Earth',sc='Scission'},
    [4]={mb='Lightning',sc='Impaction'},
    [5]={mb='Water',sc='Reverberation'},
    [6]={mb='Light',sc='Transfixion'},
    [7]={mb='Dark',sc='Compression'},
    }

prop_info = {
    Light = {elements='Fire Wind Lightning Light',properties={[1]={Light='Light'}},level=3},
    Darkness = {elements='Earth Ice Water Dark',properties={[1]={Darkness='Darkness'}},level=3},
    Gravitation = {elements='Earth Dark',properties={[1]={Distortion='Darkness'},[2]={Fragmentation='Fragmentation'}},level=2},
    Fragmentation = {elements='Wind Lightning',properties={[1]={Fusion='Light'},[2]={Distortion='Distortion'}},level=2},
    Distortion = {elements='Ice Water',properties={[1]={Gravitation='Darkness'},[2]={Fusion='Fusion'}},level=2},
    Fusion = {elements='Fire Light',properties={[1]={Fragmentation='Light'},[2]={Gravitation='Gravitation'}},level=2},
    Compression = {elements='Dark',properties={[1]={Transfixion='Transfixion'},[2]={Detonation='Detonation'}},level=1},
    Liquefaction = {elements='Fire',properties={[1]={Impaction='Fusion'},[2]={Scission='Scission'}},level=1},
    Induration = {elements='Ice',properties={[1]={Reverberation='Fragmentation'},[2]={Compression='Compression'},[3]={Impaction='Impaction'}},level=1},
    Reverberation = {elements='Water',properties={[1]={Induration='Induration'},[2]={Impaction='Impaction'}},level=1},
    Transfixion = {elements='Light',properties={[1]={Scission='Distortion'},[2]={Reverberation='Reverberation'},[3]={Compression='Compression'}},level=1},
    Scission = {elements='Earth',properties={[1]={Liquefaction='Liquefaction'},[2]={Reverberation='Reverberation'},[3]={Detonation='Detonation'}},level=1},
    Detonation = {elements='Wind',properties={[1]={['Compression']='Gravitation'},[2]={['Scission']='Compression'}},level=1},
    Impaction = {elements='Lightning',properties={[1]={Liquefaction='Liquefaction'},[2]={Detonation='Detonation'}},level=1},
    }
    
blood_pacts = L{
    [513] = {id=513,avatar='Carbuncle',en='Poison Nails',skillchain_a='Transfixion'},
    [521] = {id=521,avatar='Cait Sith',en='Regal Scratch',skillchain_a='Scission'},
    [528] = {id=528,avatar='Fenrir',en='Moonlit Charge',skillchain_a='Compression'},
    [529] = {id=529,avatar='Fenrir',en='Crescent Fang',skillchain_a='Transfixion'},
    [534] = {id=534,avatar='Fenrir',en='Eclipse Bite',skillchain_a='Gravitation'},
    [544] = {id=544,avatar='Ifrit',en='Punch',skillchain_a='Liquefaction'},
    [546] = {id=546,avatar='Ifrit',en='Burning Strike',skillchain_a='Impaction'},   
    [547] = {id=547,avatar='Ifrit',en='Double Punch',skillchain_a='Compression'},
    [550] = {id=550,avatar='Ifrit',en='Flaming Crush',skillchain_a='Fusion'},
    [560] = {id=560,avatar='Titan',en='Rock Throw',skillchain_a='Scission'},
    [562] = {id=562,avatar='Titan',en='Rock Buster',skillchain_a='Reverberation'},
    [563] = {id=563,avatar='Titan',en='Megalith Throw',skillchain_a='Induration'},
    [566] = {id=566,avatar='Titan',en='Mountain Buster',skillchain_a='Gravitation'},
    [576] = {id=576,avatar='Leviathan',en='Barracuda Dive',skillchain_a='Reverberation'},
    [578] = {id=578,avatar='Leviathan',en='Tail Whip',skillchain_a='Detonation'},
    [582] = {id=582,avatar='Leviathan',en='Spinning Dive',skillchain_a='Distortion'},
    [592] = {id=592,avatar='Garuda',en='Claw',skillchain_a='Detonation'},
    [598] = {id=598,avatar='Garuda',en='Predator Claws',skillchain_a='Fragmentation'},
    [608] = {id=608,avatar='Shiva',en='Axe Kick',skillchain_a='Induration'},
    [612] = {id=612,avatar='Shiva',en='Double Slap',skillchain_a='Scission'},
    [614] = {id=614,avatar='Shiva',en='Rush',skillchain_a='Distortion'},
    [624] = {id=624,avatar='Ramuh',en='Shock Strike',skillchain_a='Impaction'}, 
    [630] = {id=630,avatar='Ramuh',en='Chaotic Strike',skillchain_a='Fragmentation'},
    [656] = {id=656,avatar='Diabolos',en='Camisado',skillchain_a='Compression'},
    }
    
blue_mage = L{
    [519] = {id=519,en='Screwdriver',skillchain_a='Transfixion',skillchain_b='Scission'},
    [529] = {id=529,en='Bludgeon',skillchain_a='Liquefaction',skillchain_b=''},
    [527] = {id=527,en='Smite of Rage',skillchain_a='Detonation',skillchain_b=''},
    [539] = {id=539,en='Terror Touch',skillchain_a='Compression',skillchain_b='Reverberation'},
    [540] = {id=540,en='Spinal Cleave',skillchain_a='Scission',skillchain_b='Detonation'},
    [543] = {id=543,en='Mandibular Bite',skillchain_a='Induration',skillchain_b=''},
    [545] = {id=545,en='Sickle Slash',skillchain_a='Compression',skillchain_b=''},
    [551] = {id=551,en='Power Attack',skillchain_a='Reverberation',skillchain_b=''},
    [554] = {id=554,en='Death Scissors',skillchain_a='Compression',skillchain_b='Reverberation'},
    [560] = {id=560,en='Frenetic Rip',skillchain_a='Induration',skillchain_b=''},
    [564] = {id=564,en='Body Slam',skillchain_a='Impaction',skillchain_b=''},
    [567] = {id=567,en='Helldive',skillchain_a='Transfixion',skillchain_b=''},
    [569] = {id=569,en='Jet Stream',skillchain_a='Impaction',skillchain_b=''},
    [577] = {id=577,en='Foot Kick',skillchain_a='Detonation',skillchain_b=''},
    [585] = {id=585,en='Ram Charge',skillchain_a='Fragmentation',skillchain_b=''},
    [587] = {id=587,en='Claw Cyclone',skillchain_a='Scission',skillchain_b=''},
    [589] = {id=589,en='Dimensional Death',skillchain_a='Transfixion',skillchain_b='Impaction'},
    [594] = {id=594,en='Uppercut',skillchain_a='Liquefaction',skillchain_b='Impaction'},
    [596] = {id=596,en='Pinecone Bomb',skillchain_a='Liquefaction',skillchain_b=''},
    [597] = {id=597,en='Sprout Smack',skillchain_a='Reverberation',skillchain_b=''},
    [599] = {id=599,en='Queasyshroom',skillchain_a='Compression',skillchain_b=''},
    [603] = {id=603,en='Wild Oats',skillchain_a='Transfixion',skillchain_b=''},
    [611] = {id=611,en='Disseverment',skillchain_a='Distortion',skillchain_b=''},     
    [617] = {id=617,en='Vertical Cleave',skillchain_a='Gravitation',skillchain_b=''},
    [620] = {id=620,en='Battle Dance',skillchain_a='Impaction',skillchain_b=''},
    [622] = {id=622,en='Grand Slam',skillchain_a='Induration',skillchain_b=''},
    [623] = {id=623,en='Head Butt',skillchain_a='Impaction',skillchain_b=''},
    [628] = {id=628,en='Frypan',skillchain_a='Impaction',skillchain_b=''},
    [631] = {id=631,en='Hydro Shot',skillchain_a='Reverberation',skillchain_b=''},
    [638] = {id=638,en='Feather Storm',skillchain_a='Transfixion',skillchain_b=''},
    [640] = {id=640,en='Tail Slap',skillchain_a='Reverberation',skillchain_b=''},
    [641] = {id=641,en='Hysteric Barrage',skillchain_a='Detonation',skillchain_b=''},
    [643] = {id=643,en='Cannonball',skillchain_a='Fusion',skillchain_b=''},
    [650] = {id=650,en='Seedspray',skillchain_a='Induration',skillchain_b='Detonation'},
    [652] = {id=652,en='Spiral Spin',skillchain_a='Transfixion',skillchain_b=''},      
    [653] = {id=653,en='Asuran Claws',skillchain_a='Liquefaction',skillchain_b='Impaction'},
    [654] = {id=654,en='Sub\-zero Smash',skillchain_a='Fragmentation',skillchain_b=''},
    [665] = {id=665,en='Final Sting',skillchain_a='Fusion',skillchain_b=''},
    [666] = {id=666,en='Goblin Rush',skillchain_a='Fusion',skillchain_b=''},
    [667] = {id=667,en='Vanity Dive',skillchain_a='Transfixion',skillchain_b='Scission'},
    [669] = {id=669,en='Whirl of Rage',skillchain_a='Scission',skillchain_b='Detonation'},
    [670] = {id=670,en='Benthic Typhoon',skillchain_a='Gravitation',skillchain_b='Transfixion'},
    [673] = {id=673,en='Quad. Continuum',skillchain_a='Distortion',skillchain_b='Scission'},
    [677] = {id=677,en='Empty Thrash',skillchain_a='Compression',skillchain_b='Scission'},
    [682] = {id=682,en='Delta Thrust',skillchain_a='Liquefaction',skillchain_b='Detonation'},
    [688] = {id=688,en='Heavy Strike',skillchain_a='Fragmentation',skillchain_b=''},
    [692] = {id=692,en='Sudden Lunge',skillchain_a='Scission',skillchain_b=''},
    [693] = {id=693,en='Quadrastrike',skillchain_a='Liquefaction',skillchain_b='Scission'},
    [697] = {id=697,en='Amorphic Spikes',skillchain_a='Gravitation',skillchain_b=''},
    [699] = {id=699,en='Barbed Crescent',skillchain_a='Distortion',skillchain_b='Liquefaction'},
    [743] = {id=743,en='Bloodrake',skillchain_a='Darkness',skillchain_b='Gravitation'},
    } 

chain_ability = {}  
resonating = {}
azure_lore = {}

function apply_props(packet,ability)
    local mob_id = packet['Target 1 ID']
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob or not mob.is_npc or mob.hpp == 0 then return end
    local abil = res[ability][packet['Param']]
    if abil and ability == 'spells' then
        if abil.skill == 43 then
            abil = blue_mage[packet['Param']]
        elseif abil.skill == 36 then
            abil.skillchain_a = elements[abil.element].sc
        else
            return
        end
    elseif abil and ability == 'job_abilities' then
        abil = blood_pacts[packet['Param']]
    end
    if not abil then return end
    local skillchain = packet['Target 1 Action 1 Has Added Effect'] and skillchains[packet['Target 1 Action 1 Added Effect Message']]
    local now = os.clock()
    if skillchain then
        local reson = resonating[mob_id]
        local step = reson.step and reson.step + 1
        local closed
        if lvl3:contains(skillchain) and reson and not reson.closed and reson.active[1] == skillchain and
           (reson.chain or reson.ws.skillchain_a == ws.skillchain_a) then
            closed = true
        end
        resonating[mob_id] = {active={skillchain},timer=now,ws=abil,chain=true,closed=closed,step=step}
    elseif L{185,187}:contains(packet['Target 1 Action 1 Message']) then           
        resonating[mob_id] = {active={abil.skillchain_a,abil.skillchain_b,abil.skillchain_c},timer=now,ws=abil,chain=false,step=1}
    elseif L{317}:contains(packet['Target 1 Action 1 Message']) then
        resonating[mob_id] = {active={abil.skillchain_a},timer=now,ws=abil,chain=false,step=1}
    elseif ability == 'spells' and abil.skill == 36 and chain_ability[packet['Actor']] and now-chain_ability[packet['Actor']] <= 60 then
        resonating[mob_id] = {active={active},timer=now,ws=abil,chain=false,step=1}
    elseif ability == 'spells' and abil.skill == 43 and packet['Target 1 Action 1 Message'] == 2 and 
    (azure_lore[packet['Actor']] or chain_ability[packet['Actor']]) and 
    (now-azure_lore[packet['Actor']] <= 40 or now-chain_ability[packet['Actor']] <= 30) then
        resonating[mob_id] = {active={abil.skillchain_a,abil.skillchain_b},timer=now,ws=abil,chain=false,step=1}
    end
    if chain_ability[packet['Actor']] and abil.skill and (abil.skill == 43 or abil.skill == 36) then
        chain_ability[packet['Actor']] = nil
    end
    if not resonating[mob_id] then return end
    for k,element in ipairs(resonating[mob_id].active) do
        if element == '' then resonating[mob_id].active[k] = nil end
    end
end

function burst_results(reson)
    local stra,strb = '',''
    for k,element in pairs(reson.active) do
        stra = stra..' [%s]':format(element)
        if settings.ma and resonating.chain and not reson.mb_flag then
            strb = strb..'\n (Burst: %s)':format(prop_info[element].elements)
        end
    end
    return stra,strb
end

function chain_results(reson)
    local skills,spells = {},{}
    local m_job = windower.ffxi.get_player().main_job
    local abilities = windower.ffxi.get_abilities()
    local spell_table,sch
    if m_job == 'SMN' then
        spell_table = blood_pacts
    elseif m_job == 'BLU' then
        spell_table = blue_mage
    elseif m_job == 'SCH' and settings.ma then
        sch = true
    end
    for key,element in ipairs(reson.active) do
        local props = prop_info[element].properties
        for x=1,#props do
            for k,v in pairs(props[x]) do
                local lvl = prop_info[v].level
                if reson.chain and lvl3:contains(v) and lvl3:contains(element) then
                    lvl = 4
                end
                if sch then
                    for i=0,7 do
                        if elements[i].sc == v then
                            local term = elements[i].mb..' Magic'                        
                            if not spells[term] or spells[term].lvl < lvl then
                                spells[term] = {lvl=lvl,prop=v}
                            end
                        end
                    end
                elseif spell_table then
                    for i,t in ipairs(abilities.job_abilities) do
                        local spell = spell_table[t]
                        if spell and S{spell.skillchain_a,spell.skillchain_b}:contains(k) then
                            local term = spell.en
                            if spell.avatar then term = spell.avatar..': '..term end
                            if (not spells[term] or spells[term].lvl < lvl) then
                                spells[term]={lvl=lvl,prop=v}
                            end
                        end
                    end
                end
                if settings.ws then
                    for i,t in ipairs(abilities.weapon_skills) do
                        local ws = res.weapon_skills[t]
                        if ws and S{ws.skillchain_a,ws.skillchain_b,ws.skillchain_c}:contains(k) and
                        (not skills[ws.en] or skills[ws.en].lvl < lvl) then
                            skills[ws.en]={lvl=lvl,prop=v}
                        end
                    end
                end
            end
        end
    end
    return {[1]=skills,[2]=spells}
end

function display_results(targ,now)
    local str = ''
    local results = chain_results(resonating[targ])
    local chain,burst = burst_results(resonating[targ])
    for x = 1,4 do
        for i,t in ipairs(results) do
            for k,v in pairs(t) do
                if v and v.lvl == x then
                    str = '\n %s  >> Lv.%d %s ':format(k,v.lvl,v.prop)..str
                end
            end
        end
    end
    if str == '' and burst == '' then return '' end
    str = ' Step: %d >> [%s] >>':format(resonating[targ].step,resonating[targ].ws.en)..chain..burst..str
    if now-resonating[targ].timer < 3 then
        str = ' wait %s \n':format(math.abs(math.floor(now-resonating[targ].timer-3)))..str
    elseif now-resonating[targ].timer < 10 then
        str = ' GO! %s \n':format(math.abs(math.floor(now-resonating[targ].timer-10)))..str
    end
    return str
end

windower.register_event('prerender', function()
    local targ = windower.ffxi.get_mob_by_target('t')
    local now = os.clock()
    for k,v in pairs(resonating) do
        if now-v.timer > 10 then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] and not resonating[targ.id].closed then
        local disp_info = display_results(targ.id,now)
        skill_props:text(disp_info)
        skill_props:show()
    elseif not visible then
        skill_props:hide()        
    end
end)

windower.register_event('incoming chunk', function(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        -- Finish Using Weapon Skill
        if packet['Category'] == 3 then
            apply_props(packet,'weapon_skills')
        -- Finish Casting Magic
        elseif packet['Category'] == 4 then
            if packet['Target 1 Action 1 Message'] == 252 then
                resonating[packet['Target 1 ID']].mb_flag = true
            else
                apply_props(packet,'spells')
            end
        -- Finish Job Ability Usage   
        elseif packet['Category'] == 6 then
            if packet['Param'] == 94 or packet['Param'] == 317 then
                chain_ability[packet['Actor']] = os.clock()
            elseif packet['Param'] == 93 then
                azure_lore[packet['Actor']] = os.clock()
            end
        -- Finish Pet Move
        elseif packet['Category'] == 13 then
            apply_props(packet,'job_abilities')
        end
    end
end)

windower.register_event('addon command', function(...)
    local commands = {...}
    for x=1,#commands do commands[x] = commands[x]:lower() end
    if commands[1] == 'move' then
        visible = true
        if not skill_props:visible() then
            skill_props:text('\n    --- SkillChains ---\n\n  Click and drag to move display.  \n\n\t')
            skill_props:show()
            return
        end
        visible = false
    elseif default[commands[1]] then
        if not commands[2] then
            settings[commands[1]] = not settings[commands[1]]
        elseif commands[2] == 'off' then
            settings[commands[1]] = false
        elseif commands[2] == 'on' then
            settings[commands[1]] = true
        end
        windower.add_to_chat(207, '%s will %s be displayed.':format(commands[1] == 'ma' and 'Magic' or 'Weapon Skills',settings[commands[1]] and 'now' or 'NOT'))
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
end)
