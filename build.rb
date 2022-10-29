require "./version"
require "./get-version"
require "./zig-test"

PROGRAM = "zig-demo"
# VERSION = "v0.0.1"
BUILD_CMD = "zig build"
OUTPUT_ARG = "-p"
RELEASE_BUILD = true
RELEASE_ARG = RELEASE_BUILD == true ? "-Drelease" : ""
RELEASE = RELEASE_BUILD == true ? "release" : "debug"
# used in this way:
# BUILD_CMD RELEASE_ARG TARGET_ARG OUTPUT_ARG OUTPUT_PATH
TEST_CMD = "zig build"

TARGET_DIR = "target"
DOCKER_DIR = "docker"
UPLOAD_DIR = "upload"

def doCleanAll
    puts "doCleanAll..."
    `rm -rf #{TARGET_DIR} #{UPLOAD_DIR}`
end

def doClean
    puts "doClean..."
    `rm -rf #{TARGET_DIR}/#{DOCKER_DIR} #{UPLOAD_DIR}`
end

# go tool dist list
# linux only for docker
GO_ZIG = {
    "linux/386": ["i386-linux-gnu", "i386-linux-musl"],
    "linux/amd64": ["x86_64-linux-gnu", "x86_64-linux-musl"],
    "linux/arm": ["arm-linux-gnueabi", "arm-linux-gnueabihf", "arm-linux-musleabi", "arm-linux-musleabihf"],
    "linux/arm64": ["aarch64-linux-gnu", "aarch64-linux-musl"],
    "linux/mips": ["mips-linux-gnueabi", "mips-linux-gnueabihf", "mips-linux-musl"],
    "linux/mips64": ["mips64-linux-gnuabi64", "mips64-linux-gnuabin32", "mips64-linux-musl"],
    "linux/mips64le": ["mips64el-linux-gnuabi64", "mips64el-linux-gnuabin32", "mips64el-linux-musl"],
    "linux/mipsle": ["mipsel-linux-gnueabi", "mipsel-linux-gnueabihf", "mipsel-linux-musl"],
    "linux/ppc64": ["powerpc64-linux-gnu", "powerpc64-linux-musl"],
    "linux/ppc64le": ["powerpc64le-linux-gnu", "powerpc64le-linux-musl"],
    "linux/riscv64": ["riscv64-linux-gnu", "riscv64-linux-musl"],
    "linux/s390x": ["s390x-linux-gnu", "s390x-linux-musl"],
}

ARM = ["5", "6", "7"]

# zig targets | jq -r .libc
TARGETS = [
    "aarch64_be-linux-gnu",
    "aarch64_be-linux-musl",
    "aarch64_be-windows-gnu",
    "aarch64-linux-gnu",
    "aarch64-linux-musl",
    "aarch64-windows-gnu",
    "aarch64-macos-none",
    "armeb-linux-gnueabi",
    "armeb-linux-gnueabihf",
    "armeb-linux-musleabi",
    "armeb-linux-musleabihf",
    "armeb-windows-gnu",
    "arm-linux-gnueabi",
    "arm-linux-gnueabihf",
    "arm-linux-musleabi",
    "arm-linux-musleabihf",
    "thumb-linux-gnueabi",
    "thumb-linux-gnueabihf",
    "thumb-linux-musleabi",
    "thumb-linux-musleabihf",
    "arm-windows-gnu",
    "csky-linux-gnueabi",
    "csky-linux-gnueabihf",
    "i386-linux-gnu",
    "i386-linux-musl",
    "i386-windows-gnu",
    "m68k-linux-gnu",
    "m68k-linux-musl",
    "mips64el-linux-gnuabi64",
    "mips64el-linux-gnuabin32",
    "mips64el-linux-musl",
    "mips64-linux-gnuabi64",
    "mips64-linux-gnuabin32",
    "mips64-linux-musl",
    "mipsel-linux-gnueabi",
    "mipsel-linux-gnueabihf",
    "mipsel-linux-musl",
    "mips-linux-gnueabi",
    "mips-linux-gnueabihf",
    "mips-linux-musl",
    "powerpc64le-linux-gnu",
    "powerpc64le-linux-musl",
    "powerpc64-linux-gnu",
    "powerpc64-linux-musl",
    "powerpc-linux-gnueabi",
    "powerpc-linux-gnueabihf",
    "powerpc-linux-musl",
    "riscv64-linux-gnu",
    "riscv64-linux-musl",
    "s390x-linux-gnu",
    "s390x-linux-musl",
    "sparc-linux-gnu",
    "sparc64-linux-gnu",
    "wasm32-freestanding-musl",
    "wasm32-wasi-musl",
    "x86_64-linux-gnu",
    "x86_64-linux-gnux32",
    "x86_64-linux-musl",
    "x86_64-windows-gnu",
    "x86_64-macos-none",
]

TEST_TARGETS = [
    "aarch64-linux-gnu",
    "aarch64-linux-musl",
    "aarch64-windows-gnu",
    "aarch64-macos-none",
    "arm-linux-gnueabi",
    "arm-linux-gnueabihf",
    "arm-linux-musleabi",
    "arm-linux-musleabihf",
    "x86_64-linux-gnu",
    "x86_64-linux-gnux32",
    "x86_64-linux-musl",
    "x86_64-windows-gnu",
    "x86_64-macos-none",
]

