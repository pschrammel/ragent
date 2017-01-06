class TimeBomb

  class TestBomb
    include Celluloid
    include Celluloid::Notifications
    include Ragent::Logging

    finalizer :stop

    def initialize
      async.start
    end


    def start
      every(5) do
        publish 'time-bomb-boom', expode_at: Time.now
      end
    end

    def stop
      info "disarmed"
    end
  end


  include Ragent::Logging
  include Celluloid
  include Celluloid::Notifications

  def initialize(ragent)
    @ragent=ragent
    @logger=ragent.logger
    @next_time_bomb_id=1
    @time_bombs={}
  end

  def configure
    info "configuring TimeBomb"
    command("tick", :command_tick)
    command("list", :command_list)
    command("disarm", :command_disarm)
    subscribe('time-bomb-boom',:boom_callback)
  end

  def start
  end

  def stop
  end

  def name
    'time-bomb'
  end

  def command(sub, method)
    cmd=Ragent::Command.new(main: name,
                             sub: sub,
                             recipient: self,
                             method: method)
    @ragent.commands.add(cmd)
  end


  def command_disarm(options)
    bomb_name="time_bomb_#{options["bomb"]}"
    bomb=Actor[bomb_name]
    if bomb
      bomb.terminate
      @time_bombs.delete(bomb_name)
      "terminated #{bomb_name}"
    else
      "no such bomb #{bomb_name}"
    end
  end

  def command_list(options)
    @time_bombs.keys.join("\n")
  end

  def command_tick(options)
    # how to track the bombs to disarm them?
    as="time_bomb_#{@next_time_bomb_id}"
    @time_bombs[as]=true
    @next_time_bomb_id += 1

    @ragent.supervisor.supervise(
      type: TimeBomb::TestBomb,
      as: as
    )

    "starting timebomb"
  end

  def boom_callback(topic,params)
    debug "boom: #{params.inspect}"
  end
end
