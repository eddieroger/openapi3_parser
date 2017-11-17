# frozen_string_literal: true

require "openapi_parser/nodes/oauth_flow"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class OauthFlow
      include NodeFactory::Object

      allow_extensions
      field "authorizationUrl", input_type: String, required: true
      field "tokenUrl", input_type: String, required: true
      field "refreshUrl", input_type: String
      field "scopes", input_type: Hash, required: true

      private

      def build_object(data, context)
        Nodes::OauthFlow.new(data, context)
      end
    end
  end
end
