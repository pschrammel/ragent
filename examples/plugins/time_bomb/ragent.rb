class TimeBomb

  class TestBomb
    include Celluloid
    include Celluloid::Notifications
    def initialize
      async.start
    end


    def start
      while true do
        puts Time.now
        sleep 5
      end
    end
    def stop

    end
  end


  include Ragent::Logging

  def initialize(ragent)
    @ragent=ragent
    @logger=ragent.logger
  end

  def configure
    info "configuring TimeBomb"
  end

  def start
    info "starting timebomb"
    @ragent.supervisor.supervise(
      type: TimeBomb::TestBomb,
      as: :time_bomb
    )
  end

  def stop

  end
  def name
    'TimeBomb'
  end

end
