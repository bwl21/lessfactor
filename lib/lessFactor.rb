


class LessReplacer

  VAR_PATTERN    = /(@[a-z\-]+):\s*([^;]*);/
  LENGTH_PATTERN = /(\s+|:)([0-9\.]+(em|px|));/
  COLOR_PATTERN  = /()(#[a-fA-F0-9]+);/


  def initialize
    @vars = {}
    @literals = {}
  end

  def scan_vars(file)
    File.open(file, "r").readlines.each do |l|
       l.match(VAR_PATTERN) do |m|
         value =$2.downcase
         @vars[$1] = value
         @literals[value] = $1
       end
    end
  end

  def scan_literals(file)
    File.open(file, "r").readlines.each do |l|
      l.match(LENGTH_PATTERN) do |m|
        value =$2.downcase
        unless @literals[value]
          @literals[value] = "@zz-length-" + "000#{@literals.keys.count}"[-3 .. -1]
        end
      end
      l.match(COLOR_PATTERN) do |m|
        value =$2.downcase
        unless @literals[value]
          @literals[value] = "@zz-color-" + "000#{@literals.keys.count}"[-3 .. -1]
        end
      end
    end
  end

  def replace_vars(infile, outfile)
    result = File.open(infile, "r").readlines.each.map{|l|
      r1 = l.gsub(LENGTH_PATTERN) do |m|
        vn =$2.downcase
        if  @literals[vn]
          $1 + @literals[vn] + ';'
        else
          m
        end
      end

      r1.gsub(COLOR_PATTERN) do |m|
        vn =$2.downcase
        if  @literals[vn]
          $1 + @literals[vn] +';'
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
      @literals.sort{|a, b| a[1]<=> b[1] }.each{|value, name| f.puts "#{name}: #{value};" }
    end
  end
end

unless ARGV[1]
  puts %q{
    usage: lessfactor <infile> <variablesfile>

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
