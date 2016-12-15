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
    program :version, '0.10.0'
    program :description, "It's a thing!"

    command :acceptance do |c|
      c.syntax = 'modtest acceptance [options]'
      c.description = "Runs acceptance tests"
      c.option '--options', Object, 'list selected options and do nothing'
      c.option '--node NODESET', String, 'path to nodeset for the test(s)'
      c.option '--key KEYFILE', String, 'path to key file for acceptance tests'
      c.option '--enterprise VERSION', Numeric, 'PE version'
      c.option '-d','--destroy', String, 'to destroy or not to destroy?'
      c.option '--provision', Object, 'to provision or not to provision?'
      c.option '-D','--debug', Object, 'debug?'
      c.option '--test FILE', String, 'Test file'
      c.action do |args,options|

        if options.enterprise
          pe_version_actual = `curl -s http://getpe.delivery.puppetlabs.net/latest/#{options.enterprise}`
          pe_dir = "http://enterprise.delivery.puppetlabs.net/#{options.enterprise}/ci-ready"
          puppet_install_type = "pe"
        else
          puppet_install_type = "foss"
        end

        options.default \
        :key       => "#{ENV['HOME']}/.ssh/id_rsa-acceptance",
        :destroy   => ENV['BEAKER_destroy'] || false,
        :provision => ENV['BEAKER_provision'] || false

        @final_command_hash = {
          "PUPPET_INSTALL_TYPE" => puppet_install_type,
          "BEAKER_PE_DIR"       => pe_dir,
          "BEAKER_PE_VER"       => pe_version_actual,
          "BEAKER_destroy"      => tf_to_yn(options.destroy),
          "BEAKER_provision"    => tf_to_yn(options.provision),
          "BEAKER_setfile"      => options.node,
          "BEAKER_keyfile"      => options.key,
          "BEAKER_debug"        => options.debug
        }.delete_if { |key, value| value.nil? }

        @final_command_hash.each do |key,value|
          unless value == nil
            @final_command_string += "#{key}=#{value} "
          end
        end

        if Dir.exist?("#{Dir.pwd}/spec/acceptance")
          acceptance_dir = "#{Dir.pwd}/spec/acceptance"
        else
          raise "Acceptance test directory: #{Dir.pwd}/spec/acceptance not found, are you in the module's root dir?"
        end

        rspec_command = "bundle exec rspec #{Dir.pwd}/spec/acceptance/#{options.test}"
        @final_command_string += rspec_command

        print_options @final_command_hash
        print_command @final_command_hash, rspec_command

        unless options.options
          exec(@final_command_string)
        end
      end
    end

    command :unit do |c|
      c.syntax = 'modtest unit [options]'
      c.description = "Runs unit tests"
      c.action do |args, options|
        say "Unit"
      end
    end
    run!
  end
end

