module Ragent
  class Command

    include Ragent::Logging

    attr_reader :main, :sub
    def initialize(main:, sub: nil, recipient:, method:)
      @main=main.to_s
      @sub=sub.to_s
      @recipient=recipient
      @method=method
    end

    def execute(options={})
      info "running: #{@main} #{@sub}, calling: #{@method}"
      @recipient.send(@method,options)
    end

    def sub?
      !sub.empty?
    end

    def help
      "#{@main} #{@sub}"
    end  end
end