LESS_TARGETS = [
    "aarch64-linux-gnu",
    "aarch64-linux-musl",
    "x86_64-linux-gnu",
    "x86_64-linux-musl",
]

version = get_version ARGV, 0, VERSION

test_bin = ARGV[0] == "test" || false
less_bin = ARGV[0] == "less" || false

clean_all = ARGV.include? "--clean-all" || false
clean = ARGV.include? "--clean" || false
run_test = ARGV.include? "--run-test" || false
catch_error = ARGV.include? "--catch-error" || false

targets = TARGETS
targets = TEST_TARGETS if test_bin
targets = LESS_TARGETS if less_bin

if run_test
    zig_test catch_error
end

if clean_all
    doCleanAll
elsif clean
    doClean
    # on local machine, you may re-run this script
elsif test_bin || less_bin
    doClean
end
`mkdir -p #{TARGET_DIR} #{UPLOAD_DIR}`
`mkdir -p #{TARGET_DIR}/#{DOCKER_DIR}`

def existsThen(cmd, src, dest)
    if system "test -f #{src}"
        `#{cmd} #{src} #{dest}`
    end
end

def notExistsThen(cmd, dest, src)
    if not system "test -f #{dest}"
        if system "test -f #{src}"
            cmd = "#{cmd} #{src} #{dest}"
            puts cmd
            IO.popen(cmd) do |r|
                puts r.readlines
            end
        else
            puts "!! #{src} not exists"
        end
    end
end

for target in targets
    tp_array = target.split("-")
    architecture = tp_array[0]
    os = tp_array[1]
    windows = os == "windows"
    
    program_bin = !windows ? PROGRAM : "#{PROGRAM}.exe"
    target_bin = !windows ? target : "#{target}.exe"

    target_arg = "-Dtarget=#{target}"
    cmd = "#{BUILD_CMD} #{RELEASE_ARG} #{target_arg} #{OUTPUT_ARG} #{TARGET_DIR}/#{target}/#{RELEASE}"
    puts cmd
    system cmd

    existsThen "ln", "#{TARGET_DIR}/#{target}/#{RELEASE}/bin/#{program_bin}", "#{UPLOAD_DIR}/#{target_bin}"
end

GO_ZIG.each do |target_platform, targets|
    tp_array = target_platform.to_s.split("/")
    os = tp_array[0]
    architecture = tp_array[1]

    if architecture == "arm"
        for variant in ARM
            docker = "#{TARGET_DIR}/#{DOCKER_DIR}/#{os}/#{architecture}/v#{variant}"
            puts docker
            `mkdir -p #{docker}`

            if targets.kind_of?(Array)
                for target in targets
                    tg_array = target.split("-")
                    abi = tg_array.last

                    existsThen "ln", "#{TARGET_DIR}/#{target}/#{RELEASE}/bin/#{PROGRAM}", "#{docker}/#{PROGRAM}-#{abi}"
                    Dir.chdir docker do
                        notExistsThen "ln -s", PROGRAM, "#{PROGRAM}-#{abi}"
                    end
                end
            else
                existsThen "ln", "#{TARGET_DIR}/#{target}/#{RELEASE}/bin/#{PROGRAM}", "#{docker}/#{PROGRAM}"
            end
        end
    else
        docker = "#{TARGET_DIR}/#{DOCKER_DIR}/#{os}/#{architecture}"
        puts docker
        `mkdir -p #{docker}`

        if targets.kind_of?(Array)
            for target in targets
                tg_array = target.split("-")
                abi = tg_array.last

                existsThen "ln", "#{TARGET_DIR}/#{target}/#{RELEASE}/bin/#{PROGRAM}", "#{docker}/#{PROGRAM}-#{abi}"
                Dir.chdir docker do
                    notExistsThen "ln -s", PROGRAM, "#{PROGRAM}-#{abi}"
                end
            end
        else
            existsThen "ln", "#{TARGET_DIR}/#{target}/#{RELEASE}/bin/#{PROGRAM}", "#{docker}/#{PROGRAM}"
        end
    end
end

# cmd = "file #{UPLOAD_DIR}/**"
# IO.popen(cmd) do |r|
#         puts r.readlines
# end

file = "#{UPLOAD_DIR}/BINARYS"
IO.write(file, "")

cmd = "tree #{TARGET_DIR}/#{DOCKER_DIR}"
IO.popen(cmd) do |r|
    rd = r.readlines
    puts rd

    for o in rd
        IO.write(file, o, mode: "a")
    end
end

Dir.chdir UPLOAD_DIR do
    file = "SHA256SUM"
    IO.write(file, "")

    cmd = "sha256sum *"
    IO.popen(cmd) do |r|
        rd = r.readlines

        for o in rd
            if !o.include? "SHA256SUM" and !o.include? "BINARYS"
                print o
                IO.write(file, o, mode: "a")
            end
        end
    end
end

# `docker buildx build --platform linux/amd64 -t demo:amd64 . --load`
# cmd = "docker run demo:amd64"
# IO.popen(cmd) do |r|
#         puts r.readlines
# end
