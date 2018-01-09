struct FileState
    file::IOStream
    last_modified
end

function is_modified(files!)
    is_modified = false
    for (i, file) in enumerate(files!)
        info = stat(file.file)
        is_modified = is_modified || info.mtime != file.last_modified
        files![i] = FileState(file.file, info.mtime)
    end
    return is_modified
end

function main()
    println(ARGS)
    path = ARGS[1]
    re_filter = ARGS[2]
    command = foldl((l, i) -> "$(l) $(ARGS[i])", ARGS[3], 4:length(ARGS))

    println("path: $(path)")
    println("re_filter: $(re_filter)")
    println("command: $(command)")

    output = open(readstring, `find $(path) -type f -regextype posix-egrep -regex "$(re_filter)"`)
    files = map(x -> FileState(open(x), ""), filter(x -> x != "", split(output, ['\n'])))
    cmd = `$(command)`

    while true
        if is_modified(files)
            run(cmd)
        end
        sleep(1)
    end
end

main()