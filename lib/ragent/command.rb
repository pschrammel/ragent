module Ragent
  class Command

    include Ragent::Logging

    attr_reader :main, :sub
    def initialize(main:, sub: nil, recipient:, method:)
      @main=main
      @sub=sub
      @recipient=recipient
      @method=method
    end

    def execute(options={})
      info "running: #{@main} #{@sub}, calling: #{@method}"
      @recipient.send(@method,options)
    end

    def help
      "#{@main} #{@sub}"
    end  end
end
