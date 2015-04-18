# Sing
### Bard Lua Bot for Windower

Configure songs with commands, calculates song duration based on active job abilities and gear equipped 
at the endcast, checks active song buffs casted by player (as recorded by the addon) and detects song+ 
instruments, (if found in inventory/wardrobe.) and applies it to your song limit.

##### Commands:

//sing on
//sing off
//sing save -- to save your settings on a per character basis.

//sing clarion [Name of extra song to maintain.]
//sing marcato [Name of song to use with marcato]

Songs Types Currently supported:
  March x2
  Minuet x4 (minuets 2-5)
  Madrigal x2
  Scherzo x1
  Prelude x1
  Ballad x3 -- ballads are NOT implemented as of this writing.

To configure songs use //song [song type] [number] 
e.g. //song march 2 - sets number of marches to 2 (max values for each song type can be found above.)

To turn a song off use //song [song type] 0
e.g. //song madrigal 0 - sets number of madrigals to 0 madrigals will not be used.

It will use Warding Round and Herb Pastoral as 3rd and 4th dummy songs respectively,
a toggle for user defined dummy songs may be added at some point 
(possibly with the lauch of windower 5, as the resources access will simplify my vison going further).

Timers are for debugging purposes, will remove eventually or keep as a toggle if people prefer.

Future adjustments include adjustable song refesh delay, JA usage including pianissimo songs.
Along with movement to players before casting, with a safe spot to idle.

Full disclosure:
 The original concept was posted by a guest on pastebin, however many adjustments have been made and is 
 expected to further deviate beyond recognition, due to planned additions and optimizations.
 The original code for calculating and displaying song timers was pulled from a gearswap user file.
