# Modtest
**UNDER DEVELOPMENT**
This is a gem that provides a simple CLI for running acceptance and unit tests for modules on vmpooler.

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

Provision a new server and run all acceptance tests for a module on PE 2016.2 on SLES 12. Do not destroy.

Old method:
```shell
PUPPET_INSTALL_TYPE=pe BEAKER_PE_DIR="http://enterprise.delivery.puppetlabs.net/2016.2/ci-ready" BEAKER_provision=yes BEAKER_destroy=no BEAKER_setfile=spec/acceptance/nodesets/sles-12-64mda bundle exec rspec spec/acceptance
```

With this gem:
```shell
modtest acceptance -p -e 2016.2 -n spec/acceptance/nodesets/sles-12-64mda 
```

Use `modtest acceptance --help` for a full list of options

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eputnam/modtest.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

