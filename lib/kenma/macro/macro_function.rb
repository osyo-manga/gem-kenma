# frozen_string_literal: true

require_relative "../macroable.rb"
require_relative "./macro_node.rb"

module Kenma
  module Macroable
    refine Module do
      def macro_function(name)
        macro_functions << name
        module_function name
        extend Kenma::Macroable
      end

      def macro_functions
        @macro_functions ||= []
      end
    end
  end

  module Macro
    module MacroFunction
      using Kenma::Macroable
      using Kenma::Refine::Source

      using Module.new {
        refine MacroFunction do
          using Kenma::Macroable
          def macro_functions
            singleton_class.ancestors.grep(Kenma::Macroable).map(&:macro_functions).inject([], &:+)
          end

          def send_macro_function(method_name, args, &block)
            if macro_functions.include?(method_name)
              converted_args = convert(args)
              send(method_name, *converted_args&.children&.compact, &block)
            end
          end
        end
      }

      private

      def _FCALL_send_macro_function(node, parent)
        return node if parent&.type == :ITER
        method_name, args = node.children
        send_macro_function(method_name, args) || node
      end
      macro_node :FCALL, :_FCALL_send_macro_function

      def _ITER_send_macro_function(node, parent)
        fcall, scope = node.children
        method_name, args = fcall.children
        send_macro_function(method_name, args) { scope } || node
      end
      macro_node :ITER, :_ITER_send_macro_function
    end
  end
end