# frozen_string_literal: true

require "kenma"
require "kenma/refine/node_to_a"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Module.new {
    using Kenma::Refine::Source
    using Kenma::Refine::NodeToArray

    def eq_ast(&block)
      satisfy("eq_ast body") { |node| expect(RubyVM::AbstractSyntaxTree.parse(node.source).to_a).to eq RubyVM::AbstractSyntaxTree.of(block).to_a }
    end
  }
end
