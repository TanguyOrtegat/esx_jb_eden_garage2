dependency 'ft_libs'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'esx_jb_eden_garage2_sv.lua',
	'config.lua',
	'version.lua',
}
client_script {
	'esx_jb_eden_garage2_cl.lua',
	'config.lua',
}
