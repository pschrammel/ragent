module Ragent
  class Command

    include Ragent::Logging

    attr_reader :main, :sub
    def initialize(main:, sub:, recipient:, method:)
      @main=main
      @sub=sub
      @recipient=recipient
      @method=method
    end

    def execute #(*args)
      info "running: #{@main} #{@sub}, calling: #{@method}"
      @recipient.send(@method)
    end

    def help
      "#{@main} #{@sub}"
    end  end
end