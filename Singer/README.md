# Sing
### Automates casting of bard buff songs.
Configure songs with commands, calculates song duration based on active job abilities and gear equipped 
at the endcast, supports two dummy songs, checks active song buffs casted by player (as recorded by the addon) and detects song+ 
instruments, (if found in inventory/wardrobe.) and applies it to your song limit.

##### Commands: 
when typing commands don't use "[ ]" or "|". 

[on|off] is optional and when not provided will toggle states.

Accepts auto-translated terms.

	//sing [on|off]                 -  Turn actions on/off.
	//sing actions [on|off]         -  Same as above.
	//sing active [on|off]          -  Display active settings in text box
	//sing timers [on|off]          -  Dislay custom song timers.
	//sing haste [name] [on|off]    -  Add or remove names of players for Haste cycle.
	//sing refresh [name] [on|off]  -  Add or remove names of players for Refresh cycle.
	//sing pianissimo [on|off]      -  Toggles pianissimo songs.
	//sing delay [n]                -  [n] second delay between song casting.
	//sing recast song [min] [max]  -  Begin recasting songs between [min] and [max] seconds before they wear.
	//sing recast buff [min] [max]  -  Same as the above for haste and refresh.
    //sing [buff] [n]               -  Set aoe buff song to x[n] or off.*
	//sing [buff] [n] [name]        -  Set pianissimo song type to x[n] or off for [name].*
	//sing clarion [buff]           -  Set extra clarion song.*
	//sing clarion [buff] [name]    -  Set pianissimo clarion song for [name].*
	//sing marcato [song]           -  Set song to use following marcato.**
	//sing dummy [song]             -  Set dummy song.**
	//sing dummy2 [song]            -  Second dummy song, both are ignored if you do not own the proper equipment.**
	//sing ignore [name] [+|-]      -  Adding party members will ignore thier distance check when casting songs.
	//sing save                     -  Saves settings on a per character basis.

To configure songs use:
	
	"//sing [buff] [n|off]" 
	e.g. //sing march 2 - sets number of marches to 2.*

To turn a song off:
	
	"//sing [buff] 0" or "//sing [buff] off"
	e.g. //sing madrigal 0 - sets number of madrigals to 0 madrigals will not be used.*
	
	
*[buff] name of buff, currently supports all bard buffs excluding etudes and carols
    e.g march, minuet, madrigal, scherzo, prelude, ballad, mazurka are all valid buff names
	
**[song] name of song as it appears in game, not case sensitive.
