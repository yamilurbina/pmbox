class lamp {

	# MySQL first, because yes
	$mysql_require = ['mysql-server', 'libapache2-mod-auth-mysql']
	# Ensure the required packages are there 
	package { $mysql_require: ensure => installed }
	# Set a default password
	exec { 'mysql_password':
		command => '/usr/bin/mysqladmin -u root password processmaker || /bin/true',
		require => Package[$mysql_require]
	}
	# Ensure the service is running
	service { 'mysql':
		ensure    => running,
		enable    => true,
		require   => Package[$mysql_require], 
	}

	# PHP, specifically PHP5
	$php_require = [
		'php5', 
		'php5-mysql', 
		'libapache2-mod-php5', 
		'php5-gd', 
		'php5-ldap', 
		'php5-curl', 
		'php5-cli', 
		'php5-mcrypt',
		'php-soap',
		'php5-pgsql',
		'php5-odbc'
	]
	# Install packages
	package { $php_require: ensure => installed, require => Service['mysql'] }

	# Set our own php.ini file with our own parameters
	file { '/etc/php5/apache2/php.ini':
		ensure  => present,
		source  => "/vagrant/files/php/php.ini",
		owner => root,
		group => root,
		require => Package[$php_require];
	}

	# Apache server
	$apache_require = ['apache2']
	package { $apache_require: ensure => installed, require => Package[$php_require]}

	service { 'apache2' :
		ensure  => running,
		enable  => true,
		require => Package[$apache_require],
	}

}