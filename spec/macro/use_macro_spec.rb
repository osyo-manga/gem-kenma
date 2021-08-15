# frozen_string_literal: true

require "kenma/macro/frozen_constant"

RSpec.describe Kenma::Macro::UseMacro do
  using Kenma::Refine::Source

  describe "use_macro!" do
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

    subject { Kenma.compile(body) }

    let(:body) { proc {
      use_macro! CatMacro
      puts cat! + cat!
    } }
    it { is_expected.to eq_ast { puts catcat + catcat } }

    context "multi use_macro" do
      let(:body) { proc {
        use_macro! CatMacro
        use_macro! DogMacro

        puts cat! + dog!
      } }
      it { is_expected.to eq_ast { puts catcat + dogdog } }
    end

    context "overwrite use_macro" do
      module CatMacro2
        using Kenma::Macroable

        def cat!
          ast { catcat2 }
        end
        macro_function :cat!
      end

      context "same scope" do
        let(:body) { proc {
          use_macro! CatMacro
          use_macro! CatMacro2

          puts cat!
          proc {
            puts cat!
          }
        } }
        it { is_expected.to eq_ast {
          puts catcat2
          proc {
            puts catcat2
          }
        } }
      end

      context "other scope" do
        let(:body) { proc {
          use_macro! CatMacro
          puts cat!

          proc {
            use_macro! CatMacro2
            puts cat!
          }

          puts cat!
        } }
        it { is_expected.to eq_ast {
          puts catcat
          proc {
            puts catcat2
          }
          puts catcat
        } }
      end

      xcontext "re use_macro" do
        let(:body) { proc {
          use_macro! CatMacro
          use_macro! CatMacro2
          use_macro! CatMacro

          puts cat!
        } }
        it { is_expected.to eq_ast { puts catcat } }
      end

      xcontext "re use_macro in other scope" do
        let(:body) { proc {
          use_macro! CatMacro
          use_macro! CatMacro2

          puts cat!
          proc {
            use_macro! CatMacro
            puts cat!
          }
        } }
        it { is_expected.to eq_ast {
          puts catcat2
          proc {
            puts catcat
          }
        } }
      end
    end

    context "use_macro! only" do
      let(:body) { proc {
        use_macro! CatMacro
      } }
      it { is_expected.to eq_ast {} }
    end
  end
end
