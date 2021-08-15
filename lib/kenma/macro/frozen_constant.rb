# frozen_string_literal: true

require_relative "../macroable.rb"
require_relative "./macro_node.rb"

module Kenma
  module Macro
    module FrozenConstant
      using Kenma::Macroable

      def _frozen_constant_decl(node, parent)
        left, right = node.children
        ast { $left = $right.freeze }
      end
      macro_node :CDECL, :_frozen_constant_decl
    end
  end
end
