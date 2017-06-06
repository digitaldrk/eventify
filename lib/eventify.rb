# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'eventify/version'

# Eventify allows to publish events from Ruby applications
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

    def publish(type, data)
      events_url = "#{base_uri}/events"

      uri = URI.parse(events_url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, headers)
      request.set_form_data(type: type, data: data)
      response = http.request(request)

      puts response.body.inspect
    end

    private

    attr_reader :api_key, :logger, :raise_error

    def http_client
      @http_client || Faraday
    end

    def headers
      {
        'Authorization' => 'secret_token',
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def base_uri
      'http://localhost:3000'
    end
  end
end
