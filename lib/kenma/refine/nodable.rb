# frozen_string_literal: true

require "rensei"

module Kenma
  module Refine
    module Nodable
      refine Object do
        def node?; false; end
      end

      refine RubyVM::AbstractSyntaxTree::Node do
        def node?
          true
        end
      end

      refine Hash do
        def type; self[:type]; end

        def children; self[:children]; end

        def node?; !empty?; end
      end

      refine Array do
        def type; self[0]; end

        def children; self[1]; end

        def node?
          self.size == 2 &&
          self[0].kind_of?(Symbol) && self[0] == self[0].upcase &&
          self[1].kind_of?(Array)
        end
      end
    end
  end
end
