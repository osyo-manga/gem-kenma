# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::UseMacro do
  using Kenma::Refine::Source

  describe "symbolify!" do
    subject { Kenma.compile_of(body) }

    let(:body) {
      proc {
        symbolify! tag
      }
    }
    it { is_expected.to eq_ast { :tag } }

    context "with space" do
      subject { Kenma.compile_of(body) }

      let(:body) {
        proc {
          symbolify! tag + bar
        }
      }
      it { is_expected.to eq_ast { :"(tag + bar)" } }
    end

    context "string" do
      let(:body) {
        proc {
          symbolify! "1 + 2"
        }
      }
      it { is_expected.to eq_ast { :"\"1 + 2\"" } }
    end

    context "with node_bind!" do
      let(:body) {
        node = RubyVM::AbstractSyntaxTree.parse("tag")
        proc {
          symbolify! $node
        }
      }
      it { is_expected.to eq_ast { :tag } }
    end
  end

  describe "stringify!" do
    subject { Kenma.compile_of(body) }

    let(:body) {
      proc {
        stringify! 1 + 2
      }
    }
    it { is_expected.to eq_ast { "(1 + 2)" } }

    context "with node_bind!" do
      let(:body) {
        node = RubyVM::AbstractSyntaxTree.parse("1 + 2 * 3")
        proc {
          stringify! $node
        }
      }
      it { is_expected.to eq_ast { "(1 + (2 * 3))" } }
    end
  end

  describe "unstringify!" do
    subject { Kenma.compile_of(body) }

    let(:body) {
      proc {
        unstringify! "cat"
      }
    }
    it { is_expected.to eq_ast { cat } }

    context "with node_bind!" do
      let(:body) {
        node = RubyVM::AbstractSyntaxTree.parse("'cat'")
        proc {
          unstringify! $node
        }
      }
      it { is_expected.to eq_ast { cat } }
    end
  end

  describe "node_bind!" do
    subject { Kenma.compile_of(body) }

    context "defined AST::Node variable" do
      let(:body) {
        value = RubyVM::AbstractSyntaxTree.parse("1")
        proc {
          node_bind!(value)
        }
      }
      it { is_expected.to eq_ast { 1 } }
    end

    context "defined non AST::Node variable" do
      let(:body) {
        value = 42
        proc {
          node_bind!(value)
        }
      }
      it { is_expected.to eq_ast { 42 } }
    end

    context "undefined variable" do
      let(:body) {
        proc {
          node_bind!(value)
        }
      }
      it { expect { subject }.to raise_error(NameError) }
    end
  end

  describe "$variable" do
    subject { Kenma.compile_of(body) }

    context "defined $node variable" do
      let(:body) {
        node = RubyVM::AbstractSyntaxTree.parse("1")
        proc {
          puts $node
        }
      }
      it { is_expected.to eq_ast { puts 1 } }
    end

    context "defined non AST::Node variable" do
      let(:body) {
        node = 42
        proc {
          puts $node
        }
      }
      it { is_expected.to eq_ast { puts 42 } }
    end

    context "undefined variable" do
      let(:body) {
        proc {
          $node
        }
      }
      it { is_expected.to eq_ast { $node } }
    end
  end
end
