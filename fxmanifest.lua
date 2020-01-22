fx_version 'adamant'

game 'gta5'

description 'ESX JB Eden Garage'

dependencies {
	'es_extended',
	'ft_libs'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'config.lua',
	'server/main.lua',
	'version.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua',
}
