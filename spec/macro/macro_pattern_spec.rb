# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::MacroFunction do
  using Kenma::Refine::Source
  using Kenma::Macroable

  describe ".macro_pattern" do
    subject { Kenma.compile(body) }

    context "define single pat" do
      let(:macro_module) {
        Module.new {
          def cat!(node)
            ast { "にゃーん" }
          end
          macro_pattern pat { cat! }, :cat!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        cat!
      } }
      it { is_expected.to eq_ast { "にゃーん" } }
    end

    context "defined other pat" do
      let(:macro_module) {
        Module.new {
          def cat!(node)
            ast { "にゃーん" }
          end
          macro_pattern pat { cat! }, :cat!

          def cat2!(node, num:)
            ast { "にゃーん2" * $num }
          end
          macro_pattern pat { cat!($num) }, :cat2!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        cat!
        cat!(20)
      } }
      it { is_expected.to eq_ast {
        "にゃーん"
        "にゃーん2" * 20
      } }
    end

    context "overwrite macro_pattern" do
      let(:macro_module) {
        Module.new {
          def cat!(node)
            ast { "にゃーん" }
          end
          macro_pattern pat { cat! }, :cat!

          def cat2!(node)
            ast { "にゃーん2" }
          end
          macro_pattern pat { cat! }, :cat2!
        }
      }

      let(:body) { proc {
        use_macro! macro_module
        cat!
      } }
      it { is_expected.to eq_ast { "にゃーん2" } }
    end
  end

  describe Kenma::PatternCapture do
    using Kenma::Macroable

    describe "#match" do
      subject { pattern.match(target) }

      define_method(:ast) { |&block|
        RubyVM::AbstractSyntaxTree.of(block).children.last
      }
      it { expect(pat { 1 + 2 } === ast { 1 + 2 }).to eq({}) }
      it { expect(pat { 1 + 2 } === ast { 1 - 2 }).to be_nil }
      it { expect(pat { cat! } === ast { cat! }).to eq({}) }
      it { expect(pat { cat! } === ast { cat!(2) }).to be_nil }
      it { expect(pat { cat!($num) } === ast { cat!(1) }).to match num: eq_ast { 1 } }
      it { expect(pat { $left + $right } === ast { 1 + 2 }).to match left: eq_ast { 1 }, right: eq_ast { 2 } }
      it { expect(pat { $name = $value } === ast { name = 42 }).to match name: :name, value: eq_ast { 42 } }
      it { expect(pat { $name = 10 } === ast { name = 42 }).to be_nil }
      it { expect(pat { $name[$index] = $value } === ast { users[1] = 42 }).to match name: eq_ast { users }, index: eq_ast { 1 }, value: eq_ast { 42 } }
      it { expect(pat { $name[1] = $value } === ast { users[1] = 42 }).to match name: eq_ast { users }, value: eq_ast { 42 } }
      it { expect(pat { $name[1] = $value } === ast { users[2] = 42 }).to be_nil }
      it { expect(pat { $a < $b < $c } === ast { min < a < max }).to match a: eq_ast { min }, b: eq_ast { a }, c: eq_ast { max } }
    end
  end
end
