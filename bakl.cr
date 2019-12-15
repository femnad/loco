require "option_parser"

operation = "noop"
step_size = 1

def main
    OptionParser.parse! do |parser|
        parser.on("-inc", "--increase", "Increases brightness") { operation = "increase" }
    end
    if ARGV.size == 0
        puts "Not enough arguments"
        exit 1
    end

    arg = ARGV[0]

    case arg
    when "inc"
        `xbacklight -inc #{STEP_SIZE}`
    when "dec"
        `xbacklight -dec #{STEP_SIZE}`
    else
        puts "unknown operation #{arg}"
        exit 1
    end

    current = `xbacklight -get`.strip

    `notify-send -a progressable -u low -h int:value:#{current} Brightness`
end

main
