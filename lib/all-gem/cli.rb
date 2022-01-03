module AllGem
  class CLI
    attr_reader :stdout, :stderr, :stdin

    def initialize(stdout:, stderr:, stdin:)
      @stdout = stdout
      @stderr = stderr
      @stdin = stdin
    end

    def run
      # TODO
    end
  end
end
