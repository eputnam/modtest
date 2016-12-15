# Modtest
This is a gem that provides a simple CLI for running acceptance tests for modules on vmpooler.

## Installation

Build the gem:
```shell
gem build modtest.gemspec
```

Install the gem:
```shell
gem install modtest-x.y.z.gem
```

## Usage
This command must be run in the root directory of the module in test.

### Example
Provision a new server and run all acceptance tests for a module on PE 2016.2 on SLES 12. Do not destroy.

Old method:
```shell
PUPPET_INSTALL_TYPE=pe BEAKER_PE_DIR="http://enterprise.delivery.puppetlabs.net/2016.2/ci-ready" BEAKER_provision=yes BEAKER_destroy=no BEAKER_setfile=spec/acceptance/nodesets/sles-12-64mda bundle exec rspec spec/acceptance
```

With this gem:
```shell
modtest acceptance -p -e 2016.2 -n spec/acceptance/nodesets/sles-12-64mda
```

### Available Options
#### `-o`, `--options` 
  *	"noop" mode, list selected options and print command without executing.
#### `-t`, `--type TYPE`
  * maps to `PUPPET_INSTALL_TYPE` 
  * agent | foss | pe
#### `-n`, `--node NODESET`
  * maps to `BEAKER_setfile`
  * path to nodeset file
#### `-k`, `--key KEYFILE`
  * maps to `BEAKER_keyfile`
  * path to acceptance key file
#### `-i`, `--install-version INSTALL_VERSION`
  * maps to `PUPPET_INSTALL_VERSION`
  * version of selected Puppet type to install
#### `-d`, `--destroy`
- maps to `BEAKER_destroy`
- defaults to `ENV['BEAKER_destroy'] || false`	
#### `-p`, `--provision`
- maps to `BEAKER_provision`
- defaults to `ENV['BEAKER_provision'] || false`
#### `-b`, `--debug`
- maps to `BEAKER_debug`
- toggle Beaker debug output
#### `-f`, `--file TEST_FILE`
- run only a specified spec file appended to `$(pwd)/spec/acceptance/`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eputnam/modtest.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
