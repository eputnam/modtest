#!/usr/bin/env ruby
require 'rubygems'
require 'commander'
require 'rainbow/ext/string'

class Modtest
  include Commander::Methods

  def initialize
    @final_command_hash = Hash.new
    @final_command_string = String.new
  end

  def tf_to_yn tf
    if tf == true or tf == 'yes'
      return "yes"
    else
      return "no"
    end
  end

  def print_options options_hash
    puts "Selected Options: ".color(:yellow)
    options_hash.each do |option,value|
      if option == "BEAKER_setfile" && value.nil?
        value = "default"
      end
      print "#{option}=".color(:cyan)
      puts "#{value}"
    end
  end

  def print_command options_hash, rspec_command
    puts "Executing Command: ".color(:yellow)
    options_hash.each do |option,value|
      print "#{option}=".color(:cyan)
      print "#{value} "
    end
    puts rspec_command
  end

  def run
    program :name, 'modtest'
    program :version, '0.1.0'
    program :description, "Tool for running module acceptance tests without having to type so darn much!"

    command :acceptance do |c|
      c.syntax = 'modtest acceptance [options]'
      c.description = "Runs acceptance tests"
      c.option '-o', '--options', Object, 'list selected options and do nothing'
      c.option '-t', '--type TYPE', String, 'install type'
      c.option '-n', '--node NODESET', String, 'path to nodeset for the test(s)'
      c.option '-k', '--key KEYFILE', String, 'path to key file for acceptance tests'
      c.option '-i', '--install-version INSTALL_VERSION', Numeric, 'puppet version'
      c.option '-d', '--destroy', String, 'to destroy or not to destroy?'
      c.option '-p', '--provision', Object, 'to provision or not to provision?'
      c.option '-b', '--debug', Object, 'debug?'
      c.option '-f', '--file FILE', String, 'Test file'
      c.action do |args,opts|

        opts.default \
        :key       => "#{ENV['HOME']}/.ssh/id_rsa-acceptance",
        :destroy   => ENV['BEAKER_destroy'] || false,
        :provision => ENV['BEAKER_provision'] || false,
        :type      => "foss",
        :file      => "spec/acceptance/"

        case opts.type.downcase
        when "pe"
          puppet_install_type = "pe"
        when "foss"
          puppet_install_type = "foss"
        when "agent"
          puppet_install_type = "agent"
        end

        if puppet_install_type == "pe"
          if opts.install_version
            pe_version_actual = `curl -s http://getpe.delivery.puppetlabs.net/latest/#{opts.install_version}`
            pe_dir = "http://enterprise.delivery.puppetlabs.net/#{opts.install_version}/ci-ready"
          else
            raise "PE requires a version number. \nExamples: 2016.4, 2016.2, 2015.3\n"
          end
        else
          if opts.install_version
            puppet_install_version = opts.install_version
          end
        end

        @final_command_hash = {
          "PUPPET_INSTALL_TYPE"    => puppet_install_type,
          "PUPPET_INSTALL_VERSION" => puppet_install_version,
          "BEAKER_PE_DIR"          => pe_dir,
          "BEAKER_PE_VER"          => pe_version_actual,
          "BEAKER_destroy"         => tf_to_yn(opts.destroy),
          "BEAKER_provision"       => tf_to_yn(opts.provision),
          "BEAKER_setfile"         => opts.node,
          "BEAKER_keyfile"         => opts.key,
          "BEAKER_debug"           => opts.debug
        }.delete_if { |key, value| value.nil? }

        @final_command_hash.each do |key,value|
          unless value == nil
            @final_command_string += "#{key}=#{value} "
          end
        end

        raise "Acceptance test directory: #{Dir.pwd}/spec/acceptance not found, are you in the module's root dir?" if !Dir.exist?("#{Dir.pwd}/spec/acceptance")

        rspec_command = "bundle exec rspec #{Dir.pwd}/#{opts.file}"
        @final_command_string += rspec_command

        print_options @final_command_hash
        print_command @final_command_hash, rspec_command

        exec(@final_command_string) unless opts.options
      end
    end

    command :unit do |c|
      c.syntax = 'modtest unit [options]'
      c.description = "Runs unit tests"
      c.action do |args, o|

        if Dir.exist?("#{Dir.pwd}/spec/acceptance")
          acceptance_dir = "#{Dir.pwd}/spec/acceptance"
        else
          raise "Acceptance test directory: #{Dir.pwd}/spec/acceptance not found, are you in the module's root dir?"
        end

        exec('bundle exec rake spec')
      end
    end
    run!
  end
end

