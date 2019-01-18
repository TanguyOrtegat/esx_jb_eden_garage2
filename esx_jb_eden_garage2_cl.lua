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

local GUI                       = {}
GUI.Time                        = 0
local carInstance 				= {}

-- Fin Local

-- Init ESX
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
		ESX = obj 
		end)
	end
end)

--Fonction Menu

function OpenMenuGarage(garage, KindOfVehicle)
	ESX.UI.Menu.CloseAll()

	local elements = {
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
			if(data.current.value == 'return_vehicle') then
				ReturnVehicleMenu(garage, KindOfVehicle)
			end
		end,
		function(data, menu)
			menu.close()
		end
	)	
end
-- Afficher les listes des vehicules
function ListVehiclesMenu(garage, KindOfVehicle)
	local elements = {}
	local vehicleName = ""
	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)
		if not table.empty(vehicles) then
			for _,v in pairs(vehicles) do
				v.vehicle = json.decode(v.vehicle)
				local hashVehicule = v.vehicle.model		
				if v.vehiclename == 'voiture' then
					vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
				else
					vehicleName = v.vehiclename
				end
				local labelvehicle
				if(v.fourrieremecano)then
					labelvehicle = vehicleName..': Fourrière externe'
				elseif (v.state)  then
					labelvehicle = vehicleName..': Rentré'
				else
					labelvehicle = vehicleName..': Sortie'
				end	
				table.insert(elements, {label =labelvehicle , value = v})
				
			end
		else
			table.insert(elements, {label ="Pas de voitures dans le garage" , value = nil})
		end
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			local elem = {}
			table.insert(elem, {label ="Sortir la voiture" , value = 'get_vehicle_out'})
			table.insert(elem, {label ="Renommer la voiture" , value = 'rename_vehicle'})
			if data.current.value.vehiclename == 'voiture' then
				vehicleName = GetDisplayNameFromVehicleModel(data.current.value.vehicle.model)
			else
				vehicleName = data.current.value.vehiclename
			end
			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'vehicle_menu',
				{
					title    =  vehicleName,
					align    = 'top-left',
					elements = elem,
				},
				function(data2, menu2)
					if data2.current.value == "get_vehicle_out" then
                        if (data.current.value.fourrieremecano) then
                            TriggerEvent('esx:showNotification', 'Votre véhicule est dans la fourrieremecano')
                        elseif (data.current.value.state) then
                            menu.close()
                            menu2.close()
                            SpawnVehicle(data.current.value.vehicle, garage, KindOfVehicle)
                        else
                            TriggerEvent('esx:showNotification', 'Votre véhicule est déjà sorti')
                        end
					elseif data2.current.value == "rename_vehicle" then
						AddTextEntry('FMMC_KEY_TIP8', "Nom du véhicule souhaité")
						DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "", "", "", "", "", 64)
						while (UpdateOnscreenKeyboard() == 0) do
								DisableAllControlActions(0);
								Wait(0);
						end
						if (GetOnscreenKeyboardResult()) then
							local name = GetOnscreenKeyboardResult()
							TriggerServerEvent('eden_garage:renamevehicle', data.current.value.plate, name)
						end
					end
				end,
				function(data2, menu2)
					menu2.close()
				end
			)
		end,
		function(data, menu)
			menu.close()
		end
	)
	end, KindOfVehicle)
end
-- Fin Afficher les listes des vehicules

-- Afficher les listes des vehicules de fourriere
function ListVehiclesFourriereMenu(garage)
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehiclesMecano', function(vehicles)

		for _,v in pairs(vehicles) do
			v.vehicle = json.decode(v.vehicle)
			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)

			table.insert(elements, {label =vehicleName.." | "..v.firstname.." "..v.lastname , value = v})
			
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle_mecano',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			menu.close()
			SpawnVehicleMecano(data.current.value.vehicle, garage)
			TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', data.current.value.vehicle, false)
		end,
		function(data, menu)
			menu.close()
		end
	)	
	end)
end
-- Fin Afficher les listes des vehicules de fourriere


