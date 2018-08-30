# @api private
#
# This class is meant to be called from tigervnc to manage the tigervnc service.
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
