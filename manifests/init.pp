# Class: tigervnc
# ===========================
#
# Main class that includes all other classes for the tigervnc module.
#
# @param package_ensure Whether to install the tigervnc package, and/or what version. Values: 'present', 'latest', or a specific version number. Default value: present.
# @param package_name Specifies the name of the package to install. Default value: 'tigervnc'.
# @param service_enable Whether to enable the tigervnc service at boot. Default value: true.
# @param service_ensure Whether the tigervnc service should be running. Default value: 'running'.
# @param service_name Specifies the name of the service to manage. Default value: 'tigervnc'.
#
class tigervnc (
  String                     $package_ensure = 'present',
  String                     $package_name   = 'tigervnc',
  Boolean                    $service_enable = true,
  Enum['running', 'stopped'] $service_ensure = 'running',
  String                     $service_name   = 'tigervnc',
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
