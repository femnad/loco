HOME = ENV["HOME"]

MODES = ["normal", "scroll"]

SCROLLER = {"normal" => 2, "scroll" => 3}

SETTINGS_FILE = "#{HOME}/.current-mode"

def get_current
  if !File.exists? SETTINGS_FILE
    return MODES[0]
  end
  file = File.open(SETTINGS_FILE)
  content = File.read(SETTINGS_FILE)
  file.close
  return content
end

def get_next
  current = get_current
  current_index = MODES.index(current)
  if current_index
    next_index = (current_index + 1) % MODES.size
    return MODES[next_index]
  end
end

def update_mode(new_mode)
  updated = File.open(SETTINGS_FILE, "w")
  File.write(SETTINGS_FILE, new_mode)
  updated.close
end

def update_xinput(mode, device)
  scroller_button = SCROLLER[mode]
  `xinput set-prop "pointer:#{device}" 'libinput Button Scrolling Button' #{scroller_button}`
  `xinput set-prop "pointer:#{device}" 'libinput Scroll Method Enabled' 0 0 1`
end

def notify(active_mode)
  `notify-send "Active mode" "#{active_mode}"`
end

def main
  if ARGV.size != 1
    puts "usage: tosm <device-name>"
    exit 1
  end
  device = ARGV[0]
  next_mode = get_next
  update_xinput(next_mode, device)
  update_mode(next_mode)
  notify(next_mode)
end

main
