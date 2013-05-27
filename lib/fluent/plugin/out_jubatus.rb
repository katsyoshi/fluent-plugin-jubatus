module Fluent
class JubatusOutput < Output
  Plugin.register_output('jubatus', self)
  config_param :host, :string, :default => '127.0.0.1'
  config_param :port, :string, :default => '9199'
  config_param :name, :string, :default => ''
  config_param :str_keys, :string, :defult => ''
  config_param :num_keys, :string

  def initialize
    require 'jubatus/classifier/client'
    require 'jubatus/classifier/types'
    @type = 'classifier'
    @learn_analyze = 'analyze'
    super
  end

  def configure(conf)
    super
    @str = @str_keys.split(/,/).map{|str| str.strip}
    @num = @num_keys.split(/,/).map{|num| num.strip}
  end

  def start
    super
    @jubatus = Jubatus::Classifier::Client::Classifier.new(@host, @host.to_i)
  end

  def shutdown
    super
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      jubatus_run(record)
    end

    chain.next
  end

  def jubatus_run(key_values)
    str = []
    num = []
    key_values.each do |key, value|
      str << [key, value] if @str.include?(key)
      num << [key, value] if @num.include?(key)
    end
    datum = Jubatus::Classifier::Datum.new(str, num)
    if @learn_analyze =~ /^analyze$/i
      analyze(datum)
    elsif @learn_analyze =~ /^train$/i
      update(datum)
    end
  end

  private
  def analyze(datum)
    @jubatus.classifier(@name, [datum])
  rescue => e
    e
  end

  def update(datum)
    @jubatus.train(@name, [datum])
  rescue => e
    e
  end
end
end
