require "pry"

class PsParser
  def initialize(line)
    @line = line
  end

  {
    :uid  => 0,
    :pid  => 1,
    :ppid => 2,
    :c    => 3
  }.each_pair do |meth, i|
    define_method meth do
      number_matches[i]
    end
  end

  def stime
    line[/(\d{2}\w{3}\d{2})/]
  end

  def time
    line[/(\d{2}:\d{2}\.\d{2})/]
  end

  def cmd
    line[/(\S+)$/]
  end

  def tty
    Regexp.new(/\d{2}\w{3}\d{2}\s+(\S+)/)
      .match(line)
      .captures.first
  end

  private

  attr_reader :line

  def number_matches
    line.scan(/\d+/)
  end
end

class ParsePsOutput
  def tail
    loop do
      call
      sleep 1
    end
  end

  def call
    open("|ps -f | grep thin") do |f|
      puts "\n\n"

      f.each_line do |line|
        ps = PsParser.new(line)
        puts "PID: #{ps.pid} | CMD: #{ps.cmd}"
      end
    end
  end
end

# require "minitest"
require "minitest/autorun"

class TestMeme < Minitest::Test
  # "  UID   PID  PPID   C STIME   TTY           TIME CMD\n"
  def setup
    @line = <<-LINE
      0     1     0   0 12Jun15 ??   10:21.65 /sbin/launchd
    LINE
    @subject = PsParser.new(@line)
  end

  def test_uid_parses_correctly
    assert_equal @subject.uid, "0"
  end

  def test_pid_parses_correctly
    assert_equal @subject.pid, "1"
  end

  def test_ppid_parses_correctly
    assert_equal @subject.ppid, "0"
  end

  def test_c_parses_correctly
    assert_equal @subject.c, "0"
  end

  def test_stime_parses_correctly
    assert_equal @subject.stime, "12Jun15"
  end

  def test_tty_parses_correctly
    assert_equal @subject.tty, "??"
  end

  def test_time_parses_correctly
    assert_equal @subject.time, "10:21.65"
  end

  def test_cmd_parses_correctly
    assert_equal @subject.cmd, "/sbin/launchd"
  end
end

# ParsePsOutput.new.tail
