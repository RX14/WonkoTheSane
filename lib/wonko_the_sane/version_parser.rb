class VersionParser
  private
  @@cache = {}
  def self.parse(string)
    if @@cache.has_key? string
      return @@cache[string]
    end
    appendix = string.scan(/\-.*$/).first
    string = string.sub /\-.*$/, ''
    sections = string.split '.'
    sections.map! do |sec|
      test = Integer sec rescue nil
      if test.nil?
        sec
      else
        test
      end
    end

    result = {
        appendix: appendix,
        sections: sections
    }
    @@cache[string] = result
    return result
  end

  def self.appendix_values(appendix)
    str = appendix.scan /[a-zA-Z]*/
    digits = appendix.scan(/\d*/).join.to_i
    ret = case str
      when 'a'
        [0, digits]
      when 'alpha'
        [0, digits]
      when 'b'
        [1, digits]
      when 'beta'
        [1, digits]
      when 'rc'
        [2, digits]
      when 'pre'
        [2, digits]
          end
    return ret ? ret : [-1, digits]
  end

  def self.compare_values(first, second)
    if first < second
      -1
    elsif first > second
      1
    else
      0
    end
  end

  public
  def self.compare(string1, string2)
    par1 = VersionParser.parse string1
    par2 = VersionParser.parse string2
    size = [par1[:sections].length, par2[:sections].length].max
    ret = 0
    size.times do |index|
      val1 = par1[:sections].length > index ? par1[:sections][index] : 0
      val2 = par2[:sections].length > index ? par2[:sections][index] : 0
      if val1.is_a? Integer and val2.is_a? Integer
        ret = VersionParser.compare_values val1, val2
      elsif val1.is_a? Integer
        ret = VersionParser.compare_values val1.to_s, val2
      elsif val2.is_a? Integer
        ret = VersionParser.compare_values val1, val2.to_s
      else
        ret = VersionParser.compare_values val1.to_s, val2.to_s
      end
      break unless ret == 0
    end
    if ret == 0
      if par1[:appendix] and par2[:appendix]
        appendix1 = VersionParser.appendix_values par1[:appendix]
        appendix2 = VersionParser.appendix_values par2[:appendix]
        ret = VersionParser.compare_values appendix1[0], appendix2[0]
        if ret == 0
          ret = VersionParser.compare_values appendix1[1], appendix2[1]
        end
      elsif par1[:appendix]
        ret = -1
      elsif par2[:appendix]
        ret = 1
      end
    end
    return ret
  end

  def self.less?(string1, string2)
    VersionParser.compare(string1, string2) == -1
  end
  def self.greater?(string1, string2)
    VersionParser.compare(string1, string2) == 1
  end
  def self.equal?(string1, string2)
    VersionParser.compare(string1, string2) == 0
  end
  def self.less_or_equal?(string1, string2)
    ret = VersionParser.compare string1, string2
    ret == 0 or ret == -1
  end
  def self.greater_or_equal?(string1, string2)
    ret = VersionParser.compare string1, string2
    ret == 0 or ret == 1
  end
  def self.not_equal?(string1, string2)
    VersionParser.compare(string1, string2) != 0
  end
end