AuctionHelper
=============
Auction house bidding tool - addon for Windower
-----------------------------------------------
Allows you to perform auction house actions with commands, much like bidder with additional functionality.
Displays a text object with sales information when opening ah menu (if text object is set to show).

buy [item name] [stack] [price] -- buy an item on auction house

sell [item name] [ stack] [price] -- sell an item, must open ah once after addon has loaded/players logged in.

[item name] - Accepts auto-translate, short or full item name, no quotes needed.

[Stack] - "stack" or "1" or "single" or "0"

[price] - CSV and EU decimal mark are optional. e.g. 100000 or 100,000 or 100.000

inbox / ibox	-- open delivery inbox

outbox / obox	-- open delivery outbox

bazaar [item_name] [price]-- sets bazaar prices for all instances of [item_name]. Note: bazaar window must be open.

ah		-- open AH menu

ah clear 	-- clear sold/unsold status

ah show/hide -- show or hide text object, click/drag window to move, accepts following arguments to customize displayed information, show as little or as much as you like.

	timer	-- show timer counting down/up to/from end of auction/time of sale.
	date	-- date and time the item auction ends/returned/was sold
	price	-- display your asking price
	empty	-- show/hide empty slots
	slot	-- show slot number next to item entry

ah save -- save settings related to text object


check settings file for more customization options.

##### If there has been a mainenance or update to the game make sure windowers resource files have been updated to reflect new items added.

TODO:	Expand delivery boxes beyond auction house zones (list mog house zones, other delivery areas),
	Block sell confirm window when injecting sell packet (only occurs when selling inside sell menu),
	Adjust delays.
