FULL_SIZE = 200

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
        puts "Not enough arguments"
        exit 1
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
    volume = do_get_volume
    full_size = FULL_SIZE
    boosting = false
    if volume > 100
        boosting = true
        full_size += 100
    end
    boosted = boosting ? " [boosted]" : ""
    filled = volume * 2
    percentage = filled.to_f / full_size * 100
    `notify-send -a volume -u low -h int:value:#{percentage} 'Volume#{boosted}'`
end

def main()
    run_operation
    render_volume
end

main
