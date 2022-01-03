module AllGem
  class CLI
    class Error < StandardError
      attr_reader :status

      def initialize(message, status = 1)
        super(message)
        @status = status
      end
    end

    attr_reader :stdout, :stderr, :stdin

    def initialize(stdout:, stderr:, stdin:)
      @stdout = stdout
      @stderr = stderr
      @stdin = stdin
    end

    def run(argv)
      # TODO: optparse
      #       options candidates: --remote --since --major --minor --patch --dir
      command = argv[0] or raise Error.new(help)
      spec = gemspec_from_command(command)

      versions = versions_of(spec)

      # TODO: omit the same output
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

    # TODO: be aware of remote gems
    def versions_of(spec)
      Gem::Specification.select {|s| s.name == spec.name }.map { |s| s.version }.sort
    end
  end
end
