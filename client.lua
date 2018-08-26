-- Local
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local CurrentAction = nil
local GUI                       = {}
GUI.Time                        = 0
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local PlayerData                = {}

local this_Garage = {}
-- Fin Local

-- Init ESX
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
		ESX = obj 
		refreshBlips()
		end)
		Citizen.Wait(0)
	end
end)
-- Fin init ESX
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)
--- Gestion Des blips
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    --TriggerServerEvent('esx_jobs:giveBackCautionInCaseOfDrop')
    refreshBlips()
end)

function refreshBlips()
	local zones = {}
	local blipInfo = {}	

	for zoneKey,zoneValues in pairs(Config.Garages)do
		local blip = AddBlipForCoord(zoneValues.Pos.x, zoneValues.Pos.y, zoneValues.Pos.z)
		SetBlipSprite (blip, Config.BlipInfos.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, Config.BlipInfos.Color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		-- AddTextComponentString(zoneKey)
		AddTextComponentString("Garage Voitures")
		EndTextCommandSetBlipName(blip)
	end
	for zoneKey,zoneValues in pairs(Config.GaragesMecano) do
		local blip = AddBlipForCoord(zoneValues.DeletePoint.Pos.x, zoneValues.DeletePoint.Pos.y, zoneValues.DeletePoint.Pos.z)
		SetBlipSprite (blip, Config.BlipInfos.Sprite)
		SetBlipDisplay(blip, 487)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 47)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		-- AddTextComponentString(zoneKey)
		AddTextComponentString("Fourriere mecano")
		EndTextCommandSetBlipName(blip)
	end
end
-- Fin Gestion des Blips

--Fonction Menu

function OpenMenuGarage()
	
	
	ESX.UI.Menu.CloseAll()

	local elements = {
		-- {label = "Liste des véhicules", value = 'list_vehicles'},
		-- {label = "Rentrer vehicules", value = 'stock_vehicle'},
		{label = "Retour vehicule ("..Config.Price.."$)", value = 'return_vehicle'},
	}


	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'garage_menu',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			-- if(data.current.value == 'list_vehicles') then
				-- ListVehiclesMenu()
			-- end
			-- if(data.current.value == 'stock_vehicle') then
				-- StockVehicleMenu()
			-- end
			if(data.current.value == 'return_vehicle') then
				ReturnVehicleMenu()
			end

			local playerPed = GetPlayerPed(-1)
			SpawnVehicle(data.current.value)
			--local coords    = societyConfig.Zones.VehicleSpawnPoint.Pos

		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)	
end
-- Afficher les listes des vehicules
function ListVehiclesMenu()
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)
		for _,v in pairs(vehicles) do

			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
    		local labelvehicle
			
    		if(v.fourrieremecano)then
				labelvehicle = vehicleName..': Fourrière mecano'
    		elseif(v.state)then
				labelvehicle = vehicleName..': Rentré'
    		else
				labelvehicle = vehicleName..': Sortie'
    		end	
			table.insert(elements, {label =labelvehicle , value = v})
			
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if(data.current.value.state)then
				menu.close()
				SpawnVehicle(data.current.value.vehicle)
			else
				TriggerEvent('esx:showNotification', 'Votre véhicule est déjà sorti')
			end
		end,
		function(data, menu)
			menu.close()
			-- CurrentAction = 'open_garage_action'
		end
	)	
	end)
end
-- Fin Afficher les listes des vehicules

-- Afficher les listes des vehicules de fourriere
function ListVehiclesFourriereMenu()
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehiclesMecano', function(vehicles)

		for _,v in pairs(vehicles) do

			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)

			table.insert(elements, {label =vehicleName.." | "..v.firstname.." "..v.lastname , value = v})
			
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			-- if(data.current.value.state)then
				menu.close()
				SpawnVehicleMecano(data.current.value.vehicle)
				TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', data.current.value.vehicle, false)
			-- else
				-- TriggerEvent('esx:showNotification', 'Votre véhicule est déjà sorti')
			-- end
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)	
	end)
end
-- Fin Afficher les listes des vehicules de fourriere


