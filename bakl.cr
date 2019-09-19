STEP_SIZE = 1

def main
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
