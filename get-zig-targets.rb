require 'json'

def get_zig_targets
    output = `zig targets | jq -r .libc`
    return nil if output.empty?

    targets = JSON.parse output
    return targets.uniq.sort
end

if __FILE__ == $0
    pp get_zig_targets
end
