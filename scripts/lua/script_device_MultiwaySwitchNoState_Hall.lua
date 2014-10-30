-- Multi-way switch script for domoticz. By Mattias Hedström.
-- Makes it possible to use a dual relay as a multi-way switch.
-- Make sure to use one monostable switch connected to both S1 and S2 for relay to act as multi-way switch at manual operation.
-- When is this usable? Well, google it, or use wikipedia; http://en.wikipedia.org/wiki/Multiway_switching
-- I intend to use it in a traveller system with a non z-wave trailing edge dimmer due to absense of z-wave enabled trailing edge dimmers.
-- That way I can at least turn On/Off lights in Domoticz. Dimming has to be made manual :(

-- Place one script for each multi-way switch with different names in Domoticz/scripts/lua.
-- Keep the file name prefix "script_device_". e.g. "script_device_MultiwayHallway.lua".
-- To disable a script in the script folder, rename lua script with suffix "_demo.lua". e.g. "script_device_MultiwayHallway_demo.lua".
-- Make sure to add the virtual switch that will represent the multi-way switch.

-- All names in settings have to be unique. Do not name energy meters and relays with the same names.

-- Settings:
-- Switch name for relay 1 (do not control this relay manually in domoticz, actually you can hide it)
r1 = 'Hall No1'
-- switch name for relay 2 (do not control this relay manually in domoticz, actually you can hide it)
r2 = 'Hall No2'
-- Viritual Switch Name (this is the viritual switch representing the multiway switch)
v = 'Hall'

commandArray = {}
if (devicechanged[v] == 'On') then
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
end
return commandArray
