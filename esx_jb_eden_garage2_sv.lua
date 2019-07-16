ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehicles', function(source, cb, KindOfVehicle)
	local vehicules = {}
	local identifier = ""

	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = GetPlayerIdentifiers(source)[1]
	end

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
		['@identifier'] = identifier
	}, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules$

--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehiclesMecano', function(source, cb)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles INNER JOIN characters ON owned_vehicles.owner = characters.identifier WHERE fourrieremecano = TRUE", {}, function(result)
		cb(result)
	end)
end)
-- Fin --Recupere les véhicules

--Stock les véhicules
ESX.RegisterServerCallback('eden_garage:stockv',function(source,cb, vehicleProps, KindOfVehicle)
	local identifier = ""
	local _source = source
	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = GetPlayerIdentifiers(_source)[1]
	end
	local vehplate = vehicleProps.plate
	local vehiclemodel = vehicleProps.model
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles where plate=@plate and owner=@identifier",{['@plate'] = vehplate, ['@identifier'] = identifier}, function(result)
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
				DropPlayer(_source, "Tu es kick du serveur, voilà ce qu'il se passe quand on essaye de cheater.")
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
	local plate = ESX.Math.Trim(vehicleProps.plate)
	local vehiclemodel = vehicleProps.model
	local identifier = GetPlayerIdentifiers(_source)[1]
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles where plate=@plate",{['@plate'] = plate}, function(result)
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
				DropPlayer(_source, "Tu es kick du serveur, voilà ce qu'il se passe quand on essaye de cheater.")
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
AddEventHandler('eden_garage:modifystate', function(plate, state)
	local plate = plate
	MySQL.Async.execute("UPDATE owned_vehicles SET state =@state WHERE plate=@plate",{
		['@state'] = state,
		['@plate'] = plate
	})
end)
--Fin change le state du véhicule

RegisterServerEvent('eden_garage:ChangeStateFromFourriereMecano')
AddEventHandler('eden_garage:ChangeStateFromFourriereMecano', function(vehicleProps, fourrieremecano)
	local _source = source
	local vehicleplate = ESX.Math.Trim(vehicleProps.plate)
	local fourrieremecano = fourrieremecano

	MySQL.Async.execute("UPDATE owned_vehicles SET fourrieremecano =@fourrieremecano WHERE plate=@plate",{
		['@fourrieremecano'] = fourrieremecano,
		['@plate'] = vehicleplate
	})
end)


RegisterServerEvent('eden_garage:renamevehicle')
AddEventHandler('eden_garage:renamevehicle', function(vehicleplate, name)
	local vehicleplate = vehicleplate
	MySQL.Async.execute("UPDATE owned_vehicles SET vehiclename =@vehiclename WHERE plate=@plate",{['@vehiclename'] = name , ['@plate'] = vehicleplate})
end)

ESX.RegisterServerCallback('eden_garage:getOutVehicles',function(source, cb, KindOfVehicle)
	local identifier

	if KindOfVehicle ~= "personal" then
		identifier = KindOfVehicle
	else
		identifier = GetPlayerIdentifiers(source)[1]
	end

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier AND (state = FALSE OR fourrieremecano = TRUE)",{
		['@identifier'] = identifier
	}, function(result)
		cb(result)
	end)
end)

--Foonction qui check l'argent
ESX.RegisterServerCallback('eden_garage:checkMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.get('money') >= Config.Price then
		xPlayer.removeMoney(Config.Price)
		cb(true)
	else
		cb(false)
	end
end)
--Fin Foonction qui check l'argent

-- Fonction qui change les etats sorti en rentré lors d'un restart

if Config.StoreOnServerStart then
	MySQL.ready(function()
		MySQL.Async.execute("UPDATE owned_vehicles SET state=true WHERE state=false", {})
	end)
end

-- Fin Fonction qui change les etats sorti en rentré lors d'un restart