-- Fonction qui permet de rentrer un vehicule
function StockVehicleMenu()
	local playerPed  = GetPlayerPed(-1)
	-- if IsAnyVehicleNearPoint(this_Garage.DeletePoint.Pos.x,  this_Garage.DeletePoint.Pos.y,  this_Garage.DeletePoint.Pos.z,  3.5) then
	if IsPedInAnyVehicle(playerPed,  false) then
		-- local vehicle       = GetClosestVehicle(this_Garage.DeletePoint.Pos.x, this_Garage.DeletePoint.Pos.y, this_Garage.DeletePoint.Pos.z, this_Garage.DeletePoint.Size.x, 0, 70)
		local vehicle =GetVehiclePedIsIn(playerPed,false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		-- local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(GetVehiclePedIsIn(playerPed, true))
		local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
		local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
		if GotTrailer then
			ESX.TriggerServerCallback('eden_garage:stockv',function(valid)

				if(valid) then
					TriggerServerEvent('eden_garage:debug', TrailerHandle)
					DeleteVehicle(TrailerHandle)
					TriggerServerEvent('eden_garage:modifystate', trailerProps, true)
					TriggerEvent('esx:showNotification', 'Votre remorque est dans le garage')
				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
				end
			end,trailerProps)
			hasAlreadyEnteredMarker = false
		else
			ESX.TriggerServerCallback('eden_garage:stockv',function(valid)
				if(valid) then
					TriggerServerEvent('eden_garage:debug', vehicle)
					DeleteVehicle(vehicle)
					TriggerServerEvent('eden_garage:modifystate', vehicleProps, true)
					TriggerEvent('esx:showNotification', 'Votre véhicule est dans le garage')
				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
				end
			end,vehicleProps)
		end
	else
		TriggerEvent('esx:showNotification', 'Il n\' y a pas de vehicule à rentrer')
	end
	CurrentAction = 'garage_delete'
end
-- Fin fonction qui permet de rentrer un vehicule 

-- Fonction qui permet de rentrer un vehicule dans fourriere
function StockVehicleFourriereMenu()
	local playerPed  = GetPlayerPed(-1)
	-- if IsAnyVehicleNearPoint(this_Garage.DeletePoint.Pos.x,  this_Garage.DeletePoint.Pos.y,  this_Garage.DeletePoint.Pos.z,  3.5) then
	if IsPedInAnyVehicle(playerPed,  false) then
		-- local vehicle       = GetClosestVehicle(this_Garage.DeletePoint.Pos.x, this_Garage.DeletePoint.Pos.y, this_Garage.DeletePoint.Pos.z, this_Garage.DeletePoint.Size.x, 0, 70)
		local vehicle =GetVehiclePedIsIn(playerPed,false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		-- local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(GetVehiclePedIsIn(playerPed, true))
		local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
		local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
		if GotTrailer then
			ESX.TriggerServerCallback('eden_garage:stockvmecano',function(valid)

				if(valid) then
					-- TriggerServerEvent('eden_garage:debug', TrailerHandle)
					DeleteVehicle(TrailerHandle)
					TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', trailerProps, true)
					TriggerEvent('esx:showNotification', 'La remorque est rentré dans la fourrière')
				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker cette remorque dans la fourrière')
				end
			end,trailerProps)
			hasAlreadyEnteredMarker = false
		else
			ESX.TriggerServerCallback('eden_garage:stockvmecano',function(valid)
				if(valid) then
					-- TriggerServerEvent('eden_garage:debug', vehicle)
					DeleteVehicle(vehicle)
					TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicleProps, true)
					TriggerEvent('esx:showNotification', 'Le véhicule est rentré dans la fourrière')
				else
					TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule dans la fourrière')
				end
			end,vehicleProps)
		end
	else
		TriggerEvent('esx:showNotification', 'Il n\' y a pas de vehicule à rentrer')
	end
	CurrentAction = 'garagemecano_delete'
end
-- Fin fonction qui permet de rentrer un vehicule dans fourriere
--Fin fonction Menu


--Fonction pour spawn vehicule
function SpawnVehicle(vehicle)

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = this_Garage.SpawnPoint.Pos.x ,
		y = this_Garage.SpawnPoint.Pos.y,
		z = this_Garage.SpawnPoint.Pos.z + 1											
		},this_Garage.SpawnPoint.Heading, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		end)
	TriggerServerEvent('eden_garage:modifystate', vehicle, false)

end
--Fin fonction pour spawn vehicule

--Fonction pour spawn vehicule fourriere mecano
function SpawnVehicleMecano(vehicle)

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = this_Garage.SpawnPoint.Pos.x ,
		y = this_Garage.SpawnPoint.Pos.y,
		z = this_Garage.SpawnPoint.Pos.z + 1											
		},this_Garage.SpawnPoint.Heading, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		end)
	TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicle, false)
end
--Fin fonction pour spawn vehicule fourriere mecano

--Action das les markers
AddEventHandler('eden_garage:hasEnteredMarker', function(zone)
	if zone == 'garage' then
		CurrentAction     = 'garage_action_menu'
		CurrentActionMsg  = "Appuyer sur ~INPUT_PICKUP~ pour ouvrir le garage"
		CurrentActionData = {}
	end
	
	if zone == 'spawn' then
		CurrentAction     = 'garage_spawn'
		CurrentActionMsg  = "Appuyer sur ~INPUT_PICKUP~ pour sortir votre véhicule"
		CurrentActionData = {}
	end	
	
	if zone == 'delete' then
		CurrentAction     = 'garage_delete'
		CurrentActionMsg  = "Appuyer sur ~INPUT_PICKUP~ pour rentrer votre véhicule"
		CurrentActionData = {}
	end	
	
	if zone == 'spawnmecano' then
		CurrentAction     = 'garagemecano_spawn'
		CurrentActionMsg  = "Appuyer sur ~INPUT_PICKUP~ pour sortir un véhicule de fourrière"
		CurrentActionData = {}
	end	
	
	if zone == 'deletemecano' then
		CurrentAction     = 'garagemecano_delete'
		CurrentActionMsg  = "Appuyer sur ~INPUT_PICKUP~ pour rentrer un véhicule de fourrière"
		CurrentActionData = {}
	end
end)

