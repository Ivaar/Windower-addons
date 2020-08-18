# Sing
### Automates casting of bard buff songs.
#### If you are updating from a version prior to 1.20.05.09 make sure you delete your existing settings.xml file located within the addons data folder.
Configure songs with commands, calculates song duration based on active job abilities and gear equipped 
at the endcast, supports two dummy songs, checks active song buffs casted by player (as recorded by the addon) and detects song+ 
instruments, (if found in inventory/wardrobe.) and applies it to your song limit.

##### Commands: 
when typing commands don't use "[ ]"  "< >" or "|". 

[on|off] is optional and when not provided will toggle states.

Accepts auto-translated terms.

	//sing [on|off]                     -  Turn actions on/off.
	//sing actions [on|off]             -  Same as above.
	//sing active [on|off]              -  Display active settings in text box
	//sing timers [on|off]              -  Dislay custom song timers.
	//sing haste <name> [on|off]        -  Add or remove names of players for Haste cycle.
	//sing refresh <name> [on|off]      -  Add or remove names of players for Refresh cycle.
	//sing pianissimo [on|off]          -  Toggle pianissimo usage, can be shortened to p.
	//sing nightingale [on|off]         -  Toggle nightingale usage, can be shortened to n.
	//sing troubadour [on|off]          -  Toggle troubadour usage, can be shortened to t.
	//sing delay <n>                    -  [n] second delay between song casting.
	//sing recast song <min> <max>      -  Begin recasting songs between <min> and <max> seconds before they wear.
	//sing recast buff <min> <max>      -  Same as the above for haste and refresh.
    //sing <buff> [n]                   -  Set aoe buff song to x[n] or off.*
	//sing <buff> [n] [name]            -  Set pianissimo song type to x[n] or off for [name].*
	//sing marcato <song>               -  Set song to use following marcato.**
	//sing dummy [n] <song>             -  Set dummy songs, ignored if you do not own the proper equipment.**
	//sing aoe [slot|name] [on|off]     -  Set party slots to monitor for aoe range.
	//sing save [list] [name]           -  Save settings, if <list> is provided will save current songs to playlist.
	//sing reset                        -  Reset song timers.
	//sing <order> <song> [name]        -  Set songs to be used in specified order.**
	//sing <order> <clear> [name]       -  Remove song from specified slot.
	//sing playlist save <list> [name]  -  Saves current songs to playlist.
	//sing playlist <list|clear> [name] -  Loads songs from a previously set playlist. (clear is an empty playlist to remove all songs)
	//sing clear <name|aoe>				-  Clear song list for name

To configure songs use:
	
	"//sing <buff> <n|off>" 
	e.g. //sing march 2 - sets number of marches to 2.*

To turn a song off:
	
	"//sing <buff> 0" or "//sing <buff> off"
	e.g. //sing madrigal 0 - sets number of madrigals to 0 madrigals will not be used.*
	
	
*[buff] name of buff, currently supports all bard buffs 
    e.g march, minuet, madrigal, scherzo, prelude, ballad, mazurka are all valid buff names
    Note: Etudes and Carols are a bit different. If you want STR Etude you would do setude, DEX deteude, VIT vetude, etc etc
          For Carols if you wanted Fire Carol you would do fcarol, Ice icarol, etc etc. With two exceptions Lightning Carol is tcarol as in Thunder Resistance because there is also Light Carol which is lcarol and Water Carol is acarol as in Aqua because of Wind Carol being wcarol.
	
**[song] name of song as it appears in game, not case sensitive.
