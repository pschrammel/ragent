# frozen_string_literal: true
require 'thor'

module Ragent
  module Cli
    class Main < ::Thor
      desc 'start', 'starts the ragent framweork reading your config.ragent file'
      option :log_level, banner: '<debug|info|warn|error|fatal> overrides ENV RAGENT_LOG_LEVEL'
      option :root, banner: '<DIR> the root of the app (default is the pwd)'
      def start
        Ragent.start(workdir: options[:root],
                     log_level: options[:log_level],
                     blocking: true)
      end

      long_desc <<-LONGDESC
ragent console will start an irb console in your terminal. CAUTION when exiting the console
currently the agent won't shutdown cleanly.
LONGDESC
      desc 'console', 'start your application but gives you a console'
      option :log_level, banner: '<debug|info|warn|error|fatal> overrides ENV RAGENT_LOG_LEVEL'
      option :root, banner: '<DIR> the root of the app (default is the pwd)'
      def console
        Ragent.start(workdir: options[:root],
                     log_level: options[:log_level],
                     blocking: false)
        require 'irb'
        ARGV.clear # see http://stackoverflow.com/questions/33070092/irb-start-not-starting
        IRB.start
      end

      # def plugin
      #  puts "TBD: create a new plugin structure"
      # end

      # def new
      #  puts "TBD: create a new ragent app"
      # end

      desc 'version', 'prints version of metoda-cli'
      def version
        puts Ragent::VERSION.to_s
      end
    end
  end
end
