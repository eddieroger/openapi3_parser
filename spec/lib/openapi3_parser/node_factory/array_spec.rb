# frozen_string_literal: true

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Array do
  include Helpers::Context
  let(:context) { create_context(input) }
  let(:input) { [] }

  let(:default) { [] }
  let(:value_input_type) { nil }
  let(:value_factory) { nil }
  let(:validate) { nil }
  let(:instance) do
    described_class.new(context,
                        default: default,
                        value_input_type: value_input_type,
                        value_factory: value_factory,
                        validate: validate)
  end

  it_behaves_like "node factory", ::Array

  describe "non array input" do
    subject { instance }
    let(:input) { "a string" }
    it "doesn't raise an error" do
      expect { instance }.not_to raise_error
    end

    it { is_expected.not_to be_valid }
  end

  describe "#node" do
    subject(:node) { instance.node }

    it { is_expected.to be_a(Openapi3Parser::Node::Array) }

    context "when input is expected to contain hashes" do
      let(:input) { [{}, 1] }
      let(:value_input_type) { Hash }

      it "raises an InvalidType error" do
        error_type = Openapi3Parser::Error::InvalidType
        error_message = "Invalid type for #/1: Expected Object"
        expect { instance.node }
          .to raise_error(error_type, error_message)
      end
    end

    context "when input is nil and default is an array" do
      let(:input) { nil }
      let(:default) { [] }

      it { is_expected.to be_a(Openapi3Parser::Node::Array) }
    end

    context "when input is nil and default is nil" do
      let(:input) { nil }
      let(:default) { nil }

      it { is_expected.to be_nil }
    end

    context "when value_factory is set" do
      let(:value_factory) { Openapi3Parser::NodeFactory::Contact }
      let(:input) do
        [
          { "name" => "Kenneth" }
        ]
      end
      subject(:item) { instance.node.first }

      it "returns items created by the value factory" do
        expect(item).to be_a(Openapi3Parser::Node::Contact)
      end
    end

    context "when validation is set and failing" do
      let(:validate) do
        ->(validatable) { validatable.add_error("Fail") }
      end

      it "raises an error" do
        expect { node }.to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end
end
