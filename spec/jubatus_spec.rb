require File.expand_path(__dir__ + '/spec_helper')

describe FluentdJubatus do
  let(:fluent_conf){ {host: '127.0.0.1', port: 9199, name: ''} }
  let(:data){ {a: 'a', b: '1', c: '1.0', d: '-1.0', e: 'f', f: '1,', g: 'str'} }
  let(:keys){ {str:['a','e'], num:['b','c','d']} }
  let(:label){ 'fluentd' }
  let(:jubatus){
    described_class.new(type, fluent_conf[:host], fluent_conf[:port], fluent_conf[:name])
  }
  let(:datum){ jubatus.set_datum(data, keys) }
  let(:raw_jubatus){ jubatus.instance_variable_get(:@jubatus) }
  let(:result){ described_class.fix_result(type, jubatus.analyze(type, datum)) }
  let(:log){ File.expand_path(__dir__) }
  # This test run only in ubuntu or debian using deb package
  let(:ubuntu){ "/opt/jubatus/share/jubatus/example/config/#{type}" }

  def startup(path, jubatus_type: type, config_path: path, jubatus_log: log, jubatus_port: fluent_conf[:port])
    @pid = spawn("juba#{jubatus_type} -f #{config_path} -l #{jubatus_log} -p #{jubatus_port}")
    sleep 0.1
  end

  def stop_jubatus
    Process.kill(9, @pid)
    Process.wait(@pid)
    Dir.glob("./spec/juba#{type}.*").each do |f|
      File.delete(File.expand_path(f))
    end
  end

  context 'anomaly' do
    let(:type){ 'anomaly' }

    before{
      startup(ubuntu+'/lof.json')
      raw_jubatus.update(label, datum)
    }
    after{ stop_jubatus }

    it 'analyze' do
      expect(jubatus.analyze(type, datum)).to eq(1.to_f)
    end

    it 'fix results' do
      expect(result).to eq(1.to_f)
    end
  end

  context 'classifier' do
    let(:type){ 'classifier' }

    before{
      startup(ubuntu+'/arow.json')
      raw_jubatus.train([[label,datum]])
    }
    after {
      stop_jubatus
    }

    it 'analyze' do
      expect(jubatus.analyze(type, datum).first.first.label).to eq(label)
    end

    it 'fix results' do
      expect(result.size).to eq(1)
    end
  end

  context 'clustering' do
    let(:type){ 'clustering' }
    before{
      startup(ubuntu+'/kmeans.json')
      1000.times do
        raw_jubatus.push([datum])
      end
    }
    after {
      stop_jubatus
    }

    it 'analyze' do
      expect(jubatus.analyze(type, datum)).to be_true
    end

    it 'fix results' do
      pending('which do you need results in nearest center point, or nearest cluster members?')
      expect(result.size).to eq(1)
    end
  end

  context 'recommender' do
    let(:type){ 'recommender' }

    before{
      startup(ubuntu+'/inverted_index.json')
      raw_jubatus.update_row(label,datum)
    }
    after {
      stop_jubatus
    }

    it 'analyze' do
      expect(jubatus.analyze(type, datum).first.score).to eq(1)
    end

    it 'fix results' do
      expect(result.size).to eq(1)
    end
  end
end
