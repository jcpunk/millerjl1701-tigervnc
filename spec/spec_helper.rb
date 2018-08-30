require 'puppetlabs_spec_helper/module_spec_helper'

require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  add_filter '/.vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  RSpec.configure do |c|
    default_facts = {
      puppetversion: Puppet.version,
      facterversion: Facter.version,
    }
    default_facts.merge!(YAML.load(File.read(File.expand_path('../default_facts.yml', __FILE__)))) if File.exist?(File.expand_path('../default_facts.yml', __FILE__))
    default_facts.merge!(YAML.load(File.read(File.expand_path('../default_module_facts.yml', __FILE__)))) if File.exist?(File.expand_path('../default_module_facts.yml', __FILE__))
    c.default_facts = default_facts
    c.before :each do
      Puppet.settings[:strict] = :error
    end
  end
end

# put local configuration and setup into spec_helper_local
begin
  require 'spec_helper_local'
rescue LoadError
end
