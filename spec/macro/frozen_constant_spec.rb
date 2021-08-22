# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::FrozenConstant do
  using Kenma::Refine::Source

  describe "frozen constant" do
    subject { Kenma.compile_of(body) }

    context "defined constant variable" do
      let(:body) {
        proc {
          use_macro! Kenma::Macro::FrozenConstant
          HOGE = [1, 2, 3]
        }
      }
      it { is_expected.to eq_ast { HOGE = [1, 2, 3].freeze } }
    end
  end
end
