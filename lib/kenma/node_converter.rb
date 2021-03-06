# frozen_string_literal: true

require_relative "./refine/source.rb"
require_relative "./refine/nodable.rb"
require_relative "./refine/node_iteration.rb"

module Kenma
  class NodeConverter
    using Kenma::Refine::Source
    using Kenma::Refine::Nodable

    def initialize(context = {})
      @scope_context = context
    end

    def convert(node)
      _convert(node) { |node, parent|
        method_name = "NODE_#{node.type}"
        send_node(method_name, node, parent)
      }
    end

    private

    KENMA_MACRO_EMPTY_NODE = Object.new.freeze
    private_constant :KENMA_MACRO_EMPTY_NODE

    attr_reader :bind
    attr_reader :scope_context

    def bind
      scope_context[:bind]
    end

    def scope_context_switch(context, &block)
      self.class.new(scope_context.merge(context)).then(&block)
    end

    def _convert(node, &block)
      return node unless node.node?

      if node.type == :SCOPE
        return scope_context_switch(scope_context) { |converter|
          children = [*node.children.take(node.children.size-1), converter.convert(node.children.last)]
                      .reject { |it| KENMA_MACRO_EMPTY_NODE == it }
          send_node(:NODE_SCOPE, [:SCOPE, children], node)
        }
      end

      children = node.children
      converted_children = children
        .map { |node| _convert(node) { |child| block.call(child, node) || KENMA_MACRO_EMPTY_NODE } }
        .reject { |it| KENMA_MACRO_EMPTY_NODE == it }

      if converted_children == children
        node
      else
        [node.type, converted_children]
      end.then { |node| block.call(node, nil) }
    end

    def send_node(method_name, node, parent)
      if respond_to?(method_name, true)
        result = send(method_name, node, parent)
        if result == node
          node_missing(node, parent)
        else
          result
        end
      else
        node_missing(node, parent)
      end
    end

    def node_missing(node, parent)
      node
    end
  end
end
