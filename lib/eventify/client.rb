# frozen_string_literal: true

require 'json'
require 'faraday'

module Eventify
  EventifyError = Class.new(StandardError)
  InvalidTokenError = Class.new(EventifyError)
  ServiceUnavailable = Class.new(EventifyError)

  # Client that allows to publish events
  class Client
    def initialize(api_key: nil, logger: nil, raise_error: false)
      @api_key = api_key || ENV['EVENTIFY_API_KEY']
      @logger = logger
      @raise_error = raise_error
    end

    def publish(type:, data: {})
      events_url = "#{base_uri}/events"

      response = http_client.post(
        events_url, { type: type, data: data }, headers
      )
      puts response.inspect
    end

    private

    attr_reader :api_key, :logger, :raise_error

    def http_client
      @http_client || Faraday
    end

    def headers
      {
        'Authorization' => api_key,
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def base_uri
      'http://localhost:3000'
    end
  end
end
