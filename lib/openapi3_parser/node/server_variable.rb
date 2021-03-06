# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverVariableObject
    class ServerVariable < Node::Object
      # @return [Node::Array<String>, nil]
      def enum
        node_data["enum"]
      end

      # @return [String]
      def default
        node_data["default"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end
    end
  end
end