AddEventHandler('eden_garage:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)
--Fin Action das les markers

function ReturnVehicleMenu()

	ESX.TriggerServerCallback('eden_garage:getOutVehicles', function(vehicles)
		local elements = {}

		for _,v in pairs(vehicles) do

			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
    		local labelvehicle
			
			if v.fourrieremecano then
				labelvehicle = vehicleName..': Fourrière mecano'
				table.insert(elements, {label =labelvehicle , value = 'fourrieremecano'})
			else
				labelvehicle = vehicleName..': Sortie'
				table.insert(elements, {label =labelvehicle , value = v.vehicle})
			end
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'return_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if data.current.value == 'fourrieremecano' then
				ESX.ShowNotification("Va voir un mecano pour récupérer ton véhicule dans la fourrière.")
			else
				ESX.TriggerServerCallback('eden_garage:checkMoney', function(hasEnoughMoney)
					if hasEnoughMoney then
								
						TriggerServerEvent('eden_garage:pay')
						SpawnVehicle(data.current.value)
					else
						ESX.ShowNotification('Vous n\'avez pas assez d\'argent')						
					end
				end)				
			end
		end,
		function(data, menu)
			menu.close()
			-- CurrentAction = 'garage_spawn'
		end
		)	
	end)
end

-- Affichage markers
Citizen.CreateThread(function()
	while true do
		Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))			

		for k,v in pairs(Config.Garages) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then		
				DrawMarker(v.Marker, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(v.SpawnPoint.Marker, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.SpawnPoint.Size.x, v.SpawnPoint.Size.y, v.SpawnPoint.Size.z, v.SpawnPoint.Color.r, v.SpawnPoint.Color.g, v.SpawnPoint.Color.b, 100, false, true, 2, false, false, false, false)	
				DrawMarker(v.DeletePoint.Marker, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.DeletePoint.Size.x, v.DeletePoint.Size.y, v.DeletePoint.Size.z, v.DeletePoint.Color.r, v.DeletePoint.Color.g, v.DeletePoint.Color.b, 100, false, true, 2, false, false, false, false)	
			end		
		end			
		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			for k,v in pairs(Config.GaragesMecano) do
				if(GetDistanceBetweenCoords(coords, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, true) < Config.DrawDistance) then		
					DrawMarker(v.SpawnPoint.Marker, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.SpawnPoint.Size.x, v.SpawnPoint.Size.y, v.SpawnPoint.Size.z, v.SpawnPoint.Color.r, v.SpawnPoint.Color.g, v.SpawnPoint.Color.b, 100, false, true, 2, false, false, false, false)	
					DrawMarker(v.DeletePoint.Marker, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.DeletePoint.Size.x, v.DeletePoint.Size.y, v.DeletePoint.Size.z, v.DeletePoint.Color.r, v.DeletePoint.Color.g, v.DeletePoint.Color.b, 100, false, true, 2, false, false, false, false)	
				end		
			end
		end
	end
end)
-- Fin affichage markers

-- Activer le menu quand player dedans
Citizen.CreateThread(function()
	-- local currentZone = 'garage'
	while true do

		Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for _,v in pairs(Config.Garages) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = 'garage'
				this_Garage = v
			end			
			
			if(GetDistanceBetweenCoords(coords, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = 'spawn'
				this_Garage = v
			end
			
			if(GetDistanceBetweenCoords(coords, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = 'delete'
				this_Garage = v
			end
		end		
		
		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			for _,v in pairs(Config.GaragesMecano) do
				if(GetDistanceBetweenCoords(coords, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, true) < 3) then
					isInMarker  = true
					currentZone = 'spawnmecano'
					this_Garage = v
				end
				
				if(GetDistanceBetweenCoords(coords, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, true) < 3) then
					isInMarker  = true
					currentZone = 'deletemecano'
					this_Garage = v
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('eden_garage:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
		-- if not isInMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('eden_garage:hasExitedMarker', LastZone)
		end

	end
end)


-- Fin activer le menu quand player dedans

-- Controle touche
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then

				if CurrentAction == 'garage_action_menu' then
					OpenMenuGarage()
				end
				
				if CurrentAction == 'garage_spawn' then
					ListVehiclesMenu()
				end
				
				if CurrentAction == 'garage_delete' then
					StockVehicleMenu()
				end
				
				if CurrentAction == 'garagemecano_spawn' then
					ListVehiclesFourriereMenu()
				end
				
				if CurrentAction == 'garagemecano_delete' then
					StockVehicleFourriereMenu()
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()

			end
		end
	end
end)
-- Fin controle touche
function dump(o, nb)
  if nb == nil then
    nb = 0
  end
   if type(o) == 'table' then
      local s = ''
      for i = 1, nb + 1, 1 do
        s = s .. "    "
      end
      s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
          for i = 1, nb, 1 do
            s = s .. "    "
          end
         s = s .. '['..k..'] = ' .. dump(v, nb + 1) .. ',\n'
      end
      for i = 1, nb, 1 do
        s = s .. "    "
      end
      return s .. '}'
   else
      return tostring(o)
   end
end