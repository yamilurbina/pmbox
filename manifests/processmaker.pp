# Class: ProcessMaker
# Author: Yamil Urbina <hello@yamilurbina.com>
# Description: Get the latest ProcessMaker version,
# enable the PM developer tools (gulliver),
# and have ProcessMaker working out-of-the-box
class processmaker {

	# Get ProcessMaker and extract it
	exec {
		'get_processmaker':
			command => "/usr/bin/wget -P /opt http://ufpr.dl.sourceforge.net/project/processmaker/ProcessMaker/2.0/2.0.45/processmaker-2.0.45.tar.gz",
			creates => "/opt/processmaker-2.0.45.tar.gz";
		'extract_processmaker':
			cwd => '/opt/',
			command => "/bin/tar xzvf processmaker-2.0.45.tar.gz",
			creates => '/opt/processmaker',
			require => Exec['get_processmaker'];
	}

	# Set folder and file permissions, developer plugin folder and symlinks
	$file_list = [
		'/opt/processmaker/workflow/engine/plugins/',
		'/opt/processmaker/workflow/engine/config/',
		'/opt/processmaker/shared/',
		'/opt/processmaker/workflow/public_html/',
		'/opt/processmaker/workflow/engine/xmlform/',
		'/opt/processmaker/workflow/engine/content/languages/',
		'/opt/processmaker/workflow/engine/js/labels/',
	]

	define filelinks() {
		file { $name:
			ensure => present,
			path   => "${name}",
			mode => 0777,
			recurse => true,
			require => Exec['extract_processmaker'];
		}
	}
	
	# Set permissions for all folders
	filelinks { $file_list: }

	# Gulliver for development
	file { '/opt/processmaker/workflow/engine/gulliver':
		ensure => link,
		target => '/opt/processmaker/gulliver/bin/gulliver',
		require => Exec['extract_processmaker'];
	}

	# Copy the pmos conf file
	file { '/etc/apache2/sites-available/pmos':
		ensure  => present,
		source  => '/vagrant/files/processmaker/pmos',
	}

	# Disable the default apache site
	exec { "disable-apache-default":
		command => '/usr/sbin/a2dissite default',
	}

	# Enable the pmos file for apache
	exec { "enable-pmos":
		command => '/usr/sbin/a2ensite pmos',
		require => [ Exec['disable-apache-default'], File['/etc/apache2/sites-available/pmos'] ];
	}

	# Enable modules for apache and processmaker
	$apache_modules = ['rewrite','expires','deflate','vhost_alias']

	define enable_modules() {
		exec { $name:
			command => "/usr/sbin/a2enmod ${name}",
		}
	}

	# Modules up!
	enable_modules { $apache_modules: }

	# Enable PHP extensions
	$php_extensions = [
		'php5-gd',
		'php5-ldap',
		'php5-curl',
		'php5-cli',
		'php5-mcrypt',
		'php5-pgsql',
		'php5-odbc',
		'php-soap',
	]

	define enable_extensions() {
		package { $name:
			ensure => installed
		}
	}

	# Extensions up
	enable_extensions { $php_extensions: }

	# Finally, set our own php.ini file
    file { '/etc/php5/apache2/php.ini':
      ensure  => present,
      source  => "/vagrant/files/php/php.ini",
      require => Exec['get_processmaker'];
    }
}