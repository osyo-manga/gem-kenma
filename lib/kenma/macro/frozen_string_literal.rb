# frozen_string_literal: true

require_relative "../macroable.rb"

module Kenma
  module Macro
    module FrozenStringLiteral
      using Kenma::Macroable

      def frozen_string(node, parent)
        ast { $node.freeze }
      end
      macro_node :STR, :frozen_string
    end
  end
end
