# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Eventify::Client do
  context '#publish' do
    let(:instance_with_error) do
      Eventify::Client.new(api_key: 'secret_token', raise_error: true)
    end

    let(:instance_without_error) do
      Eventify::Client.new(api_key: 'secret_token')
    end

    let(:data) do
      { 'type': 'Event Type String',
        'data': { 'data stuff': 'more data stuff' } }
    end

    let(:response) do
      { 'created_at' => 'date',
        'data' => '{:\"data stuff\"=>\"more data stuff\"}',
        'id' => '65a2edc8-6342-4285-9ccd-f6a1d13ef7b8',
        'type' => 'Event Type String' }
    end

    it 'successful' do
      allow(instance_with_error).to receive(:publish).with(data) { true }

      expect(instance_with_error.publish(data)).to eq(true)
    end

    it 'unsuccessful' do
      allow(instance_without_error).to receive(:publish).with('foo') { true }

      expect(instance_without_error.publish('foo')).to eq(true)
    end

    it 'raises an exception' do
      expect { instance_with_error.publish(bad_data: 'foo') }
        .to raise_error(Eventify::EventifyError)
    end
  end
end
