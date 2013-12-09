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
    require 'fluent/plugin/jubatus'
  end

  def configure(conf)
    super
    str = @str_keys.split(/,/).map{|str| str.strip}
    num = @num_keys.split(/,/).map{|num| num.strip}
    @keys = {str: str, num: num}
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
    count = 0
    jubatus = FluentdJubatus.new(@client_api, @host, @port, @name)
    begin
      jubatus = FluentdJubatus.new(@client_api, @host, @port, @name) if count > 0
      datum = jubatus.set_datum(@client_api, data)
      if @learn_analyze =~ /^analyze$/i
        jubatus.analyze(@client_api, datum)
      elsif @learn_analyze =~ /^train$/i
        jubatus.update(@client_api, datum)
      end
    rescue MessagePack::RPC::ConnectionTimeoutError => e
      jubatus.close
      count += 1
      raise e if count > 10
      sleep 0.1
      retry
    rescue => e
      e
    end
  end

  def result_format(type, result)
  end
end
end
