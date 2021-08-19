# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma do
  using Kenma::Refine::Source

  describe ".compile" do
    module CatMacro
      using Kenma::Macroable

      def cat!
        ast { catcat }
      end
      macro_function :cat!
    end

    subject { Kenma.compile(body) }

    context "with use_macro!" do
      let(:body) { proc {
        use_macro! CatMacro
        puts cat! + cat!
      } }
      it { is_expected.to eq_ast { puts catcat + catcat } }
    end
  end

  describe "scope_context" do
    subject { Kenma::Macro::Core.convert_of(body) }
    module CatMacro
      using Kenma::Macroable

      def cat!
        ast { catcat }
      end
      macro_function :cat!
    end

    module DogMacro
      using Kenma::Macroable

      def dog!(num = ast { 1 })
        ast { dogdog }
      end
      macro_function :dog!
    end

    let(:body) {
      proc {
        class X
          use_macro! CatMacro
          dog!
          cat!

          def hoge
            use_macro! DogMacro

            dog!
            cat!
          end
          dog!

          proc {
            use_macro! DogMacro
            dog!
            cat!
          }
          dog!

          use_macro! DogMacro
          proc {
            dog!
            cat!
          }
        end
        dog!
        cat!
      }
    }
    it { is_expected.to eq_ast {
        class X
          dog!
          catcat

          def hoge
            dogdog
            catcat
          end
          dog!

          proc {
            dogdog
            catcat
          }
          dog!

          proc {
            dogdog
            catcat
          }
        end
        dog!
        cat!
      }
    }

    context "MacroModule within NODE_SCOPE" do
      module NodeScopeMacro
        using Kenma::Macroable

        def NODE_SCOPE(node, parent)
          body = node.children.last
          [:SCOPE, [*node.children.take(node.children.size-1), ast { node_scope; $body }]]
        end
      end

      let(:body) { proc {
        use_macro! NodeScopeMacro

        def hoge
          proc {
            foo
          }
        end
      } }
      it { is_expected.to eq_ast {
        def hoge
          node_scope
          proc {
            node_scope
            foo
          }
        end
      } }
    end
  end

  describe ".ast" do
    using Kenma::Macroable

    let(:context) { {} }
    subject { ast(context, &body) }

    context "1 + 2" do
      let(:body) { proc { 1 + 2 } }
      it { is_expected.to have_attributes(type: :OPCALL) }
      it { is_expected.to eq_ast &body }
    end

    context "puts 42" do
      let(:body) { proc { puts 42 } }
      it { is_expected.to have_attributes(type: :FCALL) }
      it { is_expected.to eq_ast &body }
    end

    context "stringify! 1 + 2" do
      let(:body) { proc { stringify! 1 + 2 } }
      it { expect(subject.type).to eq :LIT }
      it { is_expected.to eq_ast { "(1 + 2)" } }
    end

    context "with context" do
      let(:cat_macro) {
        Module.new {
          def cat!
            ast { catcat }
          end
          macro_function :cat!
        }
      }
      let(:context) {
        { use_macros: [cat_macro] }
      }
      let(:body) { proc { puts cat! } }
      it { is_expected.to eq_ast { puts catcat } }
    end
  end
end
