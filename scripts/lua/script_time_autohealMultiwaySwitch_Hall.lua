-- This script will heal a multiway switch. If both relays has the same state they are switch to on and off.

-- Settings:
-- Switch name for relay 1
r1 = 'Hall No1'
-- switch name for relay 2
r2 = 'Hall No2'
-- Viritual Switch Name (this is the viritual switch representing the multiway switch)
v = 'Hall'


function timeSinceUpdate (device)
	t1 = os.time()
	s = otherdevices_lastupdate[device]
	year = string.sub(s, 1, 4)
	month = string.sub(s, 6, 7)
	day = string.sub(s, 9, 10)
	hour = string.sub(s, 12, 13)
	minutes = string.sub(s, 15, 16)
	seconds = string.sub(s, 18, 19)
	t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
	return (os.difftime (t1, t2))
end

commandArray = {}
if otherdevices[r1] == nil or otherdevices[r2] == nil then
		print(string.format('At least one relay returned nil value. %s: %s. %s: %s\nMake sure to wake relay switches manually.',
		r1,otherdevices[r1],r2,otherdevices[r2]))
elseif (otherdevices[r1] == otherdevices[r2]) then
	-- make sure the devices has been idle for at least 10 seconds before healing
	diff1 = timeSinceUpdate(r1)
	diff2 = timeSinceUpdate(r2)
	
	if (diff1<diff2) then
		diff = diff2
	else
		diff = diff1
	end

	if (diff > 10) then
		print(string.format('Healing Multiway switch %s. Both relay %s and %s are %s.',v,r1,r2,otherdevices[r1]))
		commandArray[r1]='Off'
		commandArray[r2]='On'
	end
end
return commandArray

