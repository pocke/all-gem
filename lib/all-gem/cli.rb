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
      command = argv[0] or raise Error.new(help)

      # TODO: find gem name from the command
      # TODO: find all versions of the gem
      # TODO: execute the command with each version
    end

    def help
      <<~HELP
        Usage: all-ruby [all-ruby options] COMMAND_NAME [command options]
      HELP
    end
  end
end
