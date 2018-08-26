ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehicles', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicules, {vehicle = vehicle, state = v.state, fourrieremecano = v.fourrieremecano})
		end
		cb(vehicules)
	end)
end)
-- Fin --Recupere les véhicules$

--Recupere les véhicules
ESX.RegisterServerCallback('eden_garage:getVehiclesMecano', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = {}

	MySQL.Async.fetchAll("select * from owned_vehicles inner join characters on owned_vehicles.owner = characters.identifier where fourrieremecano=@fourrieremecano",{['@fourrieremecano'] = true}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicules, {vehicle = vehicle, state = v.state, fourrieremecano = v.fourrieremecano, firstname = v.firstname, lastname = v.lastname})
		end
		cb(vehicules)
	end)
end)
-- Fin --Recupere les véhicules

--Stock les véhicules
ESX.RegisterServerCallback('eden_garage:stockv',function(source,cb, vehicleProps)
	local isFound = false
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate

	
	for _,v in pairs(vehicules) do
		if(plate == v.plate)then
			local idveh = v.id
			local vehprop = json.encode(vehicleProps)
			MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE id=@id",{['@vehprop'] = vehprop, ['@id'] = v.id})
			isFound = true
			break
		end		
	end
	cb(isFound)
end)
--Fin stock les vehicules

ESX.RegisterServerCallback('eden_garage:stockvmecano',function(source,cb, vehicleProps)
	local plate = vehicleProps.plate
	
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{}, function(result) 
		-- for k,v in pairs(result) do
		local isFound = false
		for i=1, #result,1 do
			local vehicle = json.decode(result[i].vehicle)

			local vehicleplate = vehicle.plate
			if (plate == vehicleplate) then
				local vehprop = json.encode(vehicleProps)
				
				MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle =@vehprop WHERE id=@id",{['@vehprop'] = vehprop, ['@id'] = result[i].id})
				isFound = true
				break
			end
		end
		cb(isFound)
	end)
end)

--Change le state du véhicule
RegisterServerEvent('eden_garage:modifystate')
AddEventHandler('eden_garage:modifystate', function(vehicleProps, state)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate
	local state = state

	for _,v in pairs(vehicules) do
		if(plate == v.plate)then
			local idveh = v.id
			MySQL.Sync.execute("UPDATE owned_vehicles SET state =@state WHERE id=@id",{['@state'] = state , ['@id'] = v.id})
			break
		end		
	end
end)	
--Fin change le state du véhicule

RegisterServerEvent('eden_garage:ChangeStateFromFourriereMecano')
AddEventHandler('eden_garage:ChangeStateFromFourriereMecano', function(vehicleProps, fourrieremecano)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate
	local fourrieremecano = fourrieremecano
	print(fourrieremecano)
	
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{}, function(result) 
		for i=1, #result,1 do
			local vehicle = json.decode(result[i].vehicle)
			local vehicleplate = vehicle.plate
			if (plate == vehicleplate) then				
				local idveh = result[i].id
				MySQL.Sync.execute("UPDATE owned_vehicles SET fourrieremecano =@fourrieremecano WHERE id=@id",{['@fourrieremecano'] = fourrieremecano , ['@id'] = idveh})
				break
			end
		end
	end)
end)






--Fonction qui récupere les plates

-- Fin Fonction qui récupere les plates

ESX.RegisterServerCallback('eden_garage:getOutVehicles',function(source, cb)	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier AND state=false",{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicules, {vehicle =vehicle, fourrieremecano = v.fourrieremecano})
		end
		cb(vehicules)
	end)
end)

--Foonction qui check l'argent
ESX.RegisterServerCallback('eden_garage:checkMoney', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.get('money') >= Config.Price then
		cb(true)
	else
		cb(false)
	end

end)
--Fin Foonction qui check l'argent

--fonction qui retire argent
RegisterServerEvent('eden_garage:pay')
AddEventHandler('eden_garage:pay', function()

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeMoney(Config.Price)

	TriggerClientEvent('esx:showNotification', source, 'Vous avez payé ' .. Config.Price)

end)
--Fin fonction qui retire argent


--Recupere les vehicules
function getPlayerVehicles(identifier)
	
	local vehicles = {}
	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = identifier})	
	for _,v in pairs(data) do
		local vehicle = json.decode(v.vehicle)
		table.insert(vehicles, {id = v.id, plate = vehicle.plate})
	end
	return vehicles
end
--Fin Recupere les vehicules

--Debug
RegisterServerEvent('eden_garage:debug')
AddEventHandler('eden_garage:debug', function(var)
	print(to_string(var))
end)

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end
--Fin Debug


-- Fonction qui change les etats sorti en rentré lors d'un restart
AddEventHandler('onMySQLReady', function()

	MySQL.Sync.execute("UPDATE owned_vehicles SET state=true WHERE state=false", {})

end)
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