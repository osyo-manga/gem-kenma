# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::MacroFunction do
  using Kenma::Refine::Source

  describe "macro_function" do
    subject { Kenma.compile(body) }

    context "return nil" do
      module NilMacro
        using Kenma::Macroable

        def nilnil!
          nil
        end
        macro_function :nilnil!
      end

      let(:body) { proc {
        use_macro! NilMacro
        puts nilnil!
      } }
      it { is_expected.to eq_ast { puts nilnil! } }
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
