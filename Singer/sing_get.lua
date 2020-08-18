local get = {}

get.songs = {
    paeon = {'Army\'s Paeon VI','Army\'s Paeon V','Army\'s Paeon IV','Army\'s Paeon III','Army\'s Paeon II','Army\'s Paeon'},
    ballad = {'Mage\'s Ballad III','Mage\'s Ballad II','Mage\'s Ballad'},
    minne = {'Knight\'s Minne V','Knight\'s Minne IV','Knight\'s Minne III','Knight\'s Minne II','Knight\'s Minne'},
    march = {'Victory March','Advancing March'},
    minuet = {'Valor Minuet V','Valor Minuet IV','Valor Minuet III','Valor Minuet II','Valor Minuet'}, 
    madrigal = {'Blade Madrigal','Sword Madrigal'},
    prelude = {'Archer\'s Prelude','Hunter\'s Prelude'},
    mambo = {'Dragonfoe Mambo','Sheepfoe Mambo'},
    aubade = {'Fowl Aubade'},
    pastoral = {'Herb Pastoral'},
    fantasia = {'Shining Fantasia'},
    operetta = {'Puppet\'s Operetta','Scop\'s Operetta'},
    capriccio = {'Gold Capriccio'},
    round = {'Warding Round'},
    gavotte = {'Shining Fantasia'},
    hymnus = {'Goddess\'s Hymnus'},
    mazurka = {'Chocobo Mazurka'},
    sirvente = {'Foe Sirvente'},
    dirge = {'Adventurer\'s Dirge'},
    scherzo = {'Sentinel\'s Scherzo'},
    carol = {},
    etude = {},
    setude = {'Herculean Etude','Sinewy Etude'},
    detude = {'Uncanny Etude','Dextrous Etude'},
    vetude = {'Vital Etude','Vivacious Etude'},
    aetude = {'Swift Etude','Quick Etude'},
    ietude = {'Sage Etude','Learned Etude'},
    metude = {'Logical Etude','Spirited Etude'},
    cetude = {'Bewitching Etude','Enchanting Etude'},
    fcarol = {'Fire Carol','Fire Carol II'},
    icarol = {'Ice Carol','Ice Carol II'},
    wcarol = {'Wind Carol','Wind Carol II'},
    ecarol = {'Earth Carol','Earth Carol II'},
    tcarol = {'Lightning Carol','Lightning Carol II'},
    acarol = {'Water Carol','Water Carol II'},
    lcarol = {'Light Carol','Light Carol II'},
    dcarol = {'Dark Carol','Dark Carol II'},
}

get.debuffs = {
    lullaby = {'Horde Lullaby II','Horde Lullaby','Foe Lullaby II','Foe Lullaby'},
    elegy = {'Carnage Elegy'},
    nocturne = {'Pining Nocturne'},
    threnody = {
         fire = 'Fire Threnody', fire2 = 'Fire Threnody II',
         ice = 'Ice Threnody', ice2 = 'Ice Threnody II',
         wind = 'Wind Threnody', wind2 = 'Wind Threnody II',
         earth = 'Earth Threnody', earth2 = 'Earth Threnody II',
         lightning = 'Ltng. Threnody', lightning2 = 'Ltng. Threnody II',
         water = 'Water Threnody', water2 = 'Water Threnody II',
         light = 'Light Threnody', light2 = 'Light Threnody II',
         dark = 'Dark Threnody', dark2 = 'Dark Threnody II',
    }
}

local ext_songs = {
    etude = {
        str = {'Herculean Etude','Sinewy Etude'},
        dex = {'Uncanny Etude','Dextrous Etude'},
        vit = {'Vital Etude','Vivacious Etude'},
        agi = {'Swift Etude','Quick Etude'},
        int = {'Sage Etude','Learned Etude'},
        mnd = {'Logical Etude','Spirited Etude'},
        chr = {'Bewitching Etude','Enchanting Etude'},
    },
    carol = {
        fire = {'Fire Carol','Fire Carol II'},
        ice = {'Ice Carol','Ice Carol II'},
        wind = {'Wind Carol','Wind Carol II'},
        earth = {'Earth Carol','Earth Carol II'},
        lightning = {'Lightning Carol','Lightning Carol II'},
        water = {'Water Carol','Water Carol II'},
        light = {'Light Carol','Light Carol II'},
        dark = {'Dark Carol','Dark Carol II'},
    },
}

