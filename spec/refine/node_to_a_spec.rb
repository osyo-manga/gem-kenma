# frozen_string_literal: true

require "kenma/refine/node_to_a"

RSpec.describe Kenma::Refine::NodeToArray do
  using Kenma::Refine::Source
  using Kenma::Refine::NodeToArray

  describe RubyVM::AbstractSyntaxTree::Node do
    subject { node.to_a }
    let(:node) { RubyVM::AbstractSyntaxTree.parse("42.foo.bar").children.last }
    it { is_expected.to eq [:CALL, [[:CALL, [[:LIT, [42]], :foo, nil]], :bar, nil]] }
  end

  describe Array do
    subject { array.to_a }
    let(:array) {
      [:CALL, [[:CALL, [RubyVM::AbstractSyntaxTree.parse("1").children.last, :foo, nil]], :bar, nil]]
    }
    it { is_expected.to eq [:CALL, [[:CALL, [[:LIT, [1]], :foo, nil]], :bar, nil]] }
  end
end
