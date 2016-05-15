class Mediators::Ready < Mediators::Base
  def initialize(game:, player:)
    if game.started?
      raise ArgumentError, "Cannot start an already-started game"
    end

    @game = game
    @player = player
  end

  def call
    @game.state.fetch(:ready).push(@player.id).uniq!
    @game.modified! :state
    @game.save_changes
  end
end
