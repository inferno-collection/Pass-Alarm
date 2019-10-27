-- Inferno Collection Pass Alarm Version 1.31 Beta
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
--
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--
local Config = {} -- Do not edit this line
-- Whether or not to enable notifications
Config.Notifications = true
-- Whether or not to enforce a ped whitelist
Config.EnablePedWhitelist = true
-- The model name of the peds that are able to use the Pass Alarm
Config.AllowedPeds = {
	"s_m_y_fireman_01"
}
-- The size around the source the pass alarm can be heard.
-- Alarm gets quieter the further from the origin, so the
-- number below is the further spot it will be able to be heard from
Config.AlarmSize = 20
-- The length of time in ms it takes to play the "stage1" sound file.
-- It is recommended that you do not edit this unless you change the
-- "stage1" sound file. Time starts from start of audio file, not end
Config.Stage1Length = 12100

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Local Pass Alarm Variables
local PassAlarm = {}
-- All Pass Alarms
PassAlarm.Alarms = {}
-- Client's current stage
-- 0 = Disabled
-- 1 = Enabled, not sounding
-- 2 = Stage 1 activated
-- 3 = Stage 2 activated
PassAlarm.Status = 0
-- Client's positions
PassAlarm.Positions = {}

AddEventHandler("onClientMapStart", function ()
	TriggerEvent("chat:addSuggestion", "/pass", "Enable or disable your Pass Alarm.")
	TriggerEvent("chat:addSuggestion", "/passpanic", "Activate your Pass Alarm panic button.")
	TriggerEvent("chat:addSuggestion", "/passreset", "Reset any active Alarms.")
end)

-- /pass command
-- Used to toggle pass alarm
RegisterCommand("pass", function()
	local PlayerPed = PlayerPedId()
	local PedFound = false

	if Config.EnablePedWhitelist then
		for _, Ped in ipairs(Config.AllowedPeds) do
			-- If the current player's ped is in the list of allowed peds
			if IsPedModel(PlayerPed, GetHashKey(Ped)) then
				PedFound = true
				break
			end
		end
	else
		PedFound = true
	end

	if PedFound then
		if PassAlarm.Status == 0 then
			if not HasAnimDictLoaded("random@arrests") then
				RequestAnimDict("random@arrests")
				while not HasAnimDictLoaded("random@arrests") do
					Citizen.Wait(0)
				end
			end

			-- Touches shoulder as if turning on/off a pass alarm
			TaskPlayAnim(PlayerPed, "random@arrests", "generic_radio_chatter", -1, -8, 0.01, 49, 0, 0, 0, 0)
			Citizen.Wait(600)
			StopAnimTask(PlayerPed, "random@arrests", "generic_radio_chatter", 1.5)
			TriggerServerEvent("Pass-Alarm:Server", false, false, "AddAlarm")
			PassAlarm.Status = 1
		elseif PassAlarm.Status == 3 then
			NewNoti("~r~Use /passreset to disable your active Alarm, then use /pass to disable your Pass Alarm.", true)
		else
			if not HasAnimDictLoaded("random@arrests") then
				RequestAnimDict("random@arrests")
				while not HasAnimDictLoaded("random@arrests") do
					Citizen.Wait(0)
				end
			end

			-- Touches shoulder as if turning on/off a pass alarm
			TaskPlayAnim(PlayerPed, "random@arrests", "generic_radio_chatter", -1, -8, 0.01, 49, 0, 0, 0, 0)
			Citizen.Wait(600)
			StopAnimTask(PlayerPed, "random@arrests", "generic_radio_chatter", 1.5)
			TriggerServerEvent("Pass-Alarm:Server", true, false, "DeactivateAlarm")
			PassAlarm.Status = 0
		end
	else
		NewNoti("~r~Your ped is not whitelisted for the /pass command.", true)
	end
end)