-- Fonction qui permet de rentrer un vehicule
function StockVehicleMenu(KindOfVehicle)
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then
		local vehicle =GetVehiclePedIsIn(playerPed,false)
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
			if GotTrailer then
				local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
				ESX.TriggerServerCallback('eden_garage:stockv',function(valid)
					if(valid) then
						for k,v in pairs (carInstance) do
							if v.plate == trailerplate then
								table.remove(carInstance, k)
							end
						end
						DeleteEntity(TrailerHandle)
						TriggerServerEvent('eden_garage:modifystate', trailerProps.plate, true)
						TriggerEvent('esx:showNotification', 'Votre remorque est dans le garage')
					else
						TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
					end
				end,trailerProps, KindOfVehicle)
			else
				local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
				ESX.TriggerServerCallback('eden_garage:stockv',function(valid)
					if(valid) then
						for k,v in pairs (carInstance) do
							if v.plate == vehicleplate then
								table.remove(carInstance, k)
							end
						end
						DeleteEntity(vehicle)
						TriggerServerEvent('eden_garage:modifystate', vehicleProps.plate, true)
						TriggerEvent('esx:showNotification', 'Votre véhicule est dans le garage')
					else
						TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule')
					end
				end,vehicleProps, KindOfVehicle)
			end
		else
			TriggerEvent('esx:showNotification', 'Vous etes pas conducteur du vehicule')
		end
	else
		TriggerEvent('esx:showNotification', 'Il n\' y a pas de vehicule à rentrer')
	end
end
-- Fin fonction qui permet de rentrer un vehicule 

-- Fonction qui permet de rentrer un vehicule dans fourriere
function StockVehicleFourriereMenu()
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then
		local vehicle =GetVehiclePedIsIn(playerPed,false)
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
			if GotTrailer then
				local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
				ESX.TriggerServerCallback('eden_garage:stockvmecano',function(valid)
					if(valid) then
						DeleteVehicle(TrailerHandle)
						TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', trailerProps, true)
						TriggerEvent('esx:showNotification', 'La remorque est rentré dans la fourrière')
					else
						TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker cette remorque dans la fourrière')
					end
				end,trailerProps)
			else
				local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
				ESX.TriggerServerCallback('eden_garage:stockvmecano',function(valid)
					if(valid) then
						DeleteVehicle(vehicle)
						TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicleProps, true)
						TriggerEvent('esx:showNotification', 'Le véhicule est rentré dans la fourrière')
					else
						TriggerEvent('esx:showNotification', 'Vous ne pouvez pas stocker ce véhicule dans la fourrière')
					end
				end,vehicleProps)
			end
		else
			TriggerEvent('esx:showNotification', 'Vous etes pas conducteur du vehicule')
		end
	else
		TriggerEvent('esx:showNotification', 'Il n\' y a pas de vehicule à rentrer')
	end
end
-- Fin fonction qui permet de rentrer un vehicule dans fourriere
--Fin fonction Menu


--Fonction pour spawn vehicule
function SpawnVehicle(vehicle, garage, KindOfVehicle)
	ESX.Game.SpawnVehicle(vehicle.model, {
		x = garage.SpawnPoint.Pos.x,
		y = garage.SpawnPoint.Pos.y,
		z = garage.SpawnPoint.Pos.z + 1											
		},garage.SpawnPoint.Heading, function(callback_vehicle)
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
			local carplate = GetVehicleNumberPlateText(callback_vehicle)
			table.insert(carInstance, {vehicleentity = callback_vehicle, plate = carplate})
			if KindOfVehicle == 'brewer' or KindOfVehicle == 'joaillerie' or KindOfVehicle == 'fermier' or KindOfVehicle == 'fisherman' or KindOfVehicle == 'fuel' or KindOfVehicle == 'johnson' or KindOfVehicle == 'miner' or KindOfVehicle == 'reporter' or KindOfVehicle == 'vignerons' or KindOfVehicle == 'tabac' then
				TriggerEvent('esx_jobs1:addplate', carplate)
				TriggerEvent('esx_jobs2:addplate', carplate)
			end	
		end)
	TriggerServerEvent('eden_garage:modifystate', vehicle.plate, false)
