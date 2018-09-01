# @api private
#
# This class is meant to be called from tigervnc to manage the vncserver service.
#
class tigervnc::service {
  assert_private('tigervnc::service is a private class')

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      case $::operatingsystemmajrelease {
        '6': {
          service { $::tigervnc::service_name:
            ensure     => $::tigervnc::service_ensure,
            enable     => $::tigervnc::service_enable,
            hasstatus  => true,
            hasrestart => true,
          }
        }
        '7': {
          $_vncservers = $tigervnc::vncservers
          $_vncservers_length = length($_vncservers)
          if $_vncservers_length == 0 {
            fail("no vncservers were defined for use with tigervnc::service class on the CentOS 7 OS")
          } else {
            $_vncservers.each |String $username, Hash $useropts| {
              if 'ensure' in $useropts {
                if $useropts[ensure] == 'present' {
                  $_manage_service = true
                } else {
                  $_manage_service = false
                }
              } else {
                $_manage_service = true
              }
              if $_manage_service {
                $_displaynumber = $useropts[displaynumber]
                service { "vncserver@:${_displaynumber}.service":
                  ensure    => $::tigervnc::service_ensure,
                  enable    => $::tigervnc::service_enable,
                  subscribe => File["/etc/systemd/system/vncserver@:${_displaynumber}.service"],
                }
              }
            }
          }
        }
        default: {
          fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
