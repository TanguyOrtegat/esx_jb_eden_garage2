resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX JB Eden Garage'

dependencies {
	'es_extended',
	'ft_libs'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'esx_jb_eden_garage2_sv.lua',
	'version.lua'
}

client_scripts {
	'config.lua',
	'esx_jb_eden_garage2_cl.lua'
}
