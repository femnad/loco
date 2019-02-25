require "yaml"

NAME = "ysnp"
MENU_DISPLAYER = "profit"
PRINCIPAL_SPECIFIER = "login"
PRINCIPAL_PRIORITIES = ["email", "username"]

def get_secret_lines(pass_name)
  `pass show #{pass_name}`.strip.split('\n')
end

def get_password(pass_name)
  get_secret_lines(pass_name)[0]
end

def get_principal(pass_aux_lines)
  if pass_aux_lines.size == 0
    raise "No principal in password"
  end

  if pass_aux_lines.size == 1
    return pass_aux_lines[0].split(": ")[-1]
  end

  doc = pass_aux_lines.join('\n')
  parsed = YAML.parse(doc)
  pass_info = parsed.as_h

  if pass_info.has_key?(PRINCIPAL_SPECIFIER)
    puts pass_info
    principal = pass_info[PRINCIPAL_SPECIFIER]
    puts principal
    return pass_info[principal]
  end

  PRINCIPAL_PRIORITIES.each{ |principal|
    if pass_info.has_key?(principal)
      return pass_info[principal]
    end
  }

  raise "Cannot determine principal"
end

def get_principal_and_password(pass_name)
  lines = get_secret_lines(pass_name)
  password = lines[0]
  principal = get_principal(lines[1..-1])
  return principal, password
end

def perform_operation(operation, pass_secret)
  case operation
  when "copy"
    `pass -c #{pass_secret}`
  when "type"
    password = get_password(pass_secret)
    `xdotool type '#{password}'`
  when "login-tab-pass"
    principal, password = get_principal_and_password(pass_secret)
    `xdotool type #{principal}`
    `xdotool key Tab`
    `xdotool type '#{password}'`
  else
    raise "Unrecognised operation #{operation}"
  end
end

def usage
  puts "usage: #{NAME} <operation>"
end

def get_operation(args)
  if args.size != 1
    usage
    exit 1
  end
  operation = args[0]
  secret = `#{MENU_DISPLAYER}`
  perform_operation(operation, secret)
end

get_operation(ARGV)
