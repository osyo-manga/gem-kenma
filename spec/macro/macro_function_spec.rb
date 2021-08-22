# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::MacroFunction do
  using Kenma::Refine::Source

  describe "macro_function" do
    using Kenma::Macroable

    subject { Kenma.compile_of(body) }

    context "return nil" do
      let(:macro_module) {
        Module.new {
          def nilnil!
            nil
          end
          macro_function :nilnil!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        puts [1, nilnil!, 3]
      } }
      it { is_expected.to eq_ast { puts [1, 3] } }
    end

    context "return node" do
      let(:macro_module) {
        Module.new {
          def nilnil!
            RubyVM::AbstractSyntaxTree.parse("nilnil!")
          end
          macro_function :nilnil!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        puts nilnil!
      } }
      it { is_expected.to eq_ast { puts nilnil! } }
    end

    context "return self node" do
      let(:macro_module) {
        Module.new {
          def hoge!(a, b)
            ast { hoge!($a, $b) }
          end
          macro_function :hoge!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        hoge!(1 + 2, 3 +4)
      } }
      it { is_expected.to eq_ast { hoge!(1 + 2, 3 +4) } }
    end

    context "with_block" do
      module BlockMacro
        using Kenma::Macroable

        def block!(&block)
          if block
           ast { with_block { node_bind!(block.call) } }
          else
            ast { non_block }
          end
        end

        macro_function :block!
      end

      let(:body) { proc {
        use_macro! BlockMacro
        block!
        block! { 1 + 2 }
        block! { |a| a + 2 }
      } }
      it { is_expected.to eq_ast {
        non_block
        with_block { 1 + 2 }
        with_block { |a| a + 2 }
      } }
    end
  end
end
