require File.expand_path(__dir__ + '/spec_helper')

describe Fluent::JubatusOutput do
  let(:fluentd){ Fluent::Test::TestDriver.new(described_class) }
  let(:config){
    %[
      type jubatus
      client_api classifier
      host 127.0.0.1
      port 9199
      str_keys first, second, third
      num_keys ichi, ni, san
      learn_analyze analyze
    ]
  }

  context 'set config params' do
    let(:conf){ fluentd.configure(config).instance }
    it 'string keys' do
      expect(conf.instance_variable_get(:@keys)[:str]).to eq(['first','second','third'])
    end

    it 'number keys' do
      expect(conf.instance_variable_get(:@keys)[:num]).to eq(['ichi','ni','san'])
    end


    it 'client api' do
      expect(conf.client_api).to eq('classifier')
    end

    it 'host' do
      expect(conf.host).to eq('127.0.0.1')
    end

    it 'port' do
      expect(conf.port).to eq('9199')
    end

    it 'learn or analyze' do
      expect(conf.learn_analyze).to eq('analyze')
    end
  end

  context 'fluentd' do
    let(:classifier){ fluend.configure(config) }
    let(:data){ {first: '10', second: 10, third: "abcd", ichi: 1, ni: "-2", san: '3.0'} }
    it 'emit' do
      
    end
  end
end

