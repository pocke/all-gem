require_relative '../test_helper'

class AllGemCLITest < Test::Unit::TestCase
  def test_no_options
    cli = cli()
    cli.run(%w[rbs --version])
    assert_match(/^rbs-[\w.]+\s+/, cli.stdout.string)
    assert cli.stderr.string.empty?
  end

  def test_major_option
    cli = cli()
    cli.run(%w[--major --remote rbs --version])
    assert_equal ['rbs-0'], cli.stdout.string.scan(/^rbs-0/)
    assert_equal ['rbs-1'], cli.stdout.string.scan(/^rbs-1/)
    assert_equal ['rbs-2'], cli.stdout.string.scan(/^rbs-2/)

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
