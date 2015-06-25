local song_timers = {}

function song_timers.duration(name,buffs)
    local mult = 1
    if get.equip('range') == 'Daurdabla' then mult = mult + 0.3 end    -- 0.25 for 90, 0.3 for 99
    if get.equip('range') == 'Gjallarhorn' then mult = mult + 0.4 end  -- 0.3 for 95, 0.4 for 99
    if get.equip('main') == 'Carnwenhan' then mult = mult + 0.5 end    -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
    if get.equip('main') == 'Legato Dagger' then mult = mult + 0.05 end
    if get.equip('sub') == 'Legato Dagger' then mult = mult + 0.05 end
    if get.equip('neck') == 'Aoidos\' Matinee' then mult = mult + 0.1 end
    if get.equip('body') == 'Aoidos\' Hngrln. +2' then mult = mult + 0.1 end
    if get.equip('legs') == 'Mdk. Shalwar +1' then mult = mult + 0.1 end
    if get.equip('feet') == 'Brioso Slippers' then mult = mult + 0.1 end
    if get.equip('feet') == 'Brioso Slippers +1' then mult = mult + 0.11 end
    if get.equip('body') == 'Fili Hongreline' then mult = mult + 0.11 end
    if get.equip('body') == 'Fili Hongreline +1' then mult = mult + 0.12 end
    if string.find(name,'March') and (get.equip('hands') == 'Ad. Mnchtte. +2' or string.find(get.equip('hands'),'Fili Manchettes')) then mult = mult + 0.1 end
    if string.find(name,'Minuet') and (get.equip('body') == 'Aoidos\' Hngrln. +2' or string.find(get.equip('body'),'Fili Hongreline')) then mult = mult + 0.1 end
    if string.find(name,'Madrigal') and (get.equip('head') == 'Aoidos\' Calot +2' or string.find(get.equip('head'),'Fili Calot')) then mult = mult + 0.1 end
    if string.find(name,'Ballad') and (get.equip('legs') == 'Aoidos\' Rhing. +2' or string.find(get.equip('legs'),'Fili Rhingrave')) then mult = mult + 0.1 end
    if string.find(name,'Scherzo') and (get.equip('feet') == 'Aoidos\' Cothrn. +2' or string.find(get.equip('feet'),'Fili Cothurnes')) then mult = mult + 0.1 end
    if string.find(name,'Paeon') and string.find(get.equip('head'),'Brioso Roundlet') then mult = mult + 0.1 end
    if buffs.troubadour then
        mult = mult*2
    end
    if string.find(name,'Scherzo') and buffs['soul voice'] then
        mult = mult*2
    elseif string.find(name,'Scherzo') and buffs.marcato then
        mult = mult*1.5
    end
    return math.floor(mult*120)
end

function song_timers.buff_lost(targ,buff)
    local buff = get.songs[buff:lower()]
    if not buff or not timers[targ] then return end
    local minimum,song
    for k,song_name in pairs(buff) do
        local song_timer = timers[targ][song_name]
        if song_timer and (not minimum or song_timer.ts < minimum) then
            minimum = song_timer.ts
            song = song_name
        end
    end
    if not song then return end
    if not settings.song[targ] then song_timers.delete(song,'AoE') end
    song_timers.delete(song,targ)
end

function song_timers.update(targ)
    if targ == 'buffs' then return end
    if not timers[targ] then timers[targ] = {} end
    local current_time = os.time()
    local temp_timer_list = {}
    for song_name,expires in pairs(timers[targ]) do
        if expires.ts < current_time then
            temp_timer_list[song_name] = true
        end
    end
    for song_name,expires in pairs(temp_timer_list) do
        timers[targ][song_name] = nil
    end
end

function song_timers.delete(song,targ)
    timers[targ][song] = nil
    windower.send_command('timers delete "%s [%s]"':format(song,targ))
end

function song_timers.create(song,targ,dur,current_time,buffs)
    timers[targ][song] = {ts=current_time+dur,nt=buffs.troubadour,sv=buffs['soul voice']}
    if timers.AoE[song] and targ ~= 'AoE' or not settings.timers then return end
    windower.send_command('timers create "%s [%s]" %s down':format(song,targ,dur))
end
              
function song_timers.adjust(spell_name,targ,buffs)
    local current_time = os.time()
    local dur = song_timers.duration(spell_name,buffs)
    song_timers.update(targ)
    if timers[targ][spell_name] then
        if timers[targ][spell_name].ts < (current_time + dur) then
            song_timers.create(spell_name,targ,dur,current_time,buffs)
        end
    else
        if table.length(timers[targ]) < get.maxsongs(targ,buffs) then
            song_timers.create(spell_name,targ,dur,current_time,buffs)
        else
            local rep,repsong
            for song_name,expires in pairs(timers[targ]) do
                if current_time + dur > expires.ts then
                    if not rep or rep > expires.ts then
                        rep = expires.ts
                        repsong = song_name
                    end
                end
            end
            if repsong then
                song_timers.delete(repsong,targ)
                song_timers.create(spell_name,targ,dur,current_time,buffs)
            end
        end
    end
end

function song_timers.reset(bool)
    for k,targ in pairs(timers) do
        for i,v in pairs(targ) do
            windower.send_command('timers delete "%s [%s]"':format(i,k))
        end
    end
    if bool then return end
    timers = {AoE={},buffs={Haste={},Refresh={}}}
    casting = false
end

return song_timers
