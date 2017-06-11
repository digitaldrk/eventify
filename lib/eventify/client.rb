# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'eventify/version'
require 'json'

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

    def publish(data)
      response_body = post_request(data, 'events')
      return true unless raise_error == true
      throw_error(response_body)
    end

    private

    attr_reader :api_key, :logger, :raise_error

    def throw_error(response_body)
      return true unless response_body.include?('error_message')
      raise Eventify::EventifyError, response_body['error_message']
    end

    def post_request(request_body, end_point)
      events_url = "#{base_uri}/#{end_point}"

      uri = URI.parse(events_url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, headers)

      request.set_form_data(
        type: request_body[:type],
        data: request_body[:data]
      )
      response = http.request(request)
      JSON.parse(response.body)
    end

    def headers
      {
        'Authorization' => api_key,
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def base_uri
      'http://api.eventify.pro'
    end
  end
end
