FULL_SIZE = 200

def get_operation(op, step)
    case op
    when "inc", "dec"
        "#{op[0]} #{step}"
    when "toggle"
        't'
    else
        raise "unknown operation #{op}"
    end
end

def run_operation()
    if ARGV.size == 0
        puts "Not enough arguments"
        exit 1
    end
    step = ARGV.size == 1 ? 1 : ARGV[1]
    operation = get_operation(ARGV[0], step)
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
    boosting = false
    if volume > 100
        boosting = true
        boost_level = volume // 100
        volume = volume - 100
    end
    boosted = boosting ? " [#{boost_level}x boost]" : ""
    `notify-send -a progressable -u low -h int:value:#{volume} 'Volume#{boosted}'`
end

def main()
    run_operation
    render_volume
end

main
