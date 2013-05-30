module Fluent
class JubatusOutput < Output
  Plugin.register_output('jubatus', self)
  config_param :host, :string, :default => '127.0.0.1'
  config_param :port, :string, :default => '9199'
  config_param :name, :string, :default => ''
  config_param :str_keys, :string, :default => ''
  config_param :num_keys, :string, :default => ''
  config_param :learn_analyze, :string, :default => 'analyze'
  config_param :tag, :string, :default => 'jubatus'

  def initialize
    require 'jubatus/classifier/client'
    require 'jubatus/classifier/types'
    super
  end

  def configure(conf)
    super
    @str = @str_keys.split(/,/).map{|str| str.strip}
    @num = @num_keys.split(/,/).map{|num| num.strip}
  end

  def start
    super
    @jubatus = Jubatus::Classifier::Client::Classifier.new(@host, @port.to_i)
  end

  def shutdown
    super
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      Engine.emit(@tag, time, jubatus_run(record))
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
    @jubatus.classify(@name, [datum])
  rescue => e
    e
  end

  def update(datum)
    @jubatus.train(@name, [datum])
  rescue => e
    e
  end

  def set_datum(data)
    str = []
    num = []
    data.each do |key, value|
      str << [key, value] if @str.include?(key)
      num << [key, value] if @num.include?(key)
    end
    Jubatus::Classifier::Datum.new(str, num)
  end
end
end
