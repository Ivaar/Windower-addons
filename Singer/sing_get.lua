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
    }

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

local function get_song_count()
    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if extra_song_harp[v.id] then
                    return extra_song_harp[v.id]
                end
            end
        end
    end
    return 2
end

base_songs = get_song_count()

function get.buffs(curbuffs)
    local buffs = {}
    for i,v in pairs(curbuffs) do
        if res.buffs[v] and res.buffs[v].english then
            buffs[res.buffs[v].english:lower()] = (buffs[res.buffs[v].english:lower()] or 0) + 1
        end
    end
    return buffs
end

function get.spell(name)
    name = string.lower(name)
    for k,v in pairs(ids.spells) do
        if v and v.enl and string.lower(v.enl) == name then
            return v
        end
    end
    return nil
end

function get.song(name)
    name = string.lower(name)
    for k,v in pairs(ids.songs) do
        if k ~= 'n' and string.lower(v) == name then
            return {id=k,enl=v}
        end
    end
    return nil
end

function get.maxsongs(targ,buffs)
    local maxsongs = get_song_count()
    if buffs['clarion call'] then
        maxsongs = maxsongs + 1 
    end
    if timers[targ] and maxsongs < table.length(timers[targ]) then
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
    if clarion and maxsongs > base_songs then
        list[clarion] = (list[clarion] or 0) + 1 
    end
    return list
end

function get.eye_sight(player,target)
    if not target then return false end
    local xdif = target.x - player.x -- Negative if target is west
    local ydif = target.y - player.y -- Negative if target is south
    if math.abs(-math.atan2(ydif,xdif)-player.facing) < 0.76 then
        return true
    else
        return false
    end
end

function get.valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.in_party and member.mob.hpp > 0 and 
            member.mob.name:lower() == targ:lower() and math.sqrt(member.mob.distance) < dst and not member.mob.charmed then
            return true
        end
    end
    return false
end

function get.aoe_range()
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.in_party and member.mob.hpp > 0 and
            not settings.song[member.mob.name:lower()] and not settings.ignore:find(member.mob.name:lower()) and
            math.sqrt(member.mob.distance) >= 10 and not member.mob.charmed then
            return false
        end
    end
    return true
end

return get
