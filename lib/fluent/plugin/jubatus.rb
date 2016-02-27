require 'jubatus/anomaly/client'
require 'jubatus/anomaly/types'
require 'jubatus/classifier/client'
require 'jubatus/classifier/types'
require 'jubatus/clustering/client'
require 'jubatus/clustering/types'
require 'jubatus/recommender/client'
require 'jubatus/recommender/types'

class FluentdJubatus
  def initialize(type, host: 'localhost', port: '9199', name: '')
    @jubatus = case type
      when /anomaly/i then Jubatus::Anomaly::Client::Anomaly.new(host, port, name)
      when /classifier/i then Jubatus::Classifier::Client::Classifier.new(host, port, name)
      when /clustering/i then Jubatus::Clustering::Client::Clustering.new(host, port, name)
      when /recommender/i then Jubatus::Recommender::Client::Recommender.new(host, port, name)
      end
  end

  def to_datum(data, keys)
    datum = {}
    data.each do |k,v|
      datum[k.to_s] = v.to_f if keys[:num].include?(k.to_s)
      datum[k.to_s] = v.to_s if keys[:str].include?(k.to_s)
    end
    Jubatus::Common::Datum.new(datum)
  end

  def analyze(type, datum, num: 10)
    case type
    when /anomaly/i then @jubatus.calc_score(datum)
    when /classifier/i then @jubatus.classify([datum])
    when /clustering/i then @jubatus.get_nearest_members(datum)
    when /recommender/i then @jubatus.similar_row_from_datum(datum, num)
    end
  end

  def close
    @jubatus.get_client.close
  end

  def learn(type, datum, key: nil)
    # TODO
  end

  class << self
    def fix_result(type, result)
      case type
      when /anomaly/i then fix_anomaly(result)
      when /classifier/i then fix_classifier(result)
      when /clustering/i then fix_clustering(result)
      when /recommender/i then fix_recommender(result)
      end
    end

    private

    def fix_anomaly(result)
      result
    end

    def fix_classifier(results)
      results.map do |result|
        est = {}
        result.each{|res| est[res.label] = res.score}
      end
    end

    def fix_clustering(results)
      result = {}
      results.each{|r| result[r.id] = r.score}
      result
    end

    def fix_recommender(results)
      result = {}
      results.each{|r| result[r.id] = r.score }
      result
    end
  end
end
