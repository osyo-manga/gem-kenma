# frozen_string_literal: true

require_relative "./../node_converter.rb"
require_relative "./use_macro.rb"
require_relative "./basic.rb"
require_relative "./macro_function.rb"
require_relative "./macro_node.rb"
require_relative "./macro_pattern.rb"

module Kenma
  module Macro
    class Core < Kenma::NodeConverter
      using Kenma::Macroable
      using Kenma::Refine::Nodable

      include Macro::UseMacro
      include Macro::Basic
      include Macro::MacroFunction
      include Kenma::Macro::MacroPattern

      def self.eval(bind: nil, &block)
        bind = block.binding unless bind
        bind.eval(convert_of(block, bind: bind).source)
      end

      private

      def _convert(node, &block)
        return node unless node.node?

        if node.type == :SCOPE
          return scope_context_switch(scope_context) { |converter|
            children = [*node.children.take(node.children.size-1), converter.convert(node.children.last)]
                        .reject { |it| Symbol === it && it == :KENMA_MACRO_EMPTY_NODE }
            send_node(:NODE_SCOPE, [:SCOPE, children], node)
          }
        end

        super(node, &block)
      end
    end
  end
end
