# frozen_string_literal: true

RSpec.describe Kenma::Iteration do
  using Kenma::Refine::Source

  describe ".each_node" do
    subject { Kenma::Iteration.each_node(node, &block) }
    let(:node) { RubyVM::AbstractSyntaxTree.of(body) }

    context "with block" do
      let(:body) { proc {
        a = 1
        b = 2
        proc {
          c = 3
          d = 4
        }
      } }
      let(:block) { proc { |node|
        @result ||= []
        if node.type == :DASGN_CURR
          @result << node
        end
      } }
      it { expect { subject }.to change { @result }.to be_all { |it| it.type == :DASGN_CURR } }
      it { expect { subject }.to change { @result }.to have_attributes(count: 4) }

      context "pickup types" do
        let(:body) { proc {
          a = 42
          b = a + 3
          proc {
            c = 4
            puts c
          }
        } }
        let(:block) { proc { |node|
          @result ||= []
          @result << node.type
        } }
        it do
          subject
          expect(@result).to match [
            :LIT,
            :DASGN_CURR,
            :DVAR,
            :LIT,
            eq(:LIST).or(eq :ARRAY),
            :OPCALL,
            :DASGN_CURR,
            :FCALL,
            :LIT,
            :DASGN_CURR,
            :DVAR,
            eq(:LIST).or(eq :ARRAY),
            :FCALL,
            :BLOCK,
            :SCOPE,
            :ITER,
            :BLOCK,
            :SCOPE
          ]
        end
      end
    end

    context "without block" do
      let(:body) { proc {
        a = 1
        b = 2
        proc {
          c = 3
          d = 4
        }
      } }
      let(:block) { nil }
      it do
        result = subject.select { |node| node.type == :DASGN_CURR }
        expect(result.size).to eq 4
        expect(result).to be_all { |node| node.type == :DASGN_CURR }
      end
      it { expect(subject.count).to eq 14 }
      it { expect(subject.class).to eq Enumerator }
    end
  end

  describe ".convert_node" do
    subject { Kenma::Iteration.convert_node(node, &block) }
    let(:node) { RubyVM::AbstractSyntaxTree.of(body) }

    context "with block" do
      using Kenma::Refine::Nodable

      let(:body) { proc { 1 + 2 } }
      let(:block) { proc { |node, parent|
        if node.type == :OPCALL
          @parent = parent
          left, op, right = node.children
          [:OPCALL, [left, :-, right]]
        else
          node
        end
      } }
      it { expect(subject).to eq_ast { 1 - 2 } }
      it { expect(subject).to be_kind_of Array }
      it { expect(subject[1]).to be_kind_of Array }
      it do
        expect(subject[1][2][1]).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :-,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
      it { expect { subject }.to change { @parent }.to have_attributes(type: :SCOPE) }
    end

    context "non matching" do
      let(:body) { proc { 1 - 2 } }
      let(:block) { proc { |node|
        if node.type == :HOGE
          node
        else
          node
        end
      } }
      it { expect(subject).to eq node }
      it { expect(subject).to eq_ast { 1 - 2 } }
      it { expect(subject).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it { expect(subject.children[2]).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it do
        expect(subject.children[2].children).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :-,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
    end

    context "return nil" do
      using Kenma::Refine::Nodable

      let(:body) { proc {
        1 - 2
        3 + 4
        5 - 6
      } }
      let(:block) { proc { |node|
        if node.type == :OPCALL && node.children[1] == :-
          nil
        else
          node
        end
      } }
      it { expect(subject).to eq_ast { 3 + 4 } }
      it { expect(subject).to be_kind_of Array }
      it { expect(subject[1]).to be_kind_of Array }
      it do
        expect(subject[1][2][1][0].children).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :+,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
    end

    context "hook LIT" do
      using Kenma::Refine::Nodable

      let(:body) { proc {
        1 - 2
      } }
      let(:block) { proc { |node, parent|
        if node.type == :LIT && node.children[0] == 1
          @parent1 = parent
        elsif node.type == :LIT && node.children[0] == 2
          @parent2 = parent
        end
        node
      } }
      it { expect(subject).to eq node }
      it { expect(subject).to eq_ast { 1 - 2 } }
      it { expect(subject).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it { expect(subject.children[2]).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it do
        expect(subject.children[2].children).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :-,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
      it { expect { subject }.to change { @parent1 }.to have_attributes(type: :OPCALL) }
      it { expect { subject }.to change { @parent2 }.to have_attributes(type: eq(:LIST).or(eq :ARRAY)) }
    end
  end

  describe ".find_convert_node" do
    using Kenma::Macroable
    using Kenma::Refine::Nodable

    subject { Kenma::Iteration.find_convert_node(node, pattern, &block) }
    let(:node) { RubyVM::AbstractSyntaxTree.of(body) }

    context "match pattern" do
      let(:body) { proc { 1 + 2 } }
      let(:pattern) { pat { $left + $right } }
      let(:block) { proc { |left:, right:|
        [:OPCALL, [left, :-, right]]
      } }
      it { expect(subject).to eq_ast { 1 - 2 } }
      it { expect(subject).to be_kind_of Array }
      it { expect(subject[1]).to be_kind_of Array }
      it do
        expect(subject[1][2][1]).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :-,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
    end

    context "non match pattern" do
      let(:body) { proc { 1 - 2 } }
      let(:pattern) { pat { $left + $right } }
      let(:block) { proc { |left:, right:|
        [:OPCALL, [left, :-, right]]
      } }
      it { expect(subject).to eq node }
      it { expect(subject).to eq_ast { 1 - 2 } }
      it { expect(subject).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it { expect(subject.children[2]).to be_kind_of RubyVM::AbstractSyntaxTree::Node }
      it do
        expect(subject.children[2].children).to match [
          be_kind_of(RubyVM::AbstractSyntaxTree::Node),
          :-,
          be_kind_of(RubyVM::AbstractSyntaxTree::Node)
        ]
      end
    end
  end
end
