module Fluent
class JubatusOutput < Output
  Plugin.register_output('jubatus', self)

  # To support Fluentd v0.10.57 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

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
    str = @str_keys.split(/,/).map{|key| key.strip }
    num = @num_keys.split(/,/).map{|key| key.strip }
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
      result = result_format(@client_api, jubatus_run(record))
      router.emit(@tag, time, result)
    end

    chain.next
  end

  private

  def jubatus_run(data)
    count = 0
    jubatus = FluentdJubatus.new(@client_api, host: @host, port: @port, name: @name)
    begin
      datum = jubatus.to_datum(data, @keys)
      case @learn_analyze
      when /^analyze$/i
        jubatus.analyze(@client_api, datum)
      when /^learn$/i
        # todo
        # jubatus.learn(@client_api, datum)
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
    FluentdJubatus.fix_result(type, result)
  end
end
end
