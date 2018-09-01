require 'spec_helper'

describe 'tigervnc' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "tigervnc class without any parameters changed from defaults" do
          let(:params){
            {
              :vncservers => {
                'testuser' => {
                  'displaynumber' => '1',
                }
              }
            }
          }
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('tigervnc::install') }
          it { is_expected.to contain_class('tigervnc::config') }
          it { is_expected.to contain_class('tigervnc::service') }
          it { is_expected.to contain_class('tigervnc::install').that_comes_before('Class[tigervnc::config]') }
          it { is_expected.to contain_class('tigervnc::service').that_subscribes_to('Class[tigervnc::config]') }

          it { is_expected.to contain_package('tigervnc-server').with_ensure('present') }

          if facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_exec('create_vnc_dir_testuser').with(
              'command' => 'mkdir /home/testuser/.vnc',
              'path'    => '["/bin", "/usr/bin"]',
              'cwd'     => '/home/testuser',
              'user'    => 'testuser',
              'creates' => '/home/testuser/.vnc',
            ) }
            it { is_expected.to contain_exec('create_vncuser_passwd_testuser').with(
              'command' => 'echo ChangeMe | vncpasswd -f > /home/testuser/.vnc/passwd ; chmod 600 /home/testuser/.vnc/passwd',
              'path'    => '["/bin", "/usr/bin"]',
              'cwd'     => '/home/testuser',
              'user'    => 'testuser',
              'creates' => '/home/testuser/.vnc/passwd',
            ) }

            if facts[:os]['release']['major'] == '6'
              it { is_expected.to contain_file('/etc/sysconfig/vncservers').with(
                'ensure' => 'present',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0644',
              ) }
              it { is_expected.to contain_file('/etc/sysconfig/vncservers').with_content(/VNCSERVERS="1:testuser"/) }

              it { is_expected.to contain_service('vncserver').with(
                'ensure'     => 'running',
                'enable'     => 'true',
                'hasstatus'  => 'true',
                'hasrestart' => 'true',
              ) }
            end
            if facts[:os]['release']['major'] == '7'
              it { is_expected.to contain_class('systemd::systemctl::daemon_reload') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_ensure('present') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/ExecStart=\/usr\/sbin\/runuser -l testuser/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/PIDFile=\/home\/testuser\/.vnc\/%H%i.pid/) }

              it { is_expected.to contain_service('vncserver@:1.service').with(
                'ensure' => 'running',
                'enable' => 'true',
              ) }
              it { is_expected.to contain_service('vncserver@:1.service').that_subscribes_to('File[/etc/systemd/system/vncserver@:1.service]') }
            end
          end
        end

        context "tigervnc class with two vncservers specified" do
          let(:params){
            {
              :vncservers => {
                'testuser' => {
                  'displaynumber' => '1',
                },
                'otheruser' => {
                  'displaynumber' => '2',
                },
              }
            }
          }

          if facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_exec('create_vnc_dir_otheruser').with(
              'command' => 'mkdir /home/otheruser/.vnc',
              'path'    => '["/bin", "/usr/bin"]',
              'cwd'     => '/home/otheruser',
              'user'    => 'otheruser',
              'creates' => '/home/otheruser/.vnc',
            ) }
            it { is_expected.to contain_exec('create_vncuser_passwd_otheruser').with(
              'command' => 'echo ChangeMe | vncpasswd -f > /home/otheruser/.vnc/passwd ; chmod 600 /home/otheruser/.vnc/passwd',
              'path'    => '["/bin", "/usr/bin"]',
              'cwd'     => '/home/otheruser',
              'user'    => 'otheruser',
              'creates' => '/home/otheruser/.vnc/passwd',
            ) }

            if facts[:os]['release']['major'] == '6'
              it { is_expected.to contain_file('/etc/sysconfig/vncservers').with_content(/VNCSERVERS="1:testuser 2:otheruser"/) }
            end
            if facts[:os]['release']['major'] == '7'
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_ensure('present') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/ExecStart=\/usr\/sbin\/runuser -l testuser/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/PIDFile=\/home\/testuser\/.vnc\/%H%i.pid/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_ensure('present') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_content(/ExecStart=\/usr\/sbin\/runuser -l otheruser/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_content(/PIDFile=\/home\/otheruser\/.vnc\/%H%i.pid/) }

              it { is_expected.to contain_service('vncserver@:1.service').with(
                'ensure' => 'running',
                'enable' => 'true',
              ) }
              it { is_expected.to contain_service('vncserver@:1.service').that_subscribes_to('File[/etc/systemd/system/vncserver@:1.service]') }
              it { is_expected.to contain_service('vncserver@:2.service').with(
                'ensure' => 'running',
                'enable' => 'true',
              ) }
              it { is_expected.to contain_service('vncserver@:2.service').that_subscribes_to('File[/etc/systemd/system/vncserver@:1.service]') }
            end
          end
        end

        context "tigervnc class with two vncservers specified with one set to ensure absent" do
          let(:params){
            {
              :vncservers => {
                'testuser' => {
                  'displaynumber' => '1',
                  'ensure'        => 'absent',
                },
                'otheruser' => {
                  'displaynumber' => '2',
                },
              }
            }
          }

          if facts[:os]['release']['major'] == '7'
            it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_ensure('absent') }
            it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
            it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_ensure('present') }
            it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_content(/ExecStart=\/usr\/sbin\/runuser -l otheruser/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:2.service').with_content(/PIDFile=\/home\/otheruser\/.vnc\/%H%i.pid/) }

            it { is_expected.to_not contain_service('vncserver@:1.service') }
            it { is_expected.to contain_service('vncserver@:2.service').with(
              'ensure' => 'running',
              'enable' => 'true',
            ) }
            it { is_expected.to contain_service('vncserver@:2.service').that_subscribes_to('File[/etc/systemd/system/vncserver@:1.service]') }
          end
        end

        context "tigervnc class with password and args parameters added for vncserver for testuser" do
          let(:params){
            {
              :vncservers => {
                'testuser' => {
                  'displaynumber' => '1',
                  'passwd'        => 'SuperSecret',
                  'args'          => [
                    'geometry 1280x1024',
                    'localhost',
                  ]
                }
              }
            }
          }

          if facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_exec('create_vncuser_passwd_testuser').with_command('echo SuperSecret | vncpasswd -f > /home/testuser/.vnc/passwd ; chmod 600 /home/testuser/.vnc/passwd') }
            if facts[:os]['release']['major'] == '6'
              it { is_expected.to contain_file('/etc/sysconfig/vncservers').with_content(/VNCSERVERARGS\[1\]/) }
              it { is_expected.to contain_file('/etc/sysconfig/vncservers').with_content(/-geometry 1280x1024 -localhost/) }
            end

            if facts[:os]['release']['major'] == '7'
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/ExecStart=\/usr\/sbin\/runuser -l testuser/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/PIDFile=\/home\/testuser\/.vnc\/%H%i.pid/) }
              it { is_expected.to contain_file('/etc/systemd/system/vncserver@:1.service').with_content(/-geometry 1280x1024 -localhost/) }
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'tigervnc class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end
      let(:params){
        {
          :vncservers => {
            'testuser' => {
              'displaynumber' => '1',
            }
          }
        }
      }

      it { expect { is_expected.to contain_package('tigervnc') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
