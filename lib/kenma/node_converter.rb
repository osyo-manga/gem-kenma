# frozen_string_literal: true

require_relative "./refine/source.rb"
require_relative "./refine/nodable.rb"

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

    def self.convert(node, context = {})
      new(context).convert(node)
    end

    def self.convert_of(body, context = {})
      bind = body.binding unless context[:bind]
      convert(RubyVM::AbstractSyntaxTree.of(body), { bind: bind }.merge(context))
    end

    private

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

      children = node.children
      converted_children = children
        .map { |node| _convert(node) { |child| block.call(child, node) } }
        .reject { |it| Symbol === it && it == :KENMA_MACRO_EMPTY_NODE }

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
