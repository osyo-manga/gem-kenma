# frozen_string_literal: true

require_relative "./node_converter.rb"
require_relative "./macro/use_macro.rb"
require_relative "./macro/basic.rb"
require_relative "./macro/macro_function.rb"
require_relative "./macro/macro_node.rb"
require_relative "./macro/macro_pattern.rb"

module Kenma
  class PreProcessor < Kenma::NodeConverter
    include Macro::UseMacro
    include Macro::Basic
    include Macro::MacroFunction
    include Macro::MacroPattern

    alias_method :compile, :convert

    def self.compile(node, context = {})
      new(context).compile(node)
    end

    def self.compile_of(body, context = {})
      bind = body.binding unless context[:bind]
      compile(RubyVM::AbstractSyntaxTree.of(body), { bind: bind }.merge(context))
    end
  end
end
