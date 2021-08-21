# frozen_string_literal: true

require_relative "../macroable.rb"
require_relative "./macro_function.rb"

module Kenma
  module Macro
    module UseMacro
      using Kenma::Macroable
      using Kenma::Refine::Nodable
      using Kenma::Refine::Source

      def initialize(context = {})
        super
        extend *use_macros.reverse unless use_macros.empty?
      end

      def use_macro!(node)
        macro_mod = bind.eval(node.source)
        use_macros << macro_mod
        extend macro_mod
        Kenma::NodeConverter::KENMA_MACRO_EMPTY_NODE
      end
      macro_function :use_macro!

      private

      def use_macro(mod)

      end

      def use_macros
        scope_context[:use_macros] ||= []
      end

      def scope_context_switch(context, &block)
        super(context) { |converter|
          converter.extend *use_macros.reverse unless use_macros.empty?
          block.call(converter)
        }
      end
    end
  end
end
