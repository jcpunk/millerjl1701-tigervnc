# Class: tigervnc
# ===========================
#
# Main class that includes all other classes for the tigervnc module.
#
# @param manage_vncuser_passwords Whether or not to set user vncpasswd files to an initial value.
# @param package_ensure Whether to install the tigervnc package, and/or what version. Values: 'present', 'latest', or a specific version number.
# @param package_name Specifies the name of the package to install.
# @param service_enable Whether to enable the tigervnc service at boot.
# @param service_ensure Whether the tigervnc service should be running.
# @param service_name Specifies the name of the service to manage.
# @param sysconfig_template Specifies the template to use for /etc/sysconfig/vncservers.
# @param user_homedir_path Specifies the path where the user home directories are located.
# @param vncservers Hash of hashes that specifies vncservers and associated properties.
# @param vncuser_default_passwd Default password to use for vnc session passwords.
#
class tigervnc (
  Hash                       $vncservers,
  Boolean                    $manage_vncuser_passwords = true,
  String                     $package_ensure           = 'present',
  String                     $package_name             = 'tigervnc-server',
  Boolean                    $service_enable           = true,
  Enum['running', 'stopped'] $service_ensure           = 'running',
  String                     $service_name             = 'vncserver',
  String                     $sysconfig_template       = 'tigervnc/sysconfig_vncservers.erb',
  Stdlib::Unixpath           $user_homedir_path        = '/home', 
  String                     $vncuser_default_passwd   = 'ChangeMe',
  ) {
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      contain tigervnc::install
      contain tigervnc::config
      contain tigervnc::service

      Class['tigervnc::install']
      -> Class['tigervnc::config']
      ~> Class['tigervnc::service']
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
