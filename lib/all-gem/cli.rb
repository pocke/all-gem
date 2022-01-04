require 'optparse'
require 'open3'

module AllGem
  class CLI
    class Error < StandardError
      attr_reader :status

      def initialize(message, status = 1)
        super(message)
        @status = status
      end
    end

    class Options
      attr_accessor :remote, :since, :level

      def initialize
        @remote = false
        @since = nil
        @level = :all
      end
    end

    attr_reader :stdout, :stderr, :stdin, :op, :opts

    def initialize(stdout:, stderr:, stdin:)
      @stdout = stdout
      @stderr = stderr
      @stdin = stdin

      set_optparse
    end

    def run(argv)
      argv = @op.order(argv)

      command = argv[0] or raise Error.new("COMMAND is not specified.\n\n" + op.help)
      spec = gemspec_from_command(command)

      versions = versions_of(spec, opts)
      versions = filter_by_level(versions, opts)
      install! spec, versions

      execute_and_print argv, versions
    end

    private

    def set_optparse
      @opts = Options.new
      @op = OptionParser.new

      op.banner = <<~BANNER
        Usage: all-gem [all-gem options] COMMAND [command options]
      BANNER

      op.on('--remote', 'Install the gems if it does not exist in the local') { opts.remote = true }
      op.on('--since VERSION', 'Run only versions since specified one') { |v| opts.since = Gem::Version.new(v) }
      op.on('--major', 'Run only each major version') { opts.level = :major }
      op.on('--minor', 'Run only each minor version') { opts.level = :minor }
      op.on('--patch', 'Run only each patch version') { opts.level = :patch }
      op.on('--version', 'Display all-ruby version') { stdout.puts "all-gem-#{AllGem::VERSION}"; exit 0 }
      # op.on('--dir') # TODO: consider the API, make and cd to a directory
      # op.on('--pre') # TODO: consider the API
    end

    def execute_and_print(argv, versions)
      command = argv[0]

      # @type var prev: [String?, Process::Status?]
      prev = [nil, nil]
      prev_idx = -1
      versions.each.with_index do |v, idx|
        no_bundler do
          output, status = Open3.capture2e(command, "_#{v}_", *(argv[1..] or raise))
          if prev != [output, status]
            if prev_idx != idx-1
              print_result command, versions, idx-1, (prev[0] or raise), (prev[1] or raise)
            end
            print_result command, versions, idx, output, status

            prev_idx = idx
          else
            stdout.puts '...' if prev_idx == idx-1
          end

          __skip__ = prev = [output, status]
        end
      end

      if prev_idx != versions.size-1
        print_result command, versions, versions.size-1, (prev[0] or raise), (prev[1] or raise)
      end
    end

    def print_result(command, versions, idx, output, status)
      exit_status_indent = 8
      longest_version = versions.max_by { |v| command.size + '-'.size + v.to_s.size } or raise
      output_indent = command.size + '-'.size + longest_version.to_s.size + '   '.size

      version = versions[idx]
      label = "#{command}-#{version}"

      stdout.print label
      lines = output.lines
      stdout.puts "#{' ' * (output_indent - label.size)}#{lines[0]}"
      stdout.puts (lines[1..] or raise).map { |line| "#{' ' * output_indent}#{line}"}
      stdout.puts "#{' ' * exit_status_indent}exit #{status.exitstatus}" unless status.success?
    end

    def gemspec_from_command(command)
      spec = Gem::Specification.find { |s| s.executables.include?(command) }
      # TODO: did you mean
      spec or raise Error.new("Could not find #{command} as an executable file")
    end

    def versions_of(spec, opts)
      versions = local_versions(spec)
      versions.concat remote_versions(spec) if opts.remote

      versions.uniq!
      versions.sort!

      since = opts.since
      versions = versions.select { |v| since <= v } if since

      versions
    end

    def remote_versions(spec)
      f = Gem::SpecFetcher.fetcher
      f.detect(:released) { |tuple| tuple.name == spec.name }.map { |arr| arr[0].version }
    end

    def local_versions(spec)
      Gem::Specification.select { |s| s.name == spec.name }.map { |s| s.version }
    end

    def install!(spec, versions)
      installed = local_versions(spec)

      targets = (versions - installed).map { |v| "#{spec.name}:#{v}" }
      return if targets.empty?

      no_bundler do
        __skip__ = system('gem', 'install', *targets, '--conservative', exception: true)
      end
    end

    def filter_by_level(versions, opts)
      return versions if opts.level == :all

      n = { major: 0, minor: 1, patch: 2 }[opts.level]
      versions.group_by { |v| v.segments[0..n] }.map { |_, vs| vs.max or raise }
    end

    def no_bundler(&block)
      if defined?(Bundler)
        Bundler.with_unbundled_env do
          block.call
        end
      else
        block.call
      end
    end
  end
end
