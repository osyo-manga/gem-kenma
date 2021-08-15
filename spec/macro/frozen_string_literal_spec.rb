# frozen_string_literal: true

require "kenma/macro/frozen_string_literal"

RSpec.describe Kenma::Macro::FrozenStringLiteral do
  using Kenma::Refine::Source

  describe "frozen string literal" do
    subject { Kenma.compile(body) }

    context "defined string literals" do
      let(:body) {
        proc {
          use_macro! Kenma::Macro::FrozenStringLiteral
          puts "にゃーん"
        }
      }
      it { is_expected.to eq_ast { puts "にゃーん".freeze } }
    end
  end
end
