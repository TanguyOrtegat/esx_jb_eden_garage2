dependency 'ft_libs'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
	'config.lua',
}
client_script {
	'client.lua',
	'config.lua',
}
