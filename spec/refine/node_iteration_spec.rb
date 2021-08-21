# frozen_string_literal: true

RSpec.describe Kenma::Refine::NodeIteration do
  using Kenma::Refine::Source

  describe "#each_node" do
    using Kenma::Refine::NodeIteration
    subject { node.each_node }
    before do
      expect(Kenma::Iteration).to receive(:each_node)
    end
    context "RubyVM::AbstractSyntaxTree::Node" do
      let(:node) { RubyVM::AbstractSyntaxTree.parse("hoge") }
      it { subject }
    end
    context "Array" do
      let(:node) { [] }
      it { subject }
    end
  end

  describe "#convert_node" do
    using Kenma::Refine::NodeIteration
    subject { node.convert_node }
    before do
      expect(Kenma::Iteration).to receive(:convert_node)
    end
    context "RubyVM::AbstractSyntaxTree::Node" do
      let(:node) { RubyVM::AbstractSyntaxTree.parse("hoge") }
      it { subject }
    end
    context "Array" do
      let(:node) { [] }
      it { subject }
    end
  end

  describe "#find_convert_node" do
    using Kenma::Refine::NodeIteration
    subject { node.find_convert_node(nil) }
    before do
      expect(Kenma::Iteration).to receive(:find_convert_node)
    end
    context "RubyVM::AbstractSyntaxTree::Node" do
      let(:node) { RubyVM::AbstractSyntaxTree.parse("hoge") }
      it { subject }
    end
    context "Array" do
      let(:node) { [] }
      it { subject }
    end
  end
end
