require "pry"

class PsParser
  def initialize(line)
    @line = line
  end

  def uid
    number_matches[0]
  end

  def pid
    number_matches[1]
  end

  def ppid
    number_matches[2]
  end

  def c
    number_matches[3]
  end

  def stime
    Regexp.new(/(\d{2}\w{3}\d{2})/)
    .match(line)
    .captures.first
  end

  def tty
    Regexp.new(/\d{2}\w{3}\d{2}\s+(\S+)/)
    .match(line)
    .captures.first
  end

  def time
    Regexp.new(/(\d{2}:\d{2}\.\d{2})/)
    .match(line)
    .captures.first
  end

  def cmd
    Regexp.new(/(\S+)$/)
      .match(line.strip)
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

require "minitest"
# require "minitest/autorun"

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

ParsePsOutput.new.tail
