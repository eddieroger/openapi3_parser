# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject
    class Server
      include Node::Object

      # @return [String]
      def url
        node_data["url"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [Map<String, ServerVariable>]
      def variables
        node_data["variables"]
      end
    end
  end
end
