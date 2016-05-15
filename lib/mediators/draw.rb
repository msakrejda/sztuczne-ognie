class Mediators::Draw < Mediators::Base
  def initialize(game:, player:)
    unless game.started?
      raise ArgumentError, "Cannot draw in a game that has not yet started"
    end
    if game.finished?
      raise ArgumentError, "Cannot draw in a game that has already finished"
    end
    unless game.is_their_turn?(player)
      raise ArgumentError, "It's not #{player.name}'s turn"
    end

    @game = game
    @player = player
  end

  def call
    @game.draw(@player)
    @game.save_changes
  end
end
