class Mediators::Join < Mediators::Base
  def initialize(game:, player:)
    if game.started?
      raise ArgumentError, "Cannot join already-started game"
    end

    @game = game
    @player = player
  end

  def call
    @game.add_player(@player)
  end
end
