# LessFactor

This gem supports refactoring of css/less stylefiles. As of now it
mainly extracts variables. Variables are recognized by a pattern:

-   length : number followed by 'px' or 'em'
-   color : \#xxxxxx or \#xxx

It generates two new files:

      <infile>.refactored.less      - the refactored lessfile
      <infile>.refactored_vars.less - the new variables file

## Installation

Add this line to your application's Gemfile:

    gem 'lessFactor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lessFactor

## Usage

1.  run

    lessfactor infile.less varfile.less

2.  identify the semantics of the variables, e.g. by comparing
    'infile.refactored.less' with 'infile.less'
3.  rename the variables in the variables file to reflect the semantics
4.  rerun lessfactor to get the new variable names
5.  merge the refactored files back into your project

## Known Issues

This is a very first shot. Areas of improvements:

* more robust parser
* option to ignore particular literals from being refactored - no idea how to achieve that
* do not crate a new variables file but patch the existing one
* apply the same for sass

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
