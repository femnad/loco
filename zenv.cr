FULL_SIZE = 200
MARGIN = 10
PADDING = 80
Y_POSITION = 30

def get_x_and_y()
    xdpyinfo_output = `xdpyinfo`
    lines = xdpyinfo_output.split('\n')
    lines.each{ |line|
        match_data = /([0-9]+x[0-9]+) pixels/.match(line)
        if !match_data.nil?
            return match_data[1].split('x').map{|s| s.to_i}
        end
    }
    raise "can't determine resolution"
end

def get_operation(arg)
    case arg
    when "inc", "dec"
        "#{arg[0]} 1"
    when "toggle"
        't'
    else
        raise "unknown operation #{arg}"
    end
end

def run_operation()
    if ARGV.size == 0
        raise "Not enough arguments"
    end
    operation = get_operation(ARGV[0])
    `pamixer -#{operation} --allow-boost`
end

def get_volume
    `pamixer --get-volume`.to_i
end

def to_bool(s)
    s.strip == "true"
end

def mute?
    to_bool(`pamixer --get-mute`)
end

def get_x_position(size)
    x_resolution, y_resolution = get_x_and_y
    x_resolution - size - MARGIN
end

def do_get_volume
    if mute?
        return 0
    end
    get_volume
end

def render_volume
    volume = get_volume
    full_size = FULL_SIZE
    if volume > 100
        full_size += 100
    end
    filled = volume * 2
    empty = full_size - filled
    size = full_size + PADDING
    x_position = get_x_position(size)
    `echo '#{volume} ^fg(#191970)^r(#{filled}x30)^fg(#dcdcdc)^r(#{empty}x30)' | dzen2 -xs 1 -p 1 -w #{size} -x #{x_position} -y #{Y_POSITION}`
end

def main()
    run_operation
    render_volume
end

main