-- /passpanic command
-- Used to toggle pass alarm panic button
RegisterCommand("passpanic", function()
	local PlayerPed = PlayerPedId()
	local PedFound = false
	if Config.EnablePedWhitelist then
		for _, Ped in ipairs(Config.AllowedPeds) do
			-- If the current player's ped is in the list of allowed peds
			if IsPedModel(PlayerPed, GetHashKey(Ped)) then
				PedFound = true
				break
			end
		end
	else
		PedFound = true
	end

	if PedFound then
		if PassAlarm.Status == 0 then
			NewNoti("~r~You need your Pass Alarm enabled to use the panic button.", true)
		elseif PassAlarm.Status == 1 or PassAlarm.Status == 2 then
			if not HasAnimDictLoaded("random@arrests") then
				RequestAnimDict("random@arrests")
				while not HasAnimDictLoaded("random@arrests") do
					Citizen.Wait(0)
				end
			end

			-- Touches shoulder as if pressing panic button
			TaskPlayAnim(PlayerPed, "random@arrests", "generic_radio_chatter", -1, -8, 0.01, 49, 0, 0, 0, 0)
			Citizen.Wait(300)
			StopAnimTask(PlayerPed, "random@arrests", "generic_radio_chatter", 1.5)
			PassAlarm.Status = 3
			TriggerServerEvent("Pass-Alarm:Server", true, false, "Stage2")
			NewNoti("~y~Panic button activated!", true)
		elseif PassAlarm.Status == 3 then
			NewNoti("~r~Use /passreset to disable your panic button.", false)
		end
	else
		NewNoti("~r~Your ped is not whitelisted for the /passpanic command.", true)
	end
end)

-- /passreset command
-- Used to reset a pass alarm after stage 2 or panic activation
RegisterCommand("passreset", function()
	local PlayerPed = PlayerPedId()
	local PedFound = false
	if Config.EnablePedWhitelist then
		for _, Ped in ipairs(Config.AllowedPeds) do
			-- If the current player's ped is in the list of allowed peds
			if IsPedModel(PlayerPed, GetHashKey(Ped)) then
				PedFound = true
				break
			end
		end
	else
		PedFound = true
	end

	if PedFound then
		if PassAlarm.Status == 0 then
			NewNoti("~r~Your Pass Alarm is not enabled, there is nothing to reset.", false)
		elseif PassAlarm.Status == 1 then
			NewNoti("~r~Your Pass Alarm is enabled, but not in Alarm; there is nothing to reset.", false)
		elseif PassAlarm.Status == 2 then
			if not HasAnimDictLoaded("random@arrests") then
				RequestAnimDict("random@arrests")
				while not HasAnimDictLoaded("random@arrests") do
					Citizen.Wait(0)
				end
			end

			-- Touches shoulder as if turning on/off a pass alarm
			TaskPlayAnim(PlayerPed, "random@arrests", "generic_radio_chatter", -1, -8, 0.01, 49, 0, 0, 0, 0)
			Citizen.Wait(1000)
			StopAnimTask(PlayerPed, "random@arrests", "generic_radio_chatter", 1.5)
			PassAlarm.Status = 1
			TriggerServerEvent("Pass-Alarm:Server", true, false, "StopAlarm")
			NewNoti("~y~Pass Alarm reset. ~g~For future reference, during stage 1, simply moving will disable your alarm.", false)
		elseif PassAlarm.Status == 3 then
			if not HasAnimDictLoaded("random@arrests") then
				RequestAnimDict("random@arrests")
				while not HasAnimDictLoaded("random@arrests") do
					Citizen.Wait(0)
				end
			end

			-- Touches shoulder as if turning on/off a pass alarm
			TaskPlayAnim(PlayerPed, "random@arrests", "generic_radio_chatter", -1, -8, 0.01, 49, 0, 0, 0, 0)
			Citizen.Wait(1000)
			StopAnimTask(PlayerPed, "random@arrests", "generic_radio_chatter", 1.5)
			PassAlarm.Status = 1
			TriggerServerEvent("Pass-Alarm:Server", true, false, "StopAlarm")
			NewNoti("~y~Pass Alarm reset.", false)
		end
	else
		NewNoti("~r~Your ped is not whitelisted for the /passreset command.", true)
	end
end)

-- Bounce between server & client script and client NUI
RegisterNetEvent("Pass-Alarm:Bounce:NUI")
AddEventHandler("Pass-Alarm:Bounce:NUI", function(Type, Load)
	SendNUIMessage({
		PayloadType	= Type,
		Payload		= Load
	})
end)

RegisterNUICallback("RemoveAlarm", function(ID)
	-- If the client is the owner of this pass alarm, remove pass alarm
	-- This check is done so only one event is sent to the server instead of 32+
	if GetPlayerServerId(PlayerId()) == ID then
		TriggerServerEvent("Pass-Alarm:Server", true, true, "RemoveAlarm")
	end
end)

-- Bounce between server script and client script
RegisterNetEvent("Pass-Alarm:Bounce:ServerValues")
AddEventHandler("Pass-Alarm:Bounce:ServerValues", function(PAs) PassAlarm.Alarms = PAs end)

