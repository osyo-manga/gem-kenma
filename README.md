[![Ruby CI](https://github.com/osyo-manga/gem-kenma/actions/workflows/kenma.yml/badge.svg)](https://github.com/osyo-manga/gem-kenma/actions/workflows/kenma.yml)

# Kenma

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kenma'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install kenma

## Usage

### Macro function

```ruby
require "kenma"

using Kenma::Refine::Source

# Define Macro module
module CatMacro
  using Kenma::Macroable

  # Define Macro function
  # Macro function is
  #   input  -> RubyVM::AST::Node
  #   output -> RubyVM::AST::Node
  def cat!(num = ast { 1 })
    # ast return AST::Node in block
    # $num is bind variable `num`
    ast { "にゃーん" * $num }
  end
  macro_function :cat!
end

body = proc {
  use_macro! CatMacro
  puts cat!
  puts cat!(3)
}
# Apply Macro functions
puts Kenma.compile(body).source
# => begin puts(("にゃーん" * 1)); puts(("にゃーん" * 3)); end
```

### Macro defines

```ruby
require "kenma"

using Kenma::Refine::Source
using Kenma::Refine::Nodable

# Macro module
#   defined macros in
#   priority is
#     node macro > function macro > pattern macro
module MyMacro
  using Kenma::Macroable

  # Node macro
  # Replace the AST of a specific node with the AST of the return value
  def frozen_string(str_node, parent_node)
    ast { $str_node.freeze }
  end
  macro_node :STR, :frozen_string

  # Function macro
  # Replace the AST from which the function is called with the AST of the return value
  def cat!(num_not = ast { 1 })
    ast { "にゃーん" * $num_not }
  end
  macro_function :cat!

  # Pattern macro
  # Replace the AST that matches the pattern with the AST of the return value
  def frozen(node, name:, value:)
    ast { $name = $value.freeze }
  end
  macro_pattern pat { $name = $value }, :frozen
end


body = proc {
  use_macro! MyMacro

  "にゃーん" # => "にゃーん".freeze

  puts cat!     # => puts "にゃーん"
  puts cat!(3)  # => puts "にゃーん" * 3

  value = [1, 2, 3]  # => value = [1, 2, 3].freeze
}

result = Kenma.compile(body)
puts result.source
# => begin "にゃーん".freeze(); puts(("にゃーん" * 1)); puts(("にゃーん" * 3)); (value = [1, 2, 3].freeze()); end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kenma.
