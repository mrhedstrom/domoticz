--Domoticz Script to get medium actual energy between energy counter readings and puts it on a dummy device

--First create a dummy energy meter.
--Then enter the details below

--Name of the real energy counter
energyCounter = 'Elförbrukning'
--Name of the created dummy energy meter with the new actual value
dummyEnergyMeter = 'Elförbrukning2'
--ID of the created dummy energy meter with the new actual value
dummyEnergyMeterid = 126

commandArray = {}
if devicechanged[energyCounter] then
	--calculate new actual value
	s = otherdevices_lastupdate[dummyEnergyMeter]
	if s == nil then
		print('First  time script is ever triggered. Update only counter. Actual value will be updated next time.')
		actual = 0
	else
		t = os.time{year=string.sub(s, 1, 4), month=string.sub(s, 6, 7), day=string.sub(s, 9, 10), hour=string.sub(s, 12, 13), min=string.sub(s, 15, 16), sec=string.sub(s, 18, 19)}
		actual = (tonumber(otherdevices_svalues[energyCounter]) - tonumber(string.match(otherdevices_svalues[dummyEnergyMeter], ";(%d+%.*%d*)")))/(os.difftime(os.time(), t)/3600)
	end
	
	--update dummy energy meter
	commandArray[1] = {['UpdateDevice'] = dummyEnergyMeterid .. "|0|" .. actual .. ";" .. otherdevices_svalues[energyCounter]}
	
	print(dummyEnergyMeter .. ": " .. actual .. " W, " .. otherdevices_svalues[energyCounter] .. " Wh")
end

return commandArray
