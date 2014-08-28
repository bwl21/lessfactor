require "lessfactor/version"


class LessReplacer

  VAR_PATTERN = /(@[a-z\-]+):\s*([^;]*);(.*)/
  LENGTH_PATTERN = /(\s+|:)([0-9\.]+(em|px|));/
  COLOR_PATTERN = /()(#[a-fA-F0-9]+);/


  def initialize
    @vars = {}
    @literals = {}
    @literalcomments = {}
    @occurence = {}
  end

  def scan_vars(file)
    File.open(file, "r").readlines.each do |l|
      l.match(VAR_PATTERN) do |m|
        value =$2.downcase
        @vars[$1] = {v: value, c: $3}
        (@literals[value] ||= []).push $1
      end
    end
  end

  def scan_literals(file)
    line = 0
    File.open(file, "r").readlines.each do |l|

      line +=1

      l.match(LENGTH_PATTERN) do |m|
        value =$2.downcase
        unless @literals[value]
          (@literals[value] ||= []).push "@zz-size-" + "000#{@literals.keys.count}"[-3 .. -1]
        end
        (@literalcomments[value] ||= []).push line
      end

      l.match(COLOR_PATTERN) do |m|
        value =$2.downcase
        unless @literals[value]
          (@literals[value] ||= []).push "@zz-color-" + "000#{@literals.keys.count}"[-3 .. -1]
        end
        (@literalcomments[value] ||= []).push line
      end
    end
  end

  def replace_vars(infile, outfile)
    result = File.open(infile, "r").readlines.each.map { |l|
      r1 = l.gsub(LENGTH_PATTERN) do |m|
        vn =$2.downcase
        if  @literals[vn]
          name = @literals[vn].join("__")
          $1 + name +';'
        else
          m
        end
      end

      r1.gsub(COLOR_PATTERN) do |m|
        vn =$2.downcase
        if  @literals[vn]
          name = @literals[vn].join("__")
          $1 + name +';'
        else
          m
        end
      end
    }

    File.open(outfile, "w") do |f|
      f.puts(result.join())
    end
  end


  def save_vars(file)
    File.open(file, "w") do |f|
      @literals.sort { |a, b| a[1] <=> b[1] }.each { |value, name|
        the_name = name.first
        occurrences = @literalcomments[value] || []
        comment = @vars[the_name] || {c: " // todo: #{occurrences.count}: #{occurrences}"}
        f.printf "%-25s %-15s %s\n", "#{the_name}:", " #{value};", comment[:c]
      }
    end
  end
end

unless ARGV[1]
  puts %Q{

    this is lessfactor #{LessFactor::VERSION} (#{LessFactor::HOMEPAGE_URL})

    usage: lessfactor  <variablesfile> <infile>

    creates 

      <infile>.refactored.less      - the refactored lessfile
      <infile>.refactored_vars.less - the new variables file
  }
  exit(0)
end


varfile = ARGV[0]
lessfile = ARGV[1]

lessoutfile = lessfile + ".refactored.less"
lessvarfile = lessfile + ".refactored_vars.less"


lr = LessReplacer.new
lr.scan_vars(varfile)
lr.scan_literals(lessfile)
lr.replace_vars(lessfile, lessoutfile)
lr.save_vars(lessvarfile)
