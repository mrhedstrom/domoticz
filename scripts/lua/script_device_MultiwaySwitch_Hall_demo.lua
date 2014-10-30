-- Multiway switch script for domoticz. By Mattias Hedström.
-- Makes it possiblee to use a dual relay with energy meter as a multiway switch. It has  to be with energy meter and with a measurable load.
-- Make sure to use one monostable switch connected to both S1 and S2 for relay to act as multiway switch at manual operation.
-- When is this usable? Well, google it, or use wikipedia; http://en.wikipedia.org/wiki/Multiway_switching
-- I intend to use it in a traveler system with a non z-wave trailing edge dimmer due to absense of z-wave enabled trailing edge dimmers.
-- That way I can at least view state and turn On/Off lights in Domoticz. Dimming has to be made manual :(

-- Place one script for each multiway switch with different names in Domoticz/scripts/lua.
-- Keep the filename prefix "script_device_". e.g. "script_device_MultiwayHallway.lua".
-- To disable a script in the script folder, rename lua script with suffix "_demo.lua". e.g. "script_device_MultiwayHallway_demo.lua".
-- Make sure to add the virtual switch that will represent the multiway switch.

-- All names in settings have to be unique. Do not name energy meters and relays with the same names.

-- Settings:
-- Switch name for relay 1 (do not control this relay manually in domoticz, actually you can hide it)
r1 = 'Hall No1'
-- switch name for relay 2 (do not control this relay manually in domoticz, actually you can hide it)
r2 = 'Hall No2'
-- Viritual Switch Name (this is the viritual switch representing the multiway switch)
v = 'Hall'
-- Energy meter for relay 1 and 2 can be the same meter if the unit only has one meter for the two relays.
-- If it has two meters both meters must be entered separately.
-- Energy meter name for relay 1
m1 = 'Hall Energi No1'
-- Energy meter name for relay 2
m2 = 'Hall Energi No2'



commandArray = {}
if ((devicechanged[v] == 'On' and tonumber(otherdevices_svalues[m1]) == 0 and tonumber(otherdevices_svalues[m2]) == 0) or 
(devicechanged[v] == 'Off' and (tonumber(otherdevices_svalues[m1]) > 0 or tonumber(otherdevices_svalues[m2]) > 0))) then
	-- due to delay from switching from domoticz until meter change actual energy this is user triggered from controller
	-- change state on relays
	print(string.format('User triggered multiway switch %q. Changing state on relays.',v))
	if otherdevices[r1] == nil or otherdevices[r2] == nil then
		print(string.format('At least one relay returned nil value. %s: %s. %s: %s\nMake sure to wake relay switches manually.',
		r1,otherdevices[r1],r2,otherdevices[r2]))
	elseif otherdevices[r1]=='On' and otherdevices[r2]=='On' then
		-- relays are in wrong state, one should be closed and the other opened. Open r1
		commandArray[r1]='Off'
	elseif otherdevices[r1]=='Off' and otherdevices[r2]=='Off' then
		-- relays are in wrong state, one should be closed and the other opened. Close r1
		commandArray[r1]='On'
	elseif otherdevices[r1]=='On' and otherdevices[r2]=='Off' then
		-- change state, change to off first then on, both relays may not be closed at once.
		commandArray[r1]='Off'
		commandArray[r2]='On'		
	elseif otherdevices[r1]=='Off' and otherdevices[r2]=='On' then
		-- change state, change to off first then on, both relays may not be closed at once.
		commandArray[r2]='Off'		
		commandArray[r1]='On'
	end
elseif (devicechanged[m1] == '' or devicechanged[m2] == '') then
	-- Any relay meter got new reading, check state on virtual switch
	
	if (otherdevices[v]=='Off' and (tonumber(otherdevices_svalues[m1]) > 0 or tonumber(otherdevices_svalues[m2]) > 0)) then
		-- Virtual device should indicate that switch is on
		print(string.format('Multiway switch %q was turned On manually utside Domoticz. Changing indication state for virtual device.',v))
		commandArray[v]='On'
	elseif (otherdevices[v]=='On' and tonumber(otherdevices_svalues[m1]) == 0 and tonumber(otherdevices_svalues[m2]) == 0) then
		-- Virtual device should indicate that switch is off
		print(string.format('Multiway switch %q was turned Off manually utside Domoticz. Changing indication state for virtual device.',v))
		commandArray[v]='Off'
	end
end
return commandArray
