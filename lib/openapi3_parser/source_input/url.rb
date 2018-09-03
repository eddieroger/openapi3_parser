# frozen_string_literal: true

require "open-uri"
require "openapi3_parser/source_input"

module Openapi3Parser
  class SourceInput
    # An input of a URL to an OpenAPI file
    #
    # @attr_reader [String] request_url   The URL that will be requested
    # @attr_reader [String] resolved_url  The eventual URL of the file that was
    #                                     accessed, this may differ to the
    #                                     request_url in the case of redirects
    class Url < SourceInput
      attr_reader :request_url, :resolved_url

      # @param [String, URI] request_url
      def initialize(request_url)
        @request_url = request_url.to_s
        initialize_contents
      end

      # @see SourceInput#resolve_next
      # @param  [Source::Reference] reference
      # @return [SourceInput]
      def resolve_next(reference)
        ResolveNext.call(reference, self, base_url: resolved_url)
      end

      # @see SourceInput#other
      # @param  [SourceInput] other
      # @return [Boolean]
      def ==(other)
        return false unless other.instance_of?(self.class)
        [request_url, resolved_url].include?(other.request_url) ||
          [request_url, resolved_url].include?(other.resolved_url)
      end

      # return [String]
      def url
        resolved_url || request_url
      end

      # return [String]
      def inspect
        %{#{self.class.name}(url: #{url})}
      end

      # @return [String]
      def to_s
        request_url
      end

      # @return [String]
      def relative_to(source_input)
        other_url = if source_input.respond_to?(:url)
                      source_input.url
                    elsif source_input.respond_to?(:base_url)
                      source_input.base_url
                    end

        return url unless other_url

        other_url ? RelativeUrlDifference.call(other_url, url) : url
      end

      private

      def parse_contents
        uri = URI.parse(request_url)

        unless uri.absolute?
          @access_error = Error::InaccessibleInput.new(
            "Can't open a relative URI - #{uri}"
          )
          return
        end

        unless uri.respond_to?(:open)
          @access_error = Error::InaccessibleInput.new(
            "Don't know how to open URI's with a scheme of #{uri.scheme}"
          )
          return
        end

        file = uri.open
        @resolved_url = file.base_uri.to_s

        parse_string(file.read, resolved_url)
      rescue URI::Error => e
        @access_error = Error::InaccessibleInput.new(e)
      rescue OpenURI::HTTPError => e
        @access_error = Error::InaccessibleInput.new(e)
      end

      class RelativeUrlDifference
        def initialize(from_url, to_url)
          @from_uri = URI.parse(from_url)
          @to_uri = URI.parse(to_url)
        end

        def self.call(from_url, to_url)
          new(from_url, to_url).call
        end

        def call
          return to_uri.to_s if different_hosts?
          relative_path
        end

        private_class_method :new

        private

        attr_reader :from_uri, :to_uri

        def different_hosts?
          URI.join(from_uri, "/") != URI.join(to_uri, "/")
        end

        def relative_path
          relative = to_uri.route_from(from_uri)
          return relative.to_s unless relative.path.empty?

          # if we have same path it's nice to show just the filename
          file_and_query(to_uri)
        end

        def file_and_query(uri)
          Pathname.new(uri.path).basename.to_s +
            (uri.query ? "?#{uri.query}" : "")
        end
      end
    end
  end
end
