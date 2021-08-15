# frozen_string_literal: true

require "rensei"
require_relative "./nodable.rb"

module Kenma
  module Refine
    module NodeToArray
      refine RubyVM::AbstractSyntaxTree::Node do
        using Module.new {
          [
            Object,
            NilClass,
            FalseClass,
            TrueClass,
            String,
            Hash,
            Array,
            Symbol,
            Numeric,
            Regexp,
          ].each { |klass|
            refine klass do
              def to_a(*)
                self
              end
            end

          }
        }

        def to_a
          [type, children.map { |it| it.to_a }]
        end
      end

      refine Array do
        using Module.new {
          [
            Object,
            NilClass,
            FalseClass,
            TrueClass,
            String,
            Hash,
            Symbol,
            Numeric,
            Regexp,
          ].each { |klass|
            refine klass do
              def to_a(*)
                self
              end
            end

          }
        }

        using NodeToArray

        def to_a(*)
          map { |it| it.to_a }
        end
      end
    end
  end
end
