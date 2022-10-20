def zig_test catch_error = false, *opt
    test_cmd = opt[0] || "zig build"

    keyword = "tests"
    output = `zig build --help | grep #{keyword}`
    lines = output.split("\n")
    for line in lines
        arg = line.split(" ").first
        cmd = "#{test_cmd} #{arg}"
        puts cmd
        result = system cmd
        if catch_error and !result
            return
        end
    end
end

# run_test false