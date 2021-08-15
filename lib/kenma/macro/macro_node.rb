# frozen_string_literal: true

require_relative "../macroable.rb"

module Kenma
  module Macroable
    refine Module do
      def macro_node(node_type, name)
        define_method("NODE_#{node_type}") { |node, parent|
          send(name, node, parent)
        }
      end
    end
  end
end
