# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Eventify::Client do
  it 'creates client' do
    expect { Eventify::Client.new }.not_to raise_error
  end
end
