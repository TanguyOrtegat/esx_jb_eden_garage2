ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehicles', function(source, cb, KindOfVehicle, garage_name, vehicle_type)
	local _source = source
	local identifier = ""
	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = ESX.GetPlayerFromId(_source).identifier
	end

	MySQL.Async.fetchAll("SELECT vehicle, vehiclename, pound, `stored`, garage_name FROM owned_vehicles WHERE owner = @identifier and type=@vehicle_type", {
		['@identifier'] = identifier,
		['@vehicle_type'] = vehicle_type
	}, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules$

--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehiclesMecano', function(source, cb)
	MySQL.Async.fetchAll([[SELECT owned_vehicles.*, users.firstname, users.lastname, jobs.label as joblabel FROM owned_vehicles 
		left JOIN users 
		ON owned_vehicles.owner = users.identifier 
		left outer JOIN jobs 
		ON owned_vehicles.owner = jobs.name 
		WHERE pound = TRUE]], { }, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules

--Stock les véhicules
ESX.RegisterServerCallback('eden_garage:stockv',function(source,cb, vehicleProps, KindOfVehicle, garage_name, vehicle_type)
	local identifier = ""
	local _source = source
	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = ESX.GetPlayerFromId(_source).identifier
	end
	local vehplate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model
	MySQL.Async.fetchAll("SELECT vehicle FROM owned_vehicles where plate=@plate and owner=@identifier and type = @vehicle_type",{['@plate'] = vehplate, ['@identifier'] = identifier, ['@vehicle_type'] = vehicle_type}, function(result)
		if result[1] ~= nil then
			local vehprop = json.encode(vehicleProps)
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE plate=@plate",{
					['@vehprop'] = vehprop,
					['@plate'] = vehplate
				}, function(rowsChanged)
					cb(true)
				end)
			else
				TriggerEvent('nb_menuperso:bancheaterplayer', _source)
				print("[esx_eden_garage] player "..identifier..' tried to spawn a vehicle with hash:'..vehiclemodel..". his original vehicle: "..originalvehprops.model)
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)
--Fin stock les vehicules

ESX.RegisterServerCallback('eden_garage:stockvmecano',function(source,cb, vehicleProps)
	local _source = source
	local plate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model
	local identifier = ESX.GetPlayerFromId(_source).identifier
	MySQL.Async.fetchAll("SELECT vehicle FROM owned_vehicles where plate=@plate",{['@plate'] = plate}, function(result)
		if result[1] ~= nil then
			local vehprop = json.encode(vehicleProps)
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE plate=@plate",{
					['@vehprop'] = vehprop,
					['@plate'] = plate
				}, function(rowsChanged)
					cb(true)
				end)
			else
				TriggerEvent('nb_menuperso:bancheaterplayer', _source)
				print("[esx_eden_garage] player "..identifier..' tried to spawn a vehicle with hash:'..vehiclemodel..". his original vehicle: "..originalvehprops.model)
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)

--Change le state du véhicule
RegisterServerEvent('eden_garage:modifystate')
AddEventHandler('eden_garage:modifystate', function(plate, stored)
	MySQL.Async.execute("UPDATE owned_vehicles SET `stored` =@stored WHERE plate=@plate",{
		['@stored'] = stored,
		['@plate'] = plate
	})
end)	
--Fin change le state du véhicule

RegisterServerEvent('eden_garage:ChangeStateFrompound')
AddEventHandler('eden_garage:ChangeStateFrompound', function(vehicleProps, pound)
	local _source = source
	local vehicleplate = vehicleProps.plate
	local pound = pound
	
	MySQL.Async.execute("UPDATE owned_vehicles SET pound =@pound WHERE plate=@plate",{
		['@pound'] = pound,
		['@plate'] = vehicleplate
	})
end)


RegisterServerEvent('eden_garage:renamevehicle')
AddEventHandler('eden_garage:renamevehicle', function(vehicleplate, name)
	MySQL.Async.execute("UPDATE owned_vehicles SET vehiclename =@vehiclename WHERE plate=@plate",{['@vehiclename'] = name , ['@plate'] = vehicleplate})
end)

RegisterServerEvent('esx_eden_garage:MoveGarage')
AddEventHandler('esx_eden_garage:MoveGarage', function(vehicleplate, garage_name)
	MySQL.Async.execute("UPDATE owned_vehicles SET garage_name =@garage_name WHERE plate=@plate",{['@garage_name'] = garage_name , ['@plate'] = vehicleplate})
end)

ESX.RegisterServerCallback('eden_garage:getOutVehicles',function(source, cb, KindOfVehicle, garage_name, vehicle_type)	
	local _source = source
	local identifier = ""
	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = ESX.GetPlayerFromId(_source).identifier
	end

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier AND (`stored` = FALSE OR pound = TRUE) AND garage_name = @garage_name AND type=@vehicle_type",{
		['@identifier'] = identifier,
		['@garage_name'] = garage_name, 
		['@vehicle_type'] = vehicle_type
	}, function(result)
		cb(result)
	end)
end)

--Foonction qui check l'argent
ESX.RegisterServerCallback('eden_garage:checkMoney', function(source, cb, money)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= money then
		xPlayer.removeMoney(money)
		cb(true)
	else
		cb(false)
	end
end)
--Fin Foonction qui check l'argent

-- Fonction qui change les etats sorti en rentré lors d'un restart
if Config.StoreOnServerStart then
	AddEventHandler('onMySQLReady', function()

		MySQL.Async.execute("UPDATE owned_vehicles SET `stored`=true WHERE `stored`=false", {})

	end)
end
-- Fin Fonction qui change les etats sorti en rentré lors d'un restart

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
