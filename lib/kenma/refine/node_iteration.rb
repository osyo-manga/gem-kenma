# frozen_string_literal: true

require "rensei"
require_relative "./nodable.rb"
require_relative "../iteration.rb"

module Kenma
  module Refine
    module NodeIteration
      def each_node(&block)
        Kenma::Iteration.each_node(self, &block)
      end

      def convert_node(&block)
        Kenma::Iteration.convert_node(self, &block)
      end

      def find_convert_node(pat, &block)
        Kenma::Iteration.find_convert_node(self, pat, &block)
      end

      refine Array do
        include Kenma::Refine::NodeIteration
      end

      refine RubyVM::AbstractSyntaxTree::Node do
        include Kenma::Refine::NodeIteration
      end
    end
  end
end
