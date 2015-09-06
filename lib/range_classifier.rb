class RangeClassifier
  attr_reader :projection

  def initialize(projection=RangeClassifier.id, ranges: [])
    @projection = projection
    @ranges = ranges
  end

  def append_ranges(ranges)
    @ranges.concat(ranges)
    self
  end

  def append_lower_stream(stream, low: nil)
    stream.each do |high, result|
      @ranges << {
        lower: [low, high],
        result: result
      }
      low = high
    end
    self
  end

  def classify(element, *args)
    lkey, ukey = @projection.call(element, *args)
    selected = @ranges.find { |range|
      matches_section(range[:lower], lkey) && matches_section(range[:upper], ukey)
    }
    selected[:result]
  end

  private

  def self.id
    -> (v) {[v, v]}
  end

  def matches_section(range, key)
    return true if range.nil?
    l, u = range
    (l.nil? || l <= key) && (u.nil? || u >= key)
  end
end