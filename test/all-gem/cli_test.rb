require_relative '../test_helper'

class AllGemCLITest < Test::Unit::TestCase
  def test_no_options
    cli = cli()
    cli.run(%w[rbs --version])
    assert cli.stdout.string.include?('rbs-')
    assert cli.stderr.string.empty?
  end

  def test_major_option
    cli = cli()
    cli.run(%w[--major --remote rbs --version])
    assert cli.stdout.string.include?('rbs-0')
    assert cli.stdout.string.include?('rbs-1')
    assert cli.stdout.string.include?('rbs-2')
    refute cli.stdout.string.include?('rbs-0.20.0')
    refute cli.stdout.string.include?('rbs-1.6.1')

    assert cli.stderr.string.empty?
  end

  def test_no_args
    cli = cli()
    error = assert_raises AllGem::CLI::Error do
      cli.run([])
    end
    assert error.message.include?('COMMAND is not specified')
  end

  def cli
    AllGem::CLI.new(stdout: StringIO.new, stderr: StringIO.new, stdin: StringIO.new)
  end
end
