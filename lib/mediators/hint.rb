class Mediators::Hint < Mediators::Base
  def initialize(game:, target_player:, color:, value:)
    @game = game
    @player = player
    @card_id = card_id
    @color = color
    @value = value
  end

  def call
    if @color.nil? != @value.nil?
      raise ArgumentError, "Must specify one and only one of color (#{@color.inspect}) or value (#{@value.inspect}"
    elsif @value.nil?
      @game.hint_color(target_player, @color)
    else
      @game.hint_value(target_player, @value)      
    end

    @game.save_changes
  end
end
