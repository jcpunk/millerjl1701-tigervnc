# @api private
#
# This class is called from tigervnc for service config.
#
class tigervnc::config {
  assert_private('tigervnc::config is a private class')


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

          $_vncservers = $tigervnc::vncservers

          file { '/etc/sysconfig/vncservers':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content =>  template($tigervnc::sysconfig_template),
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
