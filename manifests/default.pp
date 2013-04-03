exec { "apt-update":
	command => "/usr/bin/apt-get update"
}

class { 'lamp':
	require => Exec['apt-update']
}

class { 'processmaker':
	require => Class['lamp']
}

class { 'tools': 
	require => Class['processmaker']
}

exec {'restart-apache':
	command => '/etc/init.d/apache2 restart',
	require => Class['tools']
}