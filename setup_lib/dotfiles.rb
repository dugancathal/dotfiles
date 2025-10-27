require "pathname"
require "fileutils"

module ClassConf
  def clatter(name, default: nil)
    ivar_name = "@#{name}"
    define_singleton_method(name) do
      return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
      
      instance_variable_set(ivar_name, default)
      default
    end

    define_singleton_method("#{name}=") do |other|
      instance_variable_set(ivar_name, other)
    end

    define_singleton_method("with_#{name}") do |other, &block|
      original = instance_variable_get(ivar_name)
      instance_variable_set(ivar_name, other)
      block.call(other)
    ensure
      instance_variable_set(ivar_name, original)
    end
  end
end

module Dotfiles
  IGNORED_FILES = %w[Rakefile Gemfile Gemfile.lock README.md LICENSE setup_lib .git bootstrap.sh]

  extend ClassConf

  clatter :dest, default: Pathname(Dir.home)
  clatter :source, default: Pathname(File.expand_path("..", __dir__))

  def self.os_name(host_os = RbConfig::CONFIG['host_os'])
    case host_os
      when /linux/ then 'linux'
      when /darwin/ then 'mac'
      else raise "OS not supported: #{host_os}"
    end
  end

  def self.merge_install
    MergeInstallation.new.call(to: dest, from: source)
  end

  def self.link_files
  end

  module Ui
    def self.console = ConsoleUi.new
    def self.recording = RecordingUi.new

    class ConsoleUi
      def initialize(stdout = $stdout, stdin = $stdin)
        @stdout = $stdout
        @stdin = $stdin
        @do_all = false
      end

      def ask(query)
        return true if do_all_after_ask?
        @stdout.print "#{query} [ynaq] "

        case @stdin.gets.chomp
        when /y/i then true
        when /n/i then false
        when /a/i then @do_all = true
        when /q/i then exit
        end
      end

      def do_all_after_ask? = @do_all
    end
  end

  class MergeInstallation
    def initialize(ui = Ui.console)
      @ui = ui
    end

    def call(to:, from:, ignore: IGNORED_FILES, dest_file_prefix: ".")
      from.children.each do |source_file|
        next if ignore.include?(source_file.basename.to_s)

        dest_file = to.join("#{dest_file_prefix}#{source_file.basename}")
        next call(to: dest_file, from: source_file, ignore:, dest_file_prefix: "") if dest_file.directory?

        next merge_content(to: dest_file, from: source_file) if dest_file.exist?

        FileUtils.ln_s(source_file, dest_file)
      end
    end

    def merge_content(to:, from:)
      return if to.read.include?("===dotfiles===\n")
      to.open("a") do |f|
        f.write(from.read)
      end
    end
  end
end
