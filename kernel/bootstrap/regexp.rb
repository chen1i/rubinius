class Regexp
  class << self
    def new(str, opts=false)
      create(str, opts)
    end
    
    alias :compile :new

    def create(str, opts)
      Ruby.primitive :regexp_new
    end

    # FIXME - Optimize me using String#[], String#chr, etc.
    # Do away with the control-character comparisons.
    def escape(str)
      meta = %w![ ] { } ( ) | - * . \\ ? + ^ $ #!
      quoted = ""
      str.codepoints.each do |c|
        quoted << if meta.include?(c)
        "\\#{c}"
        elsif c == "\n"
        "\\n"
        elsif c == "\r"
        "\\r"
        elsif c == "\f"
        "\\f"
        else
          c
        end
      end
      quoted
    end
    alias_method :quote, :escape
  end

  def inspect
    "#<Regexp /#{self.source}/>"
  end

  def match(str)
    Ruby.primitive :regexp_match
  end
end

class MatchData
  
  def string
    @source
  end
  
  def begin(idx)
   return full.at(0) if idx == 0
   return @region.at(idx - 1).at(0)
  end

  def end(idx)
   return full.at(1) if idx == 0
   @region.at(idx - 1).at(1)
  end

  def offset(idx)
   out = []
   out << self.begin(idx)
   out << self.end(idx)
   return out
  end

  def length
   @region.fields + 1
  end

  def captures
    out = []
    @region.each do |tup|
      x = tup.at(0)
      y = tup.at(1)
      out << @source[x...y]
    end
    return out
  end

  def [](idx)
    if idx == 0
      x = full.at(0)
      y = full.at(1) - 1
      @source[x..y]
    else
      captures[idx - 1]
    end
  end
  
  def pre_match
    return "" if full.at(0) == 0
    nd = full.at(0) - 1
    @source[0..nd]
  end
  
  def post_match
    nd = @source.size - 1
    st = full.at(1)
    @source[st..nd]
  end
end
