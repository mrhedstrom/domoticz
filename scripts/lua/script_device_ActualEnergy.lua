--Domoticz Script to get medium actual energy between energy counter readings and puts it on a dummy device

--First create a dummy energy meter and two user variables as numbers.
--Then enter the details below

--Name of the real energy counter
energyCounter = 'Elförbrukning'
--ID of the created dummy energy meter with the new actual value
dummyEnergyMeterid = 126

--The names of two user variables to keep track of previous value due to wrong values from dummy in otherdevices_lastupdate and otherdevices_svalues
userVariableTimestamp = 'LastEnergyTimestamp'
userVariableLastCount = 'LastEnergyCount'

commandArray = {}
if devicechanged[energyCounter] then
	--calculate new actual value
	actual = ((tonumber(otherdevices_svalues[energyCounter]) - tonumber(uservariables[userVariableLastCount])))/((os.time()-uservariables[userVariableTimestamp])/3600)
	
	--update dummy energy meter
	commandArray[1] = {['UpdateDevice'] = dummyEnergyMeterid .. "|0|" .. actual .. ";" .. otherdevices_svalues[energyCounter]}
	
	--update user variables
	commandArray[2] = {['Variable:'..userVariableTimestamp] = tostring(os.time())}
	commandArray[3] = {['Variable:'..userVariableLastCount] = otherdevices_svalues[energyCounter]}
	
	print("DummyEnergy: " .. actual .. " W, " .. otherdevices_svalues[energyCounter] .. " kWh")
end

return commandArray
