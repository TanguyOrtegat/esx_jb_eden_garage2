local carInstance = {}

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
	local elements, vehiclePropsList = {}, {}

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)
		if not table.empty(vehicles) then
			for k,v in ipairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				local vehicleHash = vehicleProps.model
				local vehicleName, vehicleLabel

				if v.vehiclename == 'voiture' then
					vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
				else
					vehicleName = v.vehiclename
				end

				if v.fourrieremecano then
					vehicleLabel = vehicleName..': Fourrière externe'
				elseif v.state then
					vehicleLabel = vehicleName..': Rentré'
				else
					vehicleLabel = vehicleName..': Sortie'
				end

				table.insert(elements, {
					label = vehicleLabel,
					vehicleName = vehicleName,
					state = v.state,
					plate = vehicleProps.plate,
					fourrieremecano = v.fourrieremecano,
				})
			end
		else
			table.insert(elements, {label = "Pas de voitures dans le garage"})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_vehicle', {
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			local vehicleProps = vehiclePropsList[data.current.plate]

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
				title    =  data.current.vehicleName,
				align    = 'top-left',
				elements = {
					{label ="Sortir la voiture" , value = 'get_vehicle_out'},
					{label ="Renommer la voiture" , value = 'rename_vehicle'}
			}}, function(data2, menu2)
				if data2.current.value == "get_vehicle_out" then
					if data.current.fourrieremecano then
						TriggerEvent('esx:showNotification', 'Votre véhicule est dans la fourrieremecano')
					elseif data.current.state then
						menu.close()
						menu2.close()
						SpawnVehicle(vehicleProps, garage, KindOfVehicle)
					else
						TriggerEvent('esx:showNotification', 'Votre véhicule est déjà sorti')
					end
				elseif data2.current.value == "rename_vehicle" then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_vehicle', {
						title = 'Nom du véhicule souhaité'
					}, function(data3, menu3)
						if data3.value ~= nil or data3.value ~= "" or data3.value ~= " " then
							TriggerServerEvent('eden_garage:renamevehicle', data.current.plate, data3.value)
						else
							ESX.ShowNotification("Le nom du véhicule ne peut pas être vide")
						end
						menu3.close()
					end, function(data3, menu3)
						menu3.close()
					end)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, KindOfVehicle)
end
-- Fin Afficher les listes des vehicules

-- Afficher les listes des vehicules de fourriere
function ListVehiclesFourriereMenu(garage)
	local elements, vehiclePropsList = {}, {}

	ESX.TriggerServerCallback('eden_garage:getVehiclesMecano', function(vehicles)

		for k,v in ipairs(vehicles) do
			local vehicleProps = json.decode(v.vehicle)
			vehiclePropsList[vehicleProps.plate] = vehicleProps
			local vehicleHash = vehicleProps.model
			local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)

			table.insert(elements, {
				label = ('%s | %s %s'):format(vehicleName, v.firstname, v.lastname),
				plate = vehicleProps.plate
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_vehicle_mecano', {
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			local vehicleProps = vehiclePropsList[data.current.plate]
			menu.close()
			SpawnVehicleMecano(vehicleProps, garage)
			TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicleProps, false)
		end, function(data, menu)
			menu.close()
		end)

	end)
end
-- Fin Afficher les listes des vehicules de fourriere


-- Fonction qui permet de rentrer un vehicule
function StockVehicleMenu(KindOfVehicle)
	local playerPed  = PlayerPedId()
	if IsPedInAnyVehicle(playerPed,  false) then
		local vehicle =GetVehiclePedIsIn(playerPed,false)
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(vehicle)
			if GotTrailer then
				local trailerProps  = ESX.Game.GetVehicleProperties(TrailerHandle)
				ESX.TriggerServerCallback('eden_garage:stockv',function(valid)
					if(valid) then
						for k,v in pairs (carInstance) do
							if ESX.Math.Trim(v.plate) == ESX.Math.Trim(trailerProps.plate) then
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
							if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
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
	local playerPed  = PlayerPedId()
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
			TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
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
			TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
		end)
	TriggerServerEvent('eden_garage:ChangeStateFromFourriereMecano', vehicle, false)
end
--Fin fonction pour spawn vehicule fourriere mecano

