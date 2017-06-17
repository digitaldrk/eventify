# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Eventify::Client do
  let(:base_uri) { Eventify::Client::BASE_URI }

  context '#publish' do
    let(:event_type) { 'ProfileCreated' }
    let(:event_data) { { 'name': 'John', 'email': 'john@doe.com' } }

    let(:expected_request) do
      {
        body: { type: event_type, data: event_data.to_json },
        headers: {
          'Authorization' => 'secret',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      }
    end

    let(:response) do
      '{
         "id": "a98185f9-61a2-44f2-93d0-1dfd8f7a7790",
         "type": "ProfileCreated",
         "data": "{\"name\":  \"John\", \"email\":  \"john@doe.com\"}",
         "created_at": "2017-06-07 18:28:59"
      }'
    end

    let(:response_with_error) { '{ "error_message": "Invalid Token" }' }
    let(:invalid_response) { 'foo' }

    context 'with raise_errors = true' do
      let(:client) do
        described_class.new(api_key: 'secret', raise_errors: true)
      end

      context '#publish' do
        context 'with successful response from API' do
          it 'returns true' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request).to_return(body: response, status: 200)

            expect(
              client.publish(type: event_type, data: event_data)
            ).to be_truthy

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'with error response from API' do
          it 'raises an Eventify::Error' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request)
              .to_return(body: response_with_error, status: 401)

            expect do
              client.publish(type: event_type, data: event_data)
            end.to raise_error(Eventify::Error, 'Invalid Token')

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'with invalid response from API' do
          it 'raises an Eventify::Error' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request)
              .to_return(body: invalid_response, status: 401)

            expect do
              client.publish(type: event_type, data: event_data)
            end.to raise_error(
              Eventify::Error, 'Could not process response from Eventify'
            )

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'when API is unavailable' do
          it 'raises an Eventify::ServiceUnavailableError' do
            stub_request(:post, "#{base_uri}/events").to_timeout
            expect do
              client.publish(type: event_type, data: event_data)
            end.to raise_error(
              Eventify::ServiceUnavailableError,
              'Eventify is currently unavaliable'
            )
            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
          end
        end
      end
    end

    context 'with raise_errors = false (default)' do
      let(:client) { described_class.new(api_key: 'secret') }

      context '#publish' do
        context 'with successful response from API' do
          it 'returns true' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request).to_return(body: response, status: 200)

            expect(
              client.publish(type: event_type, data: event_data)
            ).to be_truthy

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'with error response from API' do
          it 'returns false' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request)
              .to_return(body: response_with_error, status: 401)

            expect(client.publish(type: event_type, data: event_data)).to(
              be_falsey
            )

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'with invalid response from API' do
          it 'returns false' do
            stub_request(:post, "#{base_uri}/events")
              .with(expected_request)
              .to_return(body: invalid_response, status: 401)

            expect(client.publish(type: event_type, data: event_data)).to(
              be_falsey
            )

            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
              .with(expected_request).once
          end
        end

        context 'when API is unavailable' do
          it 'returns false' do
            stub_request(:post, "#{base_uri}/events").to_timeout
            expect(client.publish(type: event_type, data: event_data)).to(
              be_falsey
            )
            expect(WebMock).to have_requested(:post, "#{base_uri}/events")
          end
        end
      end
    end
  end
end