end
--Fin fonction pour spawn vehicule

--Fonction pour spawn vehicule fourriere mecano
function SpawnVehicleMecano(vehicle, garage)
	ESX.Game.SpawnVehicle(vehicle.model, {
		x = garage.SpawnPoint.Pos.x,
		y = garage.SpawnPoint.Pos.y,
		z = garage.SpawnPoint.Pos.z + 1											
		},garage.SpawnPoint.Heading, function(callback_vehicle)
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		end)
	TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicle, false)
end
--Fin fonction pour spawn vehicule fourriere mecano

function ReturnVehicleMenu(garage, KindOfVehicle)

	ESX.TriggerServerCallback('eden_garage:getOutVehicles', function(vehicles)
		local elements = {}
		if not table.empty(vehicles) then
			for _,v in pairs(vehicles) do
				v.vehicle = json.decode(v.vehicle)
				local hashVehicule = v.vehicle.model
				local vehicleName
				local labelvehicle		
				if v.vehiclename == 'voiture' then
					vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
				else
					vehicleName = v.vehiclename
				end
				
				if v.fourrieremecano then
					labelvehicle = vehicleName..': Fourrière externe'
					table.insert(elements, {label =labelvehicle , value = 'fourrieremecano'})
				else
					labelvehicle = vehicleName..': Sortie'
					table.insert(elements, {label =labelvehicle , value = v.vehicle})
				end
			end
		else
			table.insert(elements, {label ="Pas de véhicule a sortir" , value = nil})
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
				ESX.ShowNotification("Va voir la police ou mecano pour savoir comment recuperer ton véhicule.")
			elseif data.current.value ~= nil then
				local iscaronearth = false
				for k,v in pairs (carInstance) do
					if v.plate == data.current.value.plate then
						if DoesEntityExist(v.vehicleentity) then
							iscaronearth = true
						else
							table.remove(carInstance, k)
							iscaronearth = false
						end
					end
				end
				if not iscaronearth then
					ESX.TriggerServerCallback('eden_garage:checkMoney', function(hasEnoughMoney)
						if hasEnoughMoney then
							menu.close()
							SpawnVehicle(data.current.value, garage, KindOfVehicle)
						else
							ESX.ShowNotification('Vous n\'avez pas assez d\'argent')						
						end
					end)
				else
					ESX.ShowNotification("Vous ne pouvez pas sortir ce véhicule. Allez la chercher!")
				end				
			end
		end,
		function(data, menu)
			menu.close()
		end
		)
	end, KindOfVehicle)
end

function exitmarker()
	ESX.UI.Menu.CloseAll()
end

