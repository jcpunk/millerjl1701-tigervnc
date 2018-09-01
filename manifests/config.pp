# @api private
#
# This class is called from tigervnc for service config.
#
class tigervnc::config {
  assert_private('tigervnc::config is a private class')

  $_vncservers = $tigervnc::vncservers
  $_vncservers_length = length($_vncservers)
  if $_vncservers_length == 0 {
    fail('no vncservers were defined for use with tigervnc::config class')
  }

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      if $tigervnc::manage_vncuser_passwords {
        $tigervnc::vncservers.each |String $username, Hash $params| {
          exec { "create_vnc_dir_${username}":
            command => "mkdir ${tigervnc::user_homedir_path}/${username}/.vnc",
            path    =>  ['/bin', '/usr/bin',],
            cwd     => "${tigervnc::user_homedir_path}/${username}",
            user    => $username,
            creates => "${tigervnc::user_homedir_path}/${username}/.vnc",
          }
          if 'passwd' in $params {
            $pass = $params[passwd]
            exec { "create_vncuser_passwd_${username}":
              command => "echo ${pass} | vncpasswd -f > ${tigervnc::user_homedir_path}/${username}/.vnc/passwd ; chmod 600 ${tigervnc::user_homedir_path}/${username}/.vnc/passwd",
              path    =>  ['/bin', '/usr/bin',],
              cwd     => "${tigervnc::user_homedir_path}/${username}/.vnc",
              user    => $username,
              creates => "${tigervnc::user_homedir_path}/${username}/.vnc/passwd",
              require => Exec["create_vnc_dir_${username}"],
            }
          } else {
            exec { "create_vncuser_passwd_${username}":
              command => "echo ${tigervnc::vncuser_default_passwd} | vncpasswd -f > ${tigervnc::user_homedir_path}/${username}/.vnc/passwd ; chmod 600 ${tigervnc::user_homedir_path}/${username}/.vnc/passwd",
              path    =>  ['/bin', '/usr/bin',],
              cwd     => "${tigervnc::user_homedir_path}/${username}",
              user    => $username,
              creates => "${tigervnc::user_homedir_path}/${username}/.vnc/passwd",
              require => Exec["create_vnc_dir_${username}"],
            }

          }
        }
      }

      case $::operatingsystemmajrelease {
        '6': {
          file { '/etc/sysconfig/vncservers':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content =>  template($tigervnc::sysconfig_template),
          }
        }
        '7': {
          include ::systemd::systemctl::daemon_reload

          $_vncservers.each |String $username, Hash $useropts| {
            if 'ensure' in $useropts {
              $_ensure = $useropts[ensure]
            } else {
              $_ensure = 'present'
            }
            $_displaynumber = $useropts[displaynumber]
            if 'args' in $useropts {
              $_args = $useropts[args]
              file { "/etc/systemd/system/vncserver@:${_displaynumber}.service":
                ensure  => $_ensure,
                content =>  epp('tigervnc/systemd_service_with_args.epp', { 'username' =>  $username, 'args' =>  $_args }),
              } ~> Class['systemd::systemctl::daemon_reload']
            } else {
              file { "/etc/systemd/system/vncserver@:${_displaynumber}.service":
                ensure  => $_ensure,
                content =>  epp('tigervnc/systemd_service.epp', { 'username' =>  $username }),
              } ~> Class['systemd::systemctl::daemon_reload']
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
