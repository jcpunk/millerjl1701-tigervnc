# @api private
#
# This class is called from the main tigervnc class for install.
#
class tigervnc::install {
  assert_private('tigervnc::install is a private class')

  package { $::tigervnc::package_name:
    ensure => $::tigervnc::package_ensure,
  }
}
