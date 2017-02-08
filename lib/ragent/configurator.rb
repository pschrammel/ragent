module Ragent
  class Configurator
    include Ragent::Logging

    def initialize(ragent)
      @ragent=ragent
    end

    def self.load(ragent, filename)
      config=new(ragent)
      config._load(filename)
    end

    def _load(filename)
      instance_eval File.read(filename)
    end

    private

    def plugin(*args,&block)
      @ragent.add_plugin(*args,&block)
    end

  end
end
