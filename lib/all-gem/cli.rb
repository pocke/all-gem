require 'optparse'

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

    attr_reader :stdout, :stderr, :stdin

    def initialize(stdout:, stderr:, stdin:)
      @stdout = stdout
      @stderr = stderr
      @stdin = stdin
    end

    def run(argv)
      opt = Options.new
      o = OptionParser.new
      o.on('--remote') { opt.remote = true }
      o.on('--since SINCE') { |v| opt.since = Gem::Version.new(v) }
      o.on('--major') { opt.level = :major }
      o.on('--minor') { opt.level = :minor }
      o.on('--patch') { opt.level = :patch }
      # o.on('--dir') # TODO: consider the API, make and cd to a directory
      # o.on('--pre') # TODO: consider the API
      argv = o.order(argv)

      command = argv[0] or raise Error.new(help)
      spec = gemspec_from_command(command)

      versions = versions_of(spec, opt)
      versions = filter_by_level(versions, opt)
      install! spec, versions

      # TODO: omit the same output
      # TODO: handle exit status
      versions.each do |v|
        stdout.puts "#{command}-#{v}"
        __skip__  = system(command, "_#{v}_", *argv[1..])
      end
    end

    private

    def help
      <<~HELP
        Usage: all-ruby [all-ruby options] COMMAND_NAME [command options]
      HELP
    end

    def gemspec_from_command(command)
      spec = Gem::Specification.find { |s| s.executables.include?(command) }
      # TODO: did you mean
      spec or raise Error.new("Could not find #{command} as an executable file")
    end

    def versions_of(spec, opt)
      versions = local_versions(spec)
      versions.concat remote_versions(spec) if opt.remote

      versions.uniq!
      versions.sort!

      since = opt.since
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

      __skip__ = system('gem', 'install', *targets, exception: true)
    end

    def filter_by_level(versions, opt)
      return versions if opt.level == :all

      n = { major: 0, minor: 1, patch: 2 }[opt.level]
      versions.group_by { |v| v.segments[0..n] }.map { |_, vs| vs.max or raise }
    end
  end
end
