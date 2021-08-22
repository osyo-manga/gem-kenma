# frozen_string_literal: true

require_relative "./node_converter.rb"
require_relative "./refine/node_to_a.rb"

module Kenma
  module Macroable
    refine Kernel do
      def ast(context = {}, &body)
        bind = body.binding unless context[:bind]
        node = RubyVM::AbstractSyntaxTree.of(body).children.last
        Kenma.compile(node, { bind: bind }.merge(context))
      end
    end

    # TODO: duplicate Reifne::Nodable
    refine Array do
      def type; self[0]; end
      def children; self[1]; end
    end
  end
end
