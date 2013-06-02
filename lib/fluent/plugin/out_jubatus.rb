module Fluent
class JubatusOutput < Output
  Plugin.register_output('jubatus', self)
  config_param :client_api, :string, :default => 'classifier'
  config_param :host, :string, :default => '127.0.0.1'
  config_param :port, :string, :default => '9199'
  config_param :name, :string, :default => ''
  config_param :str_keys, :string, :default => ''
  config_param :num_keys, :string, :default => ''
  config_param :learn_analyze, :string, :default => 'analyze'
  config_param :tag, :string, :default => 'jubatus'

  def initialize
    super
    require 'jubatus/classifier/client'
    require 'jubatus/classifier/types'
    require 'jubatus/anomaly/client'
    require 'jubatus/anomaly/types'
    require 'jubatus/recommender/client'
    require 'jubatus/recommender/types'
  end

  def configure(conf)
    super
    @str = @str_keys.split(/,/).map{|str| str.strip}
    @num = @num_keys.split(/,/).map{|num| num.strip}
  end

  def start
    super
  end

  def shutdown
    super
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      result = result_format(jubatus_run(record))
      Engine.emit(@tag, time, result)
    end

    chain.next
  end

  private
  def jubatus_run(data)
    datum = set_datum(data)
    if @learn_analyze =~ /^analyze$/i
      analyze(datum)
    elsif @learn_analyze =~ /^train$/i
      update(datum)
    end
  end

  def analyze(datum)
    case
    when @client_api =~ /^classif(y|ier)$/i
      classify(datum)
    when @client_api =~ /^anomaly$/i
      anomaly(datum)
    when @client_api =~ /^recommender/i
      recommend(datum)
    end
  rescue => e
    e
  end

  def update(datum)
    jubatus = Jubatus::Classifier::Client::Classifier.new(@host, @port.to_i)
    jubatus.train(@name, [datum])
    jubatus.get_client.close
  rescue => e
    e
  end

  def set_datum(data)
    str = []
    num = []
    data.each do |key, value|
      str << [key, value.to_s] if @str.include?(key)
      num << [key, value.to_f] if @num.include?(key)
    end
    case
    when @client_api =~ /^classif(y|ier)$/i
      Jubatus::Classifier::Datum.new(str, num)
    when @client_api =~ /^anomaly$/i
      Jubatus::Anomaly::Datum.new(str, num)
    end
  end

  def result_format(data)
    case
    when @client_api =~ /^classifier$/i
      result_classify(data)
    when @client_api =~ /^anomaly$/i
      result_anomaly(data)
    end
  end

  def classify(datum)
    jubatus = Jubatus::Classifier::Client::Classifier.new(@host, @port.to_i)
    result = jubatus.classify(@name, [datum])
    jubatus.get_client.close()
    result
  rescue => e
    e
  end

  def anomaly(datum)
    jubatus = Jubatus::Anomaly::Client::Anomaly.new(@host, @port.to_i)
    result = jubatus.add(@name, datum)
    jubatus.get_client.close()
    result
  rescue => e
    e
  end

  def result_classify(data)
    result = {}
    data.map do |datum|
      datum.map do |est|
        result[est[0]] = est[1]
      end
    end
    result
  end

  def result_anomaly(data)
    value = data[1]
    value = data[1].to_s if data[1].to_s == "Infinity"
    { id: data[0], value: value }
  end
end
end
