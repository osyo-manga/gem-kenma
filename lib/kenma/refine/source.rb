# frozen_string_literal: true

require "rensei"

module Kenma
  module Refine
    module Source
      refine RubyVM::AbstractSyntaxTree::Node do
        if RUBY_VERSION >= "3.1.0"
          def source
            super.tap { |it|
              break Rensei.unparse(self) if it.nil?
            }
          end
        else
          def source
            Rensei.unparse(self)
          end
        end
      end

      refine Hash do
        def source; Rensei.unparse(self.dup); end
      end

      refine Array do
        def source; Rensei.unparse(self.dup); end
      end
    end
  end
end
