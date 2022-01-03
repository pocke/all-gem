module AllGem
  class CLI
    attr_reader :stdout, :stderr, :stdin

    def initialize(stdout:, stderr:, stdin:)
      @stdout = stdout
      @stderr = stderr
      @stdin = stdin
    end

    def run
      1
    end
  end
end
