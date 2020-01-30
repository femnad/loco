require "system/user"

require "admiral"
require "inotify"

CLIPMENU_MAJOR_VERSION=5
CLONE_PATH="~/z/gl"
PROG="clom"
REPO_REGEX=%r<(^https|git)://git(hub|lab)\.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+(\.git)?$>

class Clom < Admiral::Command
    class CloneLoop < Admiral::Command
        def run
            clone_loop
        end
    end

    class OneShot < Admiral::Command

        define_argument repo : String, required: true

        def run
            clone_if_git_repo arguments.repo
        end
    end

    define_help description: "clom: monitor clipboard for repos to clone"
    define_version "0.5.0"

    register_sub_command clone_loop : CloneLoop, description: "Run the clone loop"
    register_sub_command one_shot : OneShot, description: "Clone if the argument is a repo"

    def run
        puts help
    end
end

def notify(msg)
    `notify-send #{PROG} '#{msg}'`
end

def clone_if_git_repo(item)
    repo = REPO_REGEX.match(item)
    if repo.nil?
        return
    end

    repo = repo.string
    basename = Path[repo].basename

    if basename.ends_with?(".git")
        basename = basename[0..-5]
    end

    clone_path = CLONE_PATH.sub("~", ENV["HOME"])
    repo_path = "#{clone_path.to_s}/#{basename}"

    if File.directory?(repo_path)
        Dir.cd(repo_path)
        notify "Updating #{repo}"
        `git pull -r`
        notify "Updated #{repo}"
    else
        notify "Cloning #{repo}"
        `git clone -q #{repo} #{repo_path}`
        notify "Cloned #{repo}"
    end
end

def get_last_line(filename)
    file = File.new(filename)
    offset = -2
    line = ""
    while true
        file.seek(offset, IO::Seek::End)
        offset -= 1
        c = file.gets(1)
        if c == "\n" || c.nil?
            break
        end

        line += c
    end
    if line.size == 0
        return nil
    end
    tokens = line.reverse.split(/\s+/)
    if tokens.size < 2
        return nil
    end
    file.close
    return tokens[1]
end

def watch_cache_file(filename, channel)
    watcher = Inotify.watch filename do |event|
        last_line = get_last_line(filename)
        if !last_line.nil?
            channel.send(last_line)
        end
    end
end

def get_cache_file_name
    username = ENV["USER"]
    user = System::User.find_by name: username
    default_cache = "/run/user/#{user.id}/clipmenu.#{CLIPMENU_MAJOR_VERSION}.#{user.name}/line_cache_clipboard"
    if File.directory? default_cache
        return default_cache
    end
    "#{user.home_directory}/.cache/clipmenu/clipmenu.#{CLIPMENU_MAJOR_VERSION}.#{user.name}/line_cache_clipboard"
end

def clone_loop
    puts "Started clone loop"
    filename = get_cache_file_name
    channel = Channel(String).new
    spawn do
        watch_cache_file(filename, channel)
    end
    loop do
        line = channel.receive
        clone_if_git_repo line
    end
end

Clom.run
