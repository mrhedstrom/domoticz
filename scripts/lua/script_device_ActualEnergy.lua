--Domoticz Script to get medium actual energy between energy counter readings and puts it on a dummy device

--First create one dummy energy meter. (Actual + Counter)
--Edit the new device and set up "Energy read" to "From device" not "Computed"
--Then enter the details below

--Name of the real energy counter
energyCounter = 'Elförbrukning'
--Name of the created dummy energy meter with the new actual value
dummyEnergyMeter = 'Elförbrukning2'

--Counter divider offset for dummy energy meter. Only use this for counters that differs from global setting for counter divider.
--To add one tenfold set this to 10
--To remove one tenfold set to 1/10
counterDividerOffset=1

--Update with JSON to trigger event system for dummy device on update
updateWithJSON=false
domoticzPortNumber=8080

commandArray = {}
if devicechanged[energyCounter] then
	--calculate new actual value
	s = otherdevices_lastupdate[dummyEnergyMeter]
	lastDummyCounter = string.match(otherdevices_svalues[dummyEnergyMeter], ";(.+)")
	lastDummyCounterAsNumber = tonumber(lastDummyCounter)
	lastCounterAsNumber = tonumber(otherdevices_svalues[energyCounter])
	if lastCounterAsNumber == nil then
		lastCounterAsNumber = tonumber(string.match(otherdevices_svalues[energyCounter], ";(.+)"))
	end
	if lastCounterAsNumber == nil then
		print('Error reading value from energy counter ' .. energyCounter ..
			'. The type of the device is probably not a counter or the device is missing.')
		return commandArray
	else
		lastCounterAsNumber = counterDividerOffset * lastCounterAsNumber
	end
	
	actual = 0
	if s == nil then
		print('First  time script is ever triggered. Update only counter. Actual value will be updated next time.')
	elseif lastDummyCounter == nil or lastDummyCounter == '' or lastDummyCounterAsNumber == nil then
		print('Error reading last value from dummy ' .. dummyEnergyMeter .. 
			'. Got value ' .. lastDummyCounter .. ' from ' .. otherdevices_svalues[dummyEnergyMeter] ..
			'. Actual value will be excluded this reading.')
	elseif lastCounterAsNumber - lastDummyCounterAsNumber <= 0 then
		print('Last reading is the same or less than this reading. ' ..
			'Make sure the counter is being updated and make sure no other scripts are triggered on device: ' .. 
			energyCounter .. '. Or just be happy that you energy consumption is zero.')
	else
		t = os.time{year=string.sub(s, 1, 4), month=string.sub(s, 6, 7), day=string.sub(s, 9, 10), hour=string.sub(s, 12, 13), min=string.sub(s, 15, 16), sec=string.sub(s, 18, 19)}
		timeDiff = os.difftime(os.time(), t)
		if timeDiff <=0 then
			print('Error. Dummy device was just updated.')
		else
			actual = (lastCounterAsNumber - lastDummyCounterAsNumber)/(timeDiff/3600)
		end
	end
	
	--update dummy energy meter
	if updateWithJSON then
		os.execute('curl "http://127.0.0.1:' .. domoticzPortNumber .. '/json.htm?type=command&param=udevice&idx=' .. otherdevices_idx[dummyEnergyMeter] .. '&nvalue=0&svalue=' .. actual .. ';' .. lastCounterAsNumber .. '"')
	else
		commandArray[1] = {['UpdateDevice'] = otherdevices_idx[dummyEnergyMeter] .. "|0|" .. actual .. ";" .. lastCounterAsNumber}
	end
	
	print(dummyEnergyMeter .. ": " .. actual .. " W, " .. lastCounterAsNumber .. " Wh")
end

return commandArray
