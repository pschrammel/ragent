# frozen_string_literal: true
require_relative 'time_bomb/bomb'

module Ragent
  module Plugin
    class TimeBomb
      include Ragent::Plugin

      plugin_name 'time_bomb'
      commands :tick, :list, :disarm

      def configure(*_args)
        @next_time_bomb_id = 1
        @time_bombs = {}
        subscribe('time-bomb-boom', :boom_callback)
      end

      def command_disarm(options)
        bomb_name = "time_bomb_#{options['bomb']}"
        bomb = agents(bomb_name)
        if bomb
          bomb.terminate
          @time_bombs.delete(bomb_name)
          "terminated #{bomb_name}"
        else
          "no such bomb #{bomb_name}"
        end
      end

      def command_list(_options)
        @time_bombs.keys.join("\n")
      end

      def command_tick(_options)
        # how to track the bombs to disarm them?
        as = "time_bomb_#{@next_time_bomb_id}"
        @time_bombs[as] = true
        @next_time_bomb_id += 1

        agent(type: TimeBomb::Bomb, as: as)

        "starting #{as}"
      end

      def boom_callback(_topic, params)
        debug "boom: #{params.inspect}"
      end
    end
  end
end

Ragent.ragent.plugins.register(Ragent::Plugin::TimeBomb)
