# frozen_string_literal: true

require_relative "./node_converter.rb"
require_relative "./refine/node_to_a.rb"

module Kenma
  module Macroable
    refine Kernel do
      def ast(&block)
        Macro::Core.convert_of(block)
      end
    end

    # TODO: duplicate Reifne::Nodable
    refine Array do
      def type; self[0]; end
      def children; self[1]; end
    end
  end
end
