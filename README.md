# Fluent::Plugin::Jubatus

fluentd pluing for jubatus

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-jubatus', git: 'git://github.com/katsyoshi/fluent-plugin-jubatus.git'

And then execute:

    $ bundle

## Usage
Configuration file:

    <match mikutter.timeline>
        type jubatus
        host 127.0.0.1        # not necessary (default: 127.0.0.1)
        port 9199             # not necessary (default: 9199)
        str_keys string1, string2 # you need to evaluate string value in jubatus
        num_keys number2, number2 # you need to evaluate number value in jubatus
        tag jubatus.timeline  # not necessary (default: jubatus)
    </match>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