function ReturnVehicleMenu(garage, KindOfVehicle)

	ESX.TriggerServerCallback('eden_garage:getOutVehicles', function(vehicles)
		local elements, vehiclePropsList = {}, {}

		if not table.empty(vehicles) then
			for k,v in ipairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				local vehicleHash = vehicleProps.model
				local vehicleName, vehicleLabel

				if v.vehiclename == 'voiture' then
					vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
				else
					vehicleName = v.vehiclename
				end

				if v.fourrieremecano then
					vehicleLabel = vehicleName..': Fourrière externe'
					table.insert(elements, {label = vehicleLabel, action = 'fourrieremecano'})
				else
					vehicleLabel = vehicleName..': Sortie'
					table.insert(elements, {
						label = vehicleLabel,
						plate = vehicleProps.plate,
						action = 'store'
					})
				end
			end
		else
			table.insert(elements, {label = "Pas de véhicule a sortir", action = 'nothing'})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_vehicle', {
			title    = 'Garage',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local vehicleProps = vehiclePropsList[data.current.plate]

			if data.current.action == 'fourrieremecano' then
				ESX.ShowNotification("Va voir la police ou mecano pour savoir comment recuperer ton véhicule.")
			elseif data.current.action == 'store' then
				local doesVehicleExist = false

				for k,v in pairs(carInstance) do
					if ESX.Math.Trim(v.plate) == ESX.Math.Trim(data.current.plate) then
						if DoesEntityExist(v.vehicleentity) then
							doesVehicleExist = true
						else
							table.remove(carInstance, k)
							doesVehicleExist = false
						end
					end
				end

				if not doesVehicleExist then
					ESX.TriggerServerCallback('eden_garage:checkMoney', function(hasEnoughMoney)
						if hasEnoughMoney then
							menu.close()
							SpawnVehicle(vehicleProps, garage, KindOfVehicle)
						else
							ESX.ShowNotification('Vous n\'avez pas assez d\'argent')
						end
					end)
				else
					ESX.ShowNotification("Vous ne pouvez pas sortir ce véhicule. Allez la chercher!")
				end
			end
		end, function(data, menu)
			menu.close()
		end)
	end, KindOfVehicle)

end

function exitmarker()
	ESX.UI.Menu.CloseAll()
end

RegisterNetEvent("ft_libs:OnClientReady")
AddEventHandler('ft_libs:OnClientReady', function()
	for k,v in pairs (Config.Garages) do
		exports.ft_libs:AddArea("esx_eden_garage_area_"..k.."_garage", {
			marker = {
				type = v.Marker.t,
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
						if IsControlJustReleased(0, 38) and IsInputDisabled(0) and not IsPedInAnyVehicle(PlayerPedId()) then
							OpenMenuGarage(v, "personal")
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
				type = v.SpawnPoint.Marker.t,
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
						if IsControlJustReleased(0, 38) and IsInputDisabled(0) and not IsPedInAnyVehicle(PlayerPedId()) then
							ListVehiclesMenu(v, "personal")
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
				type = v.DeletePoint.Marker.t,
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
						if IsControlJustReleased(0, 38) and IsInputDisabled(0) then
							StockVehicleMenu("personal")
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
				type = v.SpawnPoint.Marker.t,
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
						if IsControlJustReleased(0, 38) and IsInputDisabled(0) and not IsPedInAnyVehicle(PlayerPedId()) then
							ListVehiclesFourriereMenu(v)
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
				type = v.DeletePoint.Marker.t,
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
						if IsControlJustReleased(0, 38) and IsInputDisabled(0) then
							StockVehicleFourriereMenu()
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

function table.empty(parsedTable)
	for _, _ in pairs(parsedTable) do
		return false
	end

	return true
end

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


--- garage societe

RegisterNetEvent('esx_eden_garage:ListVehiclesMenu')
AddEventHandler('esx_eden_garage:ListVehiclesMenu', function(garage, society)
	if not IsPedInAnyVehicle(PlayerPedId()) then
		ListVehiclesMenu(garage, society)
	end
end)

RegisterNetEvent('esx_eden_garage:OpenMenuGarage')
AddEventHandler('esx_eden_garage:OpenMenuGarage', function(garage, society)
	if not IsPedInAnyVehicle(PlayerPedId()) then
		OpenMenuGarage(garage, society)
	end
end)

RegisterNetEvent('esx_eden_garage:StockVehicleMenu')
AddEventHandler('esx_eden_garage:StockVehicleMenu', function(society)
	StockVehicleMenu(society)
end)
