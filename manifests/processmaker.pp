# Class: ProcessMaker
# Author: Yamil Urbina <hello@yamilurbina.com>
# Description: Get the latest ProcessMaker version,
# enable the PM developer tools (gulliver),
# and have ProcessMaker working out-of-the-box
class processmaker {

	#  Make sure wget is installed
	package { 'wget': ensure => installed }

	# Get ProcessMaker and extract it
	exec {
		'get_processmaker':
			command => "/usr/bin/wget -P /opt http://ufpr.dl.sourceforge.net/project/processmaker/ProcessMaker/2.0/2.0.45/processmaker-2.0.45.tar.gz",
			creates => "/opt/processmaker-2.0.45.tar.gz",
			timeout => '0',
			require => Package['wget'];
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

	# index.html permissions
	file { '/opt/processmaker/workflow/public_html/index.html':
		ensure => present,
		mode => 0777,
		require => Exec['extract_processmaker'];
	}

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
		require => Exec['extract_processmaker'];
	}

	# Disable the default apache site
	exec { "disable-apache-default":
		command => '/usr/sbin/a2dissite default',
		require => Exec['extract_processmaker'];
	}

	# Enable the pmos file for apache
	exec { "enable-pmos":
		command => '/usr/sbin/a2ensite pmos',
		require => [ Exec['disable-apache-default'], File['/etc/apache2/sites-available/pmos'] ];
	}

	# Enable modules for apache and processmaker
	$apache_modules = ['rewrite','expires','deflate','vhost_alias', 'alias']

	define enable_modules() {
		exec { $name:
			command => "/usr/sbin/a2enmod ${name}",
			require => [ Exec['disable-apache-default'], File['/etc/apache2/sites-available/pmos'] ];
		}
	}

	# Modules up!
	enable_modules { $apache_modules: }
}