for buff, tab in pairs(ext_songs) do
    for _, songs in pairs(tab) do
        get.songs[buff][#get.songs[buff]+1] = songs[1]
        get.songs[buff][#get.songs[buff]+1] = songs[2]
    end
end

function get.ext_songs(type, atr)
    if ext_songs[type] then
        return ext_songs[type][atr]
    end
end

local song = {
    [368] = 'Foe Requiem',
    [369] = 'Foe Requiem II',
    [370] = 'Foe Requiem III',
    [371] = 'Foe Requiem IV',
    [372] = 'Foe Requiem V',
    [373] = 'Foe Requiem VI',
    [374] = 'Foe Requiem VII',
    [375] = 'Foe Requiem VIII',
    [376] = 'Horde Lullaby',
    [377] = 'Horde Lullaby II',
    [378] = 'Army\'s Paeon',
    [379] = 'Army\'s Paeon II',
    [380] = 'Army\'s Paeon III',
    [381] = 'Army\'s Paeon IV',
    [382] = 'Army\'s Paeon V',
    [383] = 'Army\'s Paeon VI',
    [384] = 'Army\'s Paeon VII',
    [385] = 'Army\'s Paeon VIII',
    [386] = 'Mage\'s Ballad',
    [387] = 'Mage\'s Ballad II',
    [388] = 'Mage\'s Ballad III',
    [389] = 'Knight\'s Minne',
    [390] = 'Knight\'s Minne II',
    [391] = 'Knight\'s Minne III',
    [392] = 'Knight\'s Minne IV',
    [393] = 'Knight\'s Minne V',
    [394] = 'Valor Minuet',
    [395] = 'Valor Minuet II',
    [396] = 'Valor Minuet III',
    [397] = 'Valor Minuet IV',
    [398] = 'Valor Minuet V',
    [399] = 'Sword Madrigal',
    [400] = 'Blade Madrigal',
    [401] = 'Hunter\'s Prelude',
    [402] = 'Archer\'s Prelude',
    [403] = 'Sheepfoe Mambo',
    [404] = 'Dragonfoe Mambo',
    [405] = 'Fowl Aubade',
    [406] = 'Herb Pastoral',
    [407] = 'Chocobo Hum',
    [408] = 'Shining Fantasia',
    [409] = 'Scop\'s Operetta',
    [410] = 'Puppet\'s Operetta',
    [411] = 'Jester\'s Operetta',
    [412] = 'Gold Capriccio',
    [413] = 'Devotee Serenade',
    [414] = 'Warding Round',
    [415] = 'Goblin Gavotte',
    [416] = 'Cactuar Fugue',
    [417] = 'Honor March',
    [418] = 'Protected Aria',
    [419] = 'Advancing March',
    [420] = 'Victory March',
    [421] = 'Battlefield Elegy',
    [422] = 'Carnage Elegy',
    [423] = 'Massacre Elegy',
    [424] = 'Sinewy Etude',
    [425] = 'Dextrous Etude',
    [426] = 'Vivacious Etude',
    [427] = 'Quick Etude',
    [428] = 'Learned Etude',
    [429] = 'Spirited Etude',
    [430] = 'Enchanting Etude',
    [431] = 'Herculean Etude',
    [432] = 'Uncanny Etude',
    [433] = 'Vital Etude',
    [434] = 'Swift Etude',
    [435] = 'Sage Etude',
    [436] = 'Logical Etude',
    [437] = 'Bewitching Etude',
    [438] = 'Fire Carol',
    [439] = 'Ice Carol',
    [440] = 'Wind Carol',
    [441] = 'Earth Carol',
    [442] = 'Lightning Carol',
    [443] = 'Water Carol',
    [444] = 'Light Carol',
    [445] = 'Dark Carol',
    [446] = 'Fire Carol II',
    [447] = 'Ice Carol II',
    [448] = 'Wind Carol II',
    [449] = 'Earth Carol II',
    [450] = 'Lightning Carol II',
    [451] = 'Water Carol II',
    [452] = 'Light Carol II',
    [453] = 'Dark Carol II',
    [454] = 'Fire Threnody',
    [455] = 'Ice Threnody',
    [456] = 'Wind Threnody',
    [457] = 'Earth Threnody',
    [458] = 'Ltng. Threnody',
    [459] = 'Water Threnody',
    [460] = 'Light Threnody',
    [461] = 'Dark Threnody',
    [462] = 'Magic Finale',
    [463] = 'Foe Lullaby',
    [464] = 'Goddess\'s Hymnus',
    [465] = 'Chocobo Mazurka',
    [466] = 'Maiden\'s Virelai',
    [467] = 'Raptor Mazurka',
    [468] = 'Foe Sirvente',
    [469] = 'Adventurer\'s Dirge',
    [470] = 'Sentinel\'s Scherzo',
    [471] = 'Foe Lullaby II',
    [472] = 'Pining Nocturne',
    [871] = 'Fire Threnody II',
    [872] = 'Ice Threnody II',
    [873] = 'Wind Threnody II',
    [874] = 'Earth Threnody II',
    [875] = 'Ltng. Threnody II',
    [876] = 'Water Threnody II',
    [877] = 'Light Threnody II',
    [878] = 'Dark Threnody II',
    }

local spell = {
    [57] = {id=57,enl='Haste',dur=180},
    [109] = {id=109,enl='Refresh',dur=150},
    [119] = {id=119,enl='Aurorastorm',dur=180},
    [115] = {id=115,enl='Firestorm',dur=300},
    }

--[[
song = {}
for k,v in ipairs(res.spells) do
    if v.type == 'BardSong' then
        song[k] = v.en
    end
end
]]

do
    local info = windower.ffxi.get_info()

    if info.logged_in then
        local player = windower.ffxi.get_mob_by_target('me') or {}
        get.player_id = player.id
        get.player_name = player.name
        get.zone_id = info.zone
    end
end

local equippable_bags = {
    'Inventory',
    'Wardrobe',
    'Wardrobe2',
    'Wardrobe3',
    'Wardrobe4'
    }

local extra_song_harp = {
    [18571] = 4, -- Daurdabla 99
    [18575] = 3, -- Daurdabla 90
    [18576] = 3, -- Daurdabla 95
    [18839] = 4, -- Daurdabla 99-2
    [21400] = 3, -- Blurred Harp
    [21401] = 3, -- Blurred Harp +1
    [21407] = 3, -- Terpander
    }

local honor_march_horn = {
    [21398] = true -- Marsyas
    }

local function find_equippable_item(item_ids)
    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if item_ids[v.id] then
                    return item_ids[v.id]
                end
            end
        end
    end
end

get.jp_mods = {}

function initialize()
    local jp = windower.ffxi.get_player().job_points.brd
    get.jp_mods.clarion = jp.clarion_call_effect *2
    get.jp_mods.tenuto = jp.tenuto_effect *2
    get.jp_mods.marcato = jp.marcato_effect
    get.jp_mods.mult = jp.jp_spent >= 1200
    get.base_songs = 2
    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if extra_song_harp[v.id] and get.base_songs < extra_song_harp[v.id] then
                    get.base_songs = extra_song_harp[v.id]
                elseif honor_march_horn[v.id] and #get.songs.march == 2 then
                    table.insert(get.songs.march, 1, 'Honor March')
                end
            end
        end
    end
end
initialize()

function get.buffs()
    local set_buff = {}
    for _, buff_id in ipairs(windower.ffxi.get_player().buffs) do
        local buff_en = res.buffs[buff_id].en:lower()
        if buff_id == 272 then
            set_buff[buff_en] = 1
            times[buff_en] = 10
        else
            set_buff[buff_en] = (set_buff[buff_en] or 0) + 1
        end
    end
    return set_buff
end

function get.spell_by_id(id)
    return spell[id]
end

function get.song_name(id)
    return song[id]
end

function get.spell(name)
    name = string.lower(name)
    for k,v in pairs(spell) do
        if v and v.enl and string.lower(v.enl) == name then
            return v
        end
    end
    return nil
end

function get.song_by_name(name)
    if not name then return end
    name = string.lower(name)
    for k,v in pairs(song) do
        if k ~= 'n' and string.lower(v) == name then
            return {id=k,enl=v}
        end
    end
    return nil
end

function get.song_from_command(str)
    for k, name in pairs(song) do
        if name:gsub('[%s%p]', ''):lower() == str:gsub('[%s%p]', '') then
            return name
        end
    end
end

function get.maxsongs(targ,buffs)
    local maxsongs = get.base_songs
    if buffs['clarion call'] then
        maxsongs = maxsongs + 1 
    elseif timers[targ] and maxsongs < table.length(timers[targ]) then
        maxsongs = table.length(timers[targ])
    end
    return maxsongs
end

function get.song_list(songs,targ,maxsongs)
    local list = {}
    local clarion = settings.clarion[targ:lower()]
    for k,v in pairs(songs) do
        list[k] = v
    end
    if clarion and maxsongs > get.base_songs then
        list[clarion] = (list[clarion] or 0) + 1 
    end
    return list
end

function get.eye_sight(play,targ)
    if not targ then return false end
    return math.abs(-math.atan2(targ.y - play.y, targ.x - play.x) - play.facing) < 0.76
end

get.party_slots = L{'p1','p2','p3','p4','p5'}

function get.is_valid_target(target, distance)
    return target.hpp > 0 and target.distance:sqrt() < distance and (target.is_npc or not target.charmed)
end

function get.valid_ally(name, distance)
    for ind, member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.name:lower() == name then
            return get.is_valid_target(member.mob, distance)
        end
    end
    return false
end

function get.aoe_range(name)
    local party = windower.ffxi.get_party()

    for slot in get.party_slots:it() do
        local member = party[slot]

        if member and member.zone == get.zone_id and settings.aoe[slot] and (not member.mob or not get.is_valid_target(member.mob, 10)) then
            return false
        end
    end
    return true
end

function get.party()
    return T(windower.ffxi.get_party()):key_filter(table.contains+{get.party_slots:append('p0')})
end

function get.party_member(name)
    return name and party:with('name', string.ieq+{name})
end

return get
