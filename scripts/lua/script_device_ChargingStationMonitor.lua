--Script to turn off charging station when mobile phone is charged
--This is to prevent overcharging and get longer battery life.
--It's also good for getting rid of fire hazards and standby energy loss.

--First create a dummy switch to enable the script
--Then enter the details below

--Name of the real Charging Station switch with energy meter
chargerSwitch = 'Laddstation'
--Name of the real Charging Station Energy meter
chargerEnergyMeter = 'Laddstation energi'
--Name of the dummy switch to enable the script
chargerStationEnergyMonitorSwitch = 'Laddstation Energiavslagning'

--If energy falls below this value switch will turn off
energyMinimumForSwitch = 0.8

--The shortest period the switch will be turnd on in seconds
minTime=30

commandArray = {}
if devicechanged[chargerEnergyMeter] then
	if otherdevices[chargerStationEnergyMonitorSwitch] == 'On' and otherdevices[chargerSwitch] == 'On' then
		t1 = os.time()
		s = otherdevices_lastupdate[chargerSwitch]

		year = string.sub(s, 1, 4)
		month = string.sub(s, 6, 7)
		day = string.sub(s, 9, 10)
		hour = string.sub(s, 12, 13)
		minutes = string.sub(s, 15, 16)
		seconds = string.sub(s, 18, 19)
		t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		
		difference = (os.difftime (t1, t2))
		
		if tonumber(otherdevices_svalues[chargerEnergyMeter]) < energyMinimumForSwitch and difference > minTime then
			commandArray[chargerSwitch]='Off'
		end
	end
end

return commandArray
