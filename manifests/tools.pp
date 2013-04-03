class tools {

	# Install Git and ZSH
	$tools_require = ['git-core', 'curl']
	package { $tools_require: ensure => installed }

	# Install PHPMyAdmin
	exec {
		'get_phpmyadmin':
			command => "/usr/bin/wget -P /var/www http://ufpr.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/3.5.7/phpMyAdmin-3.5.7-english.tar.gz",
			creates => "/var/www/phpMyAdmin-3.5.7-english.tar.gz",
			timeout => '0',
			require => Package[$tools_require];
		'extract_phpmyadmin':
			cwd => '/var/www/',
			command => "/bin/tar xzvf phpMyAdmin-3.5.7-english.tar.gz",
			creates => '/var/www/phpMyAdmin-3.5.7-english',
			require => Exec['get_phpmyadmin'];
	}

	# Rename folder to phpmyadmin
	file { "/var/www/phpmyadmin":
		ensure => directory,
		source => '/var/www/phpMyAdmin-3.5.7-english',
		recurse => true,
		require => Exec['extract_phpmyadmin'];
	}

}