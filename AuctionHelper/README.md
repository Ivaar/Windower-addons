AuctionHelper
=============
Auction house bidding tool - addon for Windower
-----------------------------------------------
Allows you to perform auction house actions with commands, much like bidder with additional functionality.
Displays a text object with sales information when opening ah menu (if text object is set to show).

buy [item name] [single OR 0 and stack OR 1] [price] -- buy an item on auction house

sell [item name] [single OR 0 and stack OR 1] [price] -- sell an item, must open ah once after addon has loaded

[item name] -- Accepts auto-translate, short or full item name. 
[price] -- CSV and EU decimal mark are optional. e.g. 100000 or 100,000 or 100.000

inbox / ibox	-- open delivery inbox

outbox / obox	-- open delivery outbox

ah		-- open AH menu

ah clear 	-- clear sold/unsold status

ah show/ah hide -- show or hide text object, click/drag window to move, accepts following arguments to customize displayed information, show as little or as much as you like.

	timer	-- show timer counting down/up to/from end of auction/time of sale.
	date	-- date and time the item auction ends/returned/was sold
	price	-- display your asking price
	empty	-- show/hide empty slots
	slot	-- show slot number(normalized) next to item entry

ah save -- save settings related to text object


check settings file for more customization options.


TODO:	Expand delivery boxes beyond auction house zones (list mog house zones, other delivery areas),
	Block sell confirm window when injecting sell packet (only occurs when selling inside sell menu),
	Adjust delays.
