class Mediators::Play < Mediators::Base
  def initialize(game:, player:, card: card_id)
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
    @game.play(@player, card_id)
    @game.save_changes
  end
end
