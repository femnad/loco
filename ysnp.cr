NAME = "ysnp"
MENU_DISPLAYER = "profit"
PRINCIPAL_SPECIFIER = "login"
PRINCIPAL_PRIORITIES = ["email", "username"]

def message_and_exit(msg)
  puts msg
  exit 1
end

def get_secret_lines(pass_name)
  `pass show #{pass_name}`.strip.split('\n')
end

def get_password(pass_name)
  get_secret_lines(pass_name)[0]
end

def get_principal(pass_aux_lines)
  if pass_aux_lines.size == 0
    puts "No principal in password"
    exit 1
  end

  if pass_aux_lines.size == 1
    return pass_aux_lines[0].split(": ")[-1]
  end

  pass_info = {} of String => String
  pass_aux_lines.each{ |line|
      key, value = line.split(": ")
      pass_info[key] = value
  }

  if pass_info.has_key?(PRINCIPAL_SPECIFIER)
    principal = pass_info[PRINCIPAL_SPECIFIER]
    return pass_info[principal]
  end

  PRINCIPAL_PRIORITIES.each{ |principal|
    if pass_info.has_key?(principal)
      return pass_info[principal]
    end
  }

  message_and_exit "Cannot determine principal"
end

def get_principal_and_password(pass_name)
  lines = get_secret_lines(pass_name)
  password = lines[0]
  principal = get_principal(lines[1..-1])
  return principal, password
end

def copy_password(pass_secret)
    `pass -c #{pass_secret}`
end

def type_password(pass_secret)
    password = get_password(pass_secret)
    `xdotool type '#{password}'`
end

def type_login_and_password(pass_secret)
    principal, password = get_principal_and_password(pass_secret)
    `xdotool type #{principal}`
    `xdotool key Tab`
    `xdotool type '#{password}'`
end

def type_login(pass_secret)
    principal, _ = get_principal_and_password(pass_secret)
    `xdotool type #{principal}`
end

OPERATION_MAP = {
    "copy" => ->copy_password(String),
    "login-tab-pass" => ->type_login_and_password(String),
    "login" => ->type_login(String),
    "type" => ->type_password(String),
}

def valid_operations
    OPERATION_MAP.keys.join(", ")
end

def perform_operation(operation)
    pass_operation = OPERATION_MAP.fetch(operation, nil)
    if pass_operation.nil?
        message_and_exit "Unrecognised operation #{operation}\nNeeded one of #{valid_operations}"
    end
    secret = `#{MENU_DISPLAYER}`
    pass_operation.call(secret)
end


def usage
  puts "usage: #{NAME} <operation>\n    where operation is one of #{valid_operations}"
end

def get_operation(args)
  if args.size != 1
      message_and_exit usage
  end
  operation = args[0]
  perform_operation(operation)
end

get_operation(ARGV)