-- Rounds numbers to two decimal places
function Round2DP(Number) return (math.floor(Number * math.pow(10, 2) + 0.5) / math.pow(10, 2)) end

-- Draws notification on client's screen
function NewNoti(Text, Flash)
	if Config.Notifications then
		-- Tell GTA that a string will be passed
		SetNotificationTextEntry("STRING")
		-- Pass temporary variable to notification
		AddTextComponentString(Text)
		-- Draw new notification on client's screen
		DrawNotification(Flash, true)
	end
end

-- Volume loop
-- Sets the volumes of all current pass alarms, relative to the position of the pass alarm
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local PassAlarmCount = 0
		for _, _ in pairs(PassAlarm.Alarms) do PassAlarmCount = PassAlarmCount + 1 end

		if PassAlarmCount >= 1 then
			local PlayerPed = PlayerPedId()
			local PlayerCoords = GetEntityCoords(PlayerPed, false)

			for Alarm, _ in pairs(PassAlarm.Alarms) do
				local PassAlarmCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(Alarm)))
				local Distance = Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, PassAlarmCoords.x, PassAlarmCoords.y, PassAlarmCoords.z) + 0.01 -- Stops divide by 0 errors
				if (Distance <= Config.AlarmSize) then
					TriggerEvent("Pass-Alarm:Bounce:NUI", "SetAlarmVolume", {Alarm, 1 - (Distance / Config.AlarmSize)})
					print(1 - (Distance / Config.AlarmSize))
				else
					TriggerEvent("Pass-Alarm:Bounce:NUI", "SetAlarmVolume", {Alarm, 0})
				end
			end
		end

	end
end)

-- Movement checker
-- Checks for player movment while they have an active pass alarm
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		-- If pass alarm is disactivated but the client has logged postions
		if PassAlarm.Status == 0 and #PassAlarm.Positions >= 1 then
			PassAlarm.Positions = {}
		elseif PassAlarm.Status == 1 then
			local PlayerPed = PlayerPedId()
			local PlayerCoords = GetEntityCoords(PlayerPed, false)
			table.insert(PassAlarm.Positions, PlayerCoords)
			Citizen.Wait(1000)

			if #PassAlarm.Positions >= 18 then
				local Total = {}
				Total.x = 0
				Total.y = 0
				Total.z = 0

				for _, PassAlarmPosition in ipairs(PassAlarm.Positions) do
					Total.x = Total.x + PassAlarmPosition.x
					Total.y = Total.y + PassAlarmPosition.y
					Total.z = Total.z + PassAlarmPosition.z
				end

				-- If the player has not moved more than a few inches in the last 18 seconds
				if Round2DP(Total.x / 18) == Round2DP(PlayerCoords.x)
				and Round2DP(Total.y / 18) == Round2DP(PlayerCoords.y)
				and Round2DP(Total.z / 18) == Round2DP(PlayerCoords.z)
				then
					PassAlarm.Status = 2
					TriggerServerEvent("Pass-Alarm:Server", true, false, "Stage1")
				end

				-- Removes oldest entry from array
				table.remove(PassAlarm.Positions, 1)
			end
		elseif PassAlarm.Status == 2 then
			local PlayerPed = PlayerPedId()
			local FirstCoordCheck = GetEntityCoords(PlayerPed, false)
			Citizen.Wait(1000)
			local SencondCoordCheck = GetEntityCoords(PlayerPed, false)

			-- If the player moves more than a few inches
			if Round2DP(FirstCoordCheck.x) ~= Round2DP(SencondCoordCheck.x)
			or Round2DP(FirstCoordCheck.y) ~= Round2DP(SencondCoordCheck.y)
			or Round2DP(FirstCoordCheck.z) ~= Round2DP(SencondCoordCheck.z)
			then
				PassAlarm.Status = 1
				TriggerServerEvent("Pass-Alarm:Server", true, false, "StopAlarm")
			end

			PassAlarm.Positions = {}
		end

	end
end)

-- If by the end of the stage one alarm the player has still not moved, play stage 2 alarm
-- Placed in a seperate loop to avoid .wait conflicts
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PassAlarm.Status == 2 then
			Citizen.Wait(Config.Stage1Length)
			if PassAlarm.Status == 2 then
				PassAlarm.Status = 3
				TriggerServerEvent("Pass-Alarm:Server", true, false, "Stage2")
			end
		end
	end
end)