CLONE_PATH="~/z/gl"
PROG="clom"
REPO_REGEX=%r<(^https|git)://git(hub|lab)\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+(\.git)?$>

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

    clone_path = Path[CLONE_PATH].expand(home: ENV["HOME"])
    repo_path = "#{clone_path.to_s}/#{basename}"

    if File.exists?(repo_path) && File.directory?(repo_path)
        Dir.cd(repo_path)
        notify "Updating #{repo}"
        `git fetch`
    else
        notify "Cloning #{repo}"
        `git clone #{repo} #{repo_path}`
    end
end

def clone_loop
    loop do
        `clipnotify`
        clipboard_item=`xclip -o`
        clone_if_git_repo clipboard_item
    end
end

clone_loop
