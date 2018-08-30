node default {

  notify { 'enduser-before': }
  notify { 'enduser-after': }

  class { 'tigervnc':
    require => Notify['enduser-before'],
    before  => Notify['enduser-after'],
  }

}
