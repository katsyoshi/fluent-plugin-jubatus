require 'test_helper'

class FluentdJubatusTest < Minitest::Test
  def setup
    @jubatus = FluentdJubatus.new('anomaly')
  end

  def test_to_datum
    keys = {num: ['a'], str: ['b']}
    data = {a: 1, b: 1}
    expect = {'a' => 1, 'b' => '1'}
    assert_equal(Jubatus::Common::Datum.new(expect).string_values, @jubatus.to_datum(data, keys).string_values)
  end
end
