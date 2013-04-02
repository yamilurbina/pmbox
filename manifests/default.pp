exec { "apt-update":
	command => "/usr/bin/apt-get update"
}

class { 'lamp':
 	version => 'latest',
	require => Exec['apt-update']
}

class { 'processmaker':
	require => Class['lamp']
}

exec {'restart-apache':
	command => '/etc/init.d/apache2 restart',
	require => Class['processmaker']
}

class { 'git': 
	require => Exec['restart-apache']
}