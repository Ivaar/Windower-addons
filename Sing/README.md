# Sing
### Automates casting of bard buff songs.

Configure songs with commands, calculates song duration based on active job abilities and gear equipped 
at the endcast, checks active song buffs casted by player (as recorded by the addon) and detects song+ 
instruments, (if found in inventory/wardrobe.) and applies it to your song limit.

##### Commands:

//sing on

//sing off

//sing actions [on/off]	-- toggles actions if [on/off] not provided.

//sing save -- to save your settings on a per character basis.

//sing delay [n]	-- [n] delay between song casting

//sing precast [n] 	-- recast songs [n] seconds before songs wears

//sing display [on/off]		-- Dislay custom song timers

//sing clarion [song_type.] -- set extra clarion song here*

//sing marcato [song name]  -- set song to use following marcato**

//sing pianissimo [on/off]	-- toggles pianissimo songs.

//sing song [player_name] [song name] [+/-]	-- Add or remove pianissimo songs**

//sing aoe [player_name] [+/-]	-- Add players to aoe watch list(will not sing aoe songs if specified players are not in range, optional.)

Songs Types Currently supported and thier maximum values:
  March x2
  Minuet x4 (minuets 2-5)
  Madrigal x2
  Scherzo x1
  Prelude x1
  Ballad x3

To configure songs use //sing [song type] [number] 
e.g. //sing march 2 - sets number of marches to 2.*

To turn a song off use //sing [song type] 0
e.g. //sing madrigal 0 - sets number of madrigals to 0 madrigals will not be used.*

It will use Warding Round and Herb Pastoral as 3rd and 4th dummy songs respectively,
a toggle for user defined dummy songs will be added at some point 
(possibly with the lauch of windower 5, as the resources access will simplify my vison going further).

*[song_type] march, minuet, madrigal, scherzo, prelude, ballad, mazurka

**[song name] name of song as it appears in game, not case sensitive.