RegisterNetEvent("ft_libs:OnClientReady")
AddEventHandler('ft_libs:OnClientReady', function()
	for k,v in pairs (Config.Garages) do
		this_Garage = v
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_garage", {
			marker = {
				weight = v.Marker.w,
				height = v.Marker.h,
				red = v.Marker.r,
				green = v.Marker.g,
				blue = v.Marker.b,
			},
			trigger = {
				weight = v.Marker.w,
				active = {
					callback = function()
						exports.ft_libs:HelpPromt(v.HelpPrompt)
						if IsControlJustPressed(1, 38) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
							v.Functionmenu(v, "personal")
							GUI.Time = GetGameTimer()
						end
					end,
				},
				exit = {
					callback = exitmarker
				},
			},
			blip = {
				text = v.Name,
				colorId = Config.Blip.color,
				imageId = Config.Blip.sprite,
			},
			locations = {
				v.Pos				
			},
		})
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_spawnpoint", {
			marker = {
				weight = v.SpawnPoint.Marker.w,
				height = v.SpawnPoint.Marker.h,
				red = v.SpawnPoint.Marker.r,
				green = v.SpawnPoint.Marker.g,
				blue = v.SpawnPoint.Marker.b,
			},
			trigger = {
				weight = v.SpawnPoint.Marker.w,
				active = {
					callback = function()
						exports.ft_libs:HelpPromt(v.SpawnPoint.HelpPrompt)
						if IsControlJustPressed(1, 38) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
							v.SpawnPoint.Functionmenu(v, "personal")
							GUI.Time = GetGameTimer()
						end
					end,
				},
				exit = {
					callback = exitmarker
				},
			},
			locations = {
				{
					x = v.SpawnPoint.Pos.x,
					y = v.SpawnPoint.Pos.y,
					z = v.SpawnPoint.Pos.z,
				},
			},
		})
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_deletepoint", {
			marker = {
				weight = v.DeletePoint.Marker.w,
				height = v.DeletePoint.Marker.h,
				red = v.DeletePoint.Marker.r,
				green = v.DeletePoint.Marker.g,
				blue = v.DeletePoint.Marker.b,
			},
			trigger = {
				weight = v.DeletePoint.Marker.w,
				active = {
					callback = function()
						exports.ft_libs:HelpPromt(v.DeletePoint.HelpPrompt)
						if IsControlJustPressed(1, 38) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
							v.DeletePoint.Functionmenu("personal")
							GUI.Time = GetGameTimer()
						end
					end,
				},
				exit = {
					callback = exitmarker
				},
			},
			locations = {
				{
					x = v.DeletePoint.Pos.x,
					y = v.DeletePoint.Pos.y,
					z = v.DeletePoint.Pos.z,
				},
			},
		})
	end
	
	for k,v in pairs (Config.GaragesMecano) do
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_mecanospawnpoint", {
			enable = false,
			marker = {
				weight = v.SpawnPoint.Marker.w,
				height = v.SpawnPoint.Marker.h,
				red = v.SpawnPoint.Marker.r,
				green = v.SpawnPoint.Marker.g,
				blue = v.SpawnPoint.Marker.b,
			},
			trigger = {
				weight = v.SpawnPoint.Marker.w,
				active = {
					callback = function()
						exports.ft_libs:HelpPromt(v.SpawnPoint.HelpPrompt)
						if IsControlJustPressed(1, 38) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
							v.SpawnPoint.Functionmenu(v)
							GUI.Time = GetGameTimer()
						end
					end,
				},
				exit = {
					callback = exitmarker
				},
			},
			blip = {
				text = v.Name,
				colorId = Config.MecanoBlip.color,
				imageId = Config.MecanoBlip.sprite,
			},
			locations = {
				{
					x = v.SpawnPoint.Pos.x,
					y = v.SpawnPoint.Pos.y,
					z = v.SpawnPoint.Pos.z,
				},
			},
		})
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_mecanodeletepoint", {
			enable = false,
			marker = {
				weight = v.DeletePoint.Marker.w,
				height = v.DeletePoint.Marker.h,
				red = v.DeletePoint.Marker.r,
				green = v.DeletePoint.Marker.g,
				blue = v.DeletePoint.Marker.b,
			},
			trigger = {
				weight = v.DeletePoint.Marker.w,
				active = {
					callback = function()
						exports.ft_libs:HelpPromt(v.DeletePoint.HelpPrompt)
						if IsControlJustPressed(1, 38) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
							v.DeletePoint.Functionmenu()
							GUI.Time = GetGameTimer()
						end
					end,
				},
				exit = {
					callback = exitmarker
				},
			},
			locations = {
				{
					x = v.DeletePoint.Pos.x,
					y = v.DeletePoint.Pos.y,
					z = v.DeletePoint.Pos.z,
				},
			},
		})
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

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

--- garage societe

RegisterNetEvent('esx_eden_garage:ListVehiclesMenu')
AddEventHandler('esx_eden_garage:ListVehiclesMenu', function(garage, society)
	ListVehiclesMenu(garage, society)
end)

RegisterNetEvent('esx_eden_garage:OpenMenuGarage')
AddEventHandler('esx_eden_garage:OpenMenuGarage', function(garage, society)
	OpenMenuGarage(garage, society)
end)

RegisterNetEvent('esx_eden_garage:StockVehicleMenu')
AddEventHandler('esx_eden_garage:StockVehicleMenu', function(society)
	StockVehicleMenu(society)
end)
