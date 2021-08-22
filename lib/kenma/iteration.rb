# frozen_string_literal: true

require_relative "./refine/nodable.rb"

module Kenma
  module Iteration
    using Kenma::Refine::Nodable

    KENMA_ITERATION_MACRO_EMPTY_NODE = Object.new.freeze
    private_constant :KENMA_ITERATION_MACRO_EMPTY_NODE

    module_function

    def each_node(node, &block)
      return Enumerator.new { |y|
        each_node(node) { |node|
          y << node
        }
      } unless block
      return node unless node.node?

      node.children.map { |node|
        each_node(node) { |child| block.call(child, node) }
      }
      block.call(node) if block
    end

    def convert_node(node, &block)
      return node unless node.node?

      children = node.children
      converted_children = children
        .map { |node| convert_node(node) { |child| block.call(child, node) || KENMA_ITERATION_MACRO_EMPTY_NODE } }
        .reject { |it| KENMA_ITERATION_MACRO_EMPTY_NODE == it }

      if converted_children == children
        node
      else
        [node.type, converted_children]
      end.then { |node| block.call(node, nil) }
    end

    def find_convert_node(node, pat, &block)
      convert_node(node) { |node|
        if result = pat === node
          block.call(node, **result)
        else
          node
        end
      }
    end
  end
end
