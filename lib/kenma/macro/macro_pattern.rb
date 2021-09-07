# frozen_string_literal: true

require_relative "../macroable.rb"
require_relative "./macro_node.rb"

module Kenma
  using Kenma::Refine::Nodable

  class PatternCapture < Struct.new(:pat_node)
    def initialize(pat_node)
      self.pat_node = pat_node
    end

    def match(node)
      _match(node, pat_node)
    end
    alias_method :===, :match

    private

    def _match(node, pat)
      return {} if node == pat
      return nil if node.nil? || pat.nil?
      return nil if !node.node? || !pat.node?

      if pat.type == :GASGN && node.type.to_s =~ /ASGN|CDECL/
        match_result = _match(node.children.last, pat.children.last)
        if match_result
          tag = pat.children.first.to_s.delete_prefix("$").to_sym
          { tag => node.children.first }.merge(_match(node.children.last, pat.children.last))
        else
          nil
        end
      elsif pat.type == :GVAR
        tag = pat.children.first.to_s.delete_prefix("$").to_sym
        { tag => node }
      # Add Support: pat { [*$node] } === ast { [a, b, c] } # => { node: [a, b, c] }
      # Not Support: pat { [$first, *$node] } === ast { [a, b, c] } # => nil
      elsif pat.type === :SPLAT && pat.children.first.type == :GVAR
        tag = pat.children.first.children.first.to_s.delete_prefix("$").to_sym
        { tag => node }
      elsif node.type == pat.type && node.children.size == pat.children.size
        node.children.zip(pat.children).inject({}) { |result, (src, pat)|
          if match_result = _match(src, pat)
            result.merge(match_result)
          else
            break nil
          end
        }
      else
        nil
      end
    end
  end

  module Macroable
    refine Kernel do
      def pat(&block)
        pat_node(RubyVM::AbstractSyntaxTree.of(block).children.last)
      end

      def pat_node(node)
        PatternCapture.new(node)
      end
    end

    refine Module do
      def macro_pattern(pattern, name)
        macro_patterns[name] = pattern
        extend Kenma::Macroable
      end

      def macro_patterns
        @macro_patterns ||= {}
      end
    end
  end

  module Macro
    module MacroPattern
      using Kenma::Macroable
      using Kenma::Refine::Source

      using Module.new {
        refine MacroPattern do
          using Kenma::Macroable
          def macro_patterns
            singleton_class.ancestors.grep(Kenma::Macroable).map(&:macro_patterns).inject({}, &:merge)
          end
        end
      }

      def node_missing(node, parent)
        macro = macro_patterns.lazy.reverse_each.map { |name, pat| [name, pat.match(node)] }.find { |name, captured| captured }
        if macro
          if macro[1].empty?
            send(macro[0], node)
          else
            send(macro[0], node, **macro[1])
          end
        else
          super(node, parent)
        end
      end
    end
  end
end
