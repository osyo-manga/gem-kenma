# frozen_string_literal: true

RSpec.describe Kenma::NodeConverter do
  using Kenma::Refine::Source
  using Kenma::Macroable

  describe "#node_missing" do
    context "defined NODE_XXX" do
      context "args value and return value same" do
        let(:klass) {
          Class.new(Kenma::NodeConverter) {
            def NODE_VCALL(node, parent)
              node
            end

            def node_missing(node, parent)
              node
            end
          }
        }
        let(:converter) { klass.new }
        before do
          expect(converter).to receive(:node_missing)
        end
        it { converter.convert(ast { vcall }.children.last) }
      end

      context "args value and return value different" do
        let(:klass) {
          Class.new(Kenma::NodeConverter) {
            def NODE_VCALL(node, parent)
              ast { vcall }
            end

            def node_missing(node, parent)
              node
            end
          }
        }
        let(:converter) { klass.new }
        before do
          expect(converter).not_to receive(:node_missing)
        end
        it { converter.convert(ast { vcall }.children.last) }
      end
    end
  end
end
