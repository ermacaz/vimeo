require 'uri'

module Vimeo
  module Helpers
    def perform_get_with_object(path, options, klass)
      perform_request_with_object :get, path, options, klass
    end

    def perform_get(path, options)
      perform_request(:get, path, options)
    end

    def perform_patch(path, options)
      perform_request(:patch, path, options)
    end

    def perform_put(path, options)
      perform_request(:put, path, options)
    end

    def perform_delete(path, options = {})
      perform_request(:delete, path, options)
    end

    def perform_post(path, options)
      perform_request(:post, path, options)
    end

    def perform_request(method, path, options)
      client = get_client_object
      Vimeo::Request.new(client, method, path, options).perform
    end

    def perform_request_with_object(method, path, options, klass)
      client = get_client_object
      response = perform_request(method, path, options)
      if response_is_collection? response
        build_collection_from_response(response, klass)
      else
        klass.new client, response
      end
    end

    def post_upload file, ticket
			request = { file_data: file }
			perform_post(ticket.uri, ticket)
    end

    def build_collection_from_response(response, klass)
      client = get_client_object
      raw_items = response.fetch(:data)
      items = raw_items.collect do |i|
        klass.new self, i
      end

      keys    = [:page, :per_page, :pages]
      values  = response.values_at(:page, :per_page, :paging)

      options = Hash[keys.zip(values)]

      Vimeo::Collection.new(client, items, klass, options)
    end

    def response_is_collection? response
      !!response.include?(:page)
    end

    def get_client_object
      @client || self
    end
  end
end