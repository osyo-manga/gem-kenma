# frozen_string_literal: true

require_relative "../macroable.rb"

module Kenma
  module Macro
    module Basic
      using Kenma::Macroable
      using Kenma::Refine::Source
      using Kenma::Refine::Nodable

      def symbolify!(args)
        [:LIT, [args.source.to_sym]]
      end
      macro_function :symbolify!

      def stringify!(args)
        if args.respond_to?(:source)
          [:LIT, [args.source]]
        else
          [:LIT, [args.to_s]]
        end
      end
      macro_function :stringify!

      def unstringify!(args)
        RubyVM::AbstractSyntaxTree.parse(bind.eval(args.source)).children.last
      end
      macro_function :unstringify!

      def node_bind!(args)
        bind.eval(args.source)
      end
      macro_function :node_bind!

      def eval!(args)
        data = bind.eval(args.source)
        RubyVM::AbstractSyntaxTree.parse(data.inspect).children.last
      end
      macro_function :eval!

      # $node
      def NODE_GVAR(node, parent)
        name = node.children.first.to_s.delete_prefix("$").to_sym
        if bind.local_variable_defined?(name)
          bind.local_variable_get(name)
        else
          node
        end
      end

      # $left = right
      def NODE_GASGN(node, parent)
        left, right = node.children
        name = left.to_s.delete_prefix("$").to_sym
        if bind.local_variable_defined?(name)
          [:GASGN, [bind.local_variable_get(name), right]]
        else
          node
        end
      end
    end
  end
end
