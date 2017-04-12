require 'rails_helper'
require 'webmock/rspec'
require 'yaml'

describe 'dynamic class' do
  before(:each) do
    @apis = YAML.load_file('apis.yml')
  end

  it 'is defined' do
    @apis.each do |api|
      expect { Object.const_get api['api_class'] }.to_not raise_error
    end
  end

  it 'has .run method defined' do
    @apis.each do |api|
      expect(api['api_class'].constantize).to respond_to :run
    end
  end

  it 'creates MyParentApi object with .run method' do
    @apis.each do |api|
      stub_request(:get, api['url'])
        .to_return(status: 200, body: api['parameter_map'].to_json, headers: {})
      expect { api['api_class'].constantize.run }.to change { MyParentApi.count }.by(1)
      expect(MyParentApi.last.internal_param1).to eq('internal_param1')
      expect(MyParentApi.last.internal_param2).to eq('internal_param2')
    end
  end
end