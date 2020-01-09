require "admiral"

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
        `git fetch`
    else
        notify "Cloning #{repo}"
        `git clone -q #{repo} #{repo_path}`
    end
end

def clone_loop
    puts "Started clone loop"
    loop do
        `clipnotify`
        clipboard_item=`xclip -o`
        clone_if_git_repo clipboard_item
    end
end

Clom.run
