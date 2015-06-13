# Sing
### Automates casting of bard buff songs.

Configure songs with commands, calculates song duration based on active job abilities and gear equipped 
at the endcast, supports two dummy songs, checks active song buffs casted by player (as recorded by the addon) and detects song+ 
instruments, (if found in inventory/wardrobe.) and applies it to your song limit.

##### Commands: 
when typing commands don't use "" [] |

	"//sing on"			-- Turn actions off
	"//sing off"			-- Turn actions on
	"//sing actions [on/off]"	-- toggles actions if [on/off] not provided.
	"//sing save"			-- to save your settings on a per character basis.
	"//sing delay [n]"		-- [n] delay between song casting
	"//sing precast [n]"		-- recast songs [n] seconds before songs wears
	"//sing display [on/off]"	-- Dislay custom song timers
	"//sing clarion [buff_name]" 	-- set extra clarion song here*
	"//sing marcato [song name]"	 -- set song to use following marcato**
	"//sing pianissimo [on/off]"	-- toggles pianissimo songs.
	"//sing dummy1 [song name]"	-- set dummy song**
	"//sing dummy2 [song name]"	-- second dummy song, ignored if you do not own the proper equipment.
	"//sing song [player_name] [song name] [+|-]"	-- Add or remove pianissimo songs**
	"//sing aoe [player_name] [+|-]"	-- Add players to aoe watch list(will not sing AoE songs if 
	specified players are not in range, optional.)
 
To configure songs use:
	
	"//sing [buff_name] [number]" 
	e.g. //sing march 2 - sets number of marches to 2.*

To turn a song off use :
	
	"//sing [buff_name] 0" or "//sing [buff_name] off"
	e.g. //sing madrigal 0 - sets number of madrigals to 0 madrigals will not be used.*
	
	
*[buff_name] name of buff, currently supports all bard buffs excluding etudes and carols
e.g march, minuet, madrigal, scherzo, prelude, ballad, mazurka are all valid buff names
	
**[song name] name of song as it appears in game, not case sensitive.
