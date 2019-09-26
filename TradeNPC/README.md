# TradeNPC

Trade an npc up to 8 stacks of items and gil with a single command.

### Command Usage:
```
tradenpc <quantity> <item name> [npc name]
```

Quantities greater than an items stack size are accepted, if you specify too many items the trade will not occur.

For gil CSV and EU decimal mark are optional. e.g. 100000 or 100,000 or 100.000

Accepts auto-translate, short or full item name.

If the item name is more than one word you must use quotes or auto-translate.

Multiple items can be traded in one command.

If trading gil it must be the first set of arguments or the trade will not occur.

If you need to exceed the chatlog character limit, you can type the command from console or execute via a txt script.

### Examples

```
//tradenpc 100 "1 byne bill"

//tradenpc 792 alexandrite

//tradenpc 10,000 gil 24 "fire crystal" 12 "earth crystal" 18 "water crystal" 6 "dark crystal" "Ephemeral Moogle"
```
