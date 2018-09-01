# tigervnc

master branch: [![Build Status](https://secure.travis-ci.org/millerjl1701/millerjl1701-tigervnc.png?branch=master)](http://travis-ci.org/millerjl1701/millerjl1701-tigervnc)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with tigervnc](#setup)
    * [What tigervnc affects](#what-tigervnc-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with tigervnc](#beginning-with-tigervnc)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Module Description

This module installs, configures, and manages the tigervnc-server vncserver service.

By default, it will set the vnc session password for each user to the same password but allows for the user to change their own password as they choose. Alternatively, one can set different vnc session passwords per user. Either allows for the vncserver service(s) to startup correctly on the very first application of the module. 

This module makes no assumptions for user authentication via XDMCP at this time. 

This module assumes that you are not going to use xinetd for management of the service at this time. 

If you prefer to use the xinetd/XDMCP method referenced in the documentation, please consider using the [simp/vnc](https://forge.puppet.com/simp/vnc) module.

For more details on the TigerVNC project, please see [http://tigervnc.org/](http://tigervnc.org/).

For reference, the tigervnc-server installation and configuration documentation for RedHat is located at:
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/chap-tigervnc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/chap-tigervnc)
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-tigervnc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-tigervnc)


This module is currently written to support CentOS/RedHat 6/7 operating systems. Other operating systems could be added if time permits (Pull requests are welcome. :)

## Setup

### What tigervnc affects

* Package: tigervnc-server
* File: /etc/sysconfig/vncservers (CentOS/RedHat 6)
* File: /etc/systemd/system/vncserver@:_displaynumber_.service (CentOS/RedHat 7)
* File: /home/_username_/.vnc (Managed by default. This can be disabled)
* File: /home/_username_/.vnc/passwd (Managed by default. This can be disabled)
* Service: vncserver (CentOS/RedHat 6)
* Service: vncserver@:_displaynumber_.service (CentOS/RedHat 7)

### Setup Requirements

The user(s) that the vncserver will be run as must exist on the system prior to the tigervnc class being called. However, no assumption is made on how that user is created on the system- just that it exists. For a puppet way of managing users, one could use the [rberwald/accounts](https://forge.puppet.com/rberwald/accounts), and then you would likely want to setup in puppet code (site.pp or elsewhere) something similar to:

```puppet
    Class['accounts'] -> Class['tigervnc']
```

to ensure proper resource ordering.

For CentOS/RedHat 7, this module depends on the [camptocamp/systemd](http://forge.puppet.com/camptocamp/systemd) module for management of the systemd unit file and systemd daemon-reload process.

This module configures tigervnc-server using system service resources. If you prefer using xinetd for management of the vncserver processes, please consider using the [simp/vnc](https://forge.puppet.com/simp/vnc) module instead.

### Beginning with tigervnc

To install, configure and manage the tigervnc-server vncserver service for a single user with the basic defaults, one would use the following puppet code:

```puppet
  class { 'tigervnc':
    vncservers => {
      'user1' => {
        displaynumber => '1',
      },
    },
  }
```

which will launch a vncserver service process for the user "user1" listening at __0.0.0.0:5901__. 

## Usage

All parameters to the main class may be passed via puppet code or hiera.

Note: the Puppet lookup function will by default create a merged hash from hiera data for the tigervnc::sysconfig_vncservers parameter. It is possible to override the merge behavior in your own hiera data; however, this has not been tested and could create unanticipated results.

Some futher examples that one could do with the class.

### Disable the management of vncpasswd files per user 

```puppet
  class { 'tigervnc':
    manage_vncuser_passwords => false,
    vncservers               => {
      'user1' => {
        displaynumber => '1',
      },
    },
  }
```

Note: If one disables the class from managing the vncpasswd files, the vncserver service(s) will not start until the password file is created via other means.

### Specify a default vncpasswd for all users

```puppet
  class { 'tigervnc':
    vncuser_default_passwd => 'SuperDuperPassword',
    vncservers             => {
      'user1' => {
        displaynumber => '1',
      },
    },
  }
```

Note: While a default password will be created for a user, this module does not manage the vncpasswd file once created. This allows for the user to change their vncpasswd as they desire. If the vnc passwd file is removed at somepoint, the class will recreate a passwd fie with either the default or specified user password.

### Specify multiple vnc users

```puppet
  class { 'tigervnc':
    vncservers             => {
      'user1' => {
        displaynumber => '1',
      },
      'user2' => {
        displaynumber => '2',
      }
    },
  }
```

and what this looks like in hiera:

```yaml
---

tigervnc::vncservers:
  user1:
    displaynumber: '1'
  user2:
    displaynumber: '2'
```

### Specify vncserver arguments for a different resolution and to listen on localhost only

```puppet
  class { 'tigervnc':
    vncservers             => {
      'user1' => {
        displaynumber => '1',
      },
      'user2' => {
        displaynumber => '2',
        'args'        => [
            'geometry 1280x1024',
            'localhost',
        ],
      },
    },
  }
```

and what this looks like in hiera:

```yaml
---

tigervnc::vncservers:
  user1:
    displaynumber: '1'
  user2:
    displaynumber: '2'
    args:
      - 'geometry 1280x1024'
      - 'localhost'
```

### Removing a systemd unit file and service (in this example for user2) on CentOS/RedHat 7

```puppet
  class { 'tigervnc':
    vncservers             => {
      'user1' => {
        displaynumber => '1',
      },
      'user2' => {
        ensure        => 'absent',
        displaynumber => '2',
      }
    },
  }
```

## Reference

Generated puppet strings documentation with examples is available from [https://millerjl1701.github.io/millerjl1701-tigervnc](https://millerjl1701.github.io/millerjl1701-tigervnc).

The puppet strings documentation is also included in the /docs folder.

### Public Class
* tigervnc: Main class which installs, configures, and manages the vncserver service(s)

### Private Classes
* tigervnc::install: Class for installation of the tigervnc-server.
* tigervnc::config: Class for setting configuration files for the vncserver process(es)
* tigervnc::service: Class for managing the state of the vncserver process(es)

## Limitations

This module currently supports CentOS/RedHat 6/7. In time, other operating systems may be added. Pull requests with tests are welcome!

## Development

Please see the [CONTRIBUTING document](CONTRIBUTING.md) for information on how to get started developing code and submit a pull request for this module. While written in an opinionated fashion at the start, over time this can become less and less the case.

### Contributors

To see who is involved with this module, see the [GitHub list of contributors](https://github.com/millerjl1701/millerjl1701-tigervnc/graphs/contributors) or the [CONTRIBUTORS document](CONTRIBUTORS).
