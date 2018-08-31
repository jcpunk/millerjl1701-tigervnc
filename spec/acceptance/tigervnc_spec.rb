require 'spec_helper_acceptance'

describe 'tigervnc class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      user { 'testuser1': ensure => present, managehome => true, }
      user { 'testuser2': ensure => present, managehome => true, }
      class { 'tigervnc':
        vncservers => {
          'testuser1' => {
            displaynumber => '1',
          },
          'testuser2' => {
            ensure        => present,
            displaynumber => '2',
            passwd        => 'password',
            args          => [
              'geometry 1280x1024',
              'localhost',
            ],
          },
        },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('tigervnc-server') do
      it { should be_installed }
    end

    if (fact'osfamily') == 'RedHat' && fact('operatingsystemmajrelease') == '6'
      describe file('/etc/sysconfig/vncservers') do
        it { should exist }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        it { should contain '1:testuser1 2:testuser2' }
      end
      describe service('vncserver') do
        it { should be_enabled }
        it { should be_running }
      end
    end

    describe port(5901) do
      it { should be_listening.on('0.0.0.0').with('tcp') }
    end
    describe port(5902) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end
end
