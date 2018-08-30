require 'spec_helper'

describe 'tigervnc' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "tigervnc class without any parameters changed from defaults" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('tigervnc::install') }
          it { is_expected.to contain_class('tigervnc::config') }
          it { is_expected.to contain_class('tigervnc::service') }
          it { is_expected.to contain_class('tigervnc::install').that_comes_before('Class[tigervnc::config]') }
          it { is_expected.to contain_class('tigervnc::service').that_subscribes_to('Class[tigervnc::config]') }

          it { is_expected.to contain_package('tigervnc').with_ensure('present') }

          it { is_expected.to contain_service('tigervnc').with(
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasstatus'  => 'true',
            'hasrestart' => 'true',
          ) }
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

      it { expect { is_expected.to contain_package('tigervnc') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
