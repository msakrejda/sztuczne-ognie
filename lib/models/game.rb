class Game < Sequel::Model
  plugin :timestamps

  many_to_many :players

  def before_create
    super
    self.state = new_state
  end

  def state
    @state ||= super.to_h
  end

  def state=(value)
    @state = value
    super(Sequel.json(value))
  end

  def started?
    !started_at.nil?    
  end

  def finished?
    !finished_at.nil?
  end

  class Card
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def id
      @state.fetch(:id)
    end

    def is_color?(color)
      @state.fetch(:color) == color
    end

    def is_value?(value)
      @state.fetch(:value) == value
    end
  end

  class Deck
    def initialize(state)
      @state = state
    end

    def draw
      card_state = @state.shift
      Card.new(card_state) unless card_state.nil?
    end

    def empty?
      @state.empty?
    end
  end

  class Hand
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def cards
      state.fetch(:cards).map { |c| Card.new(c) }
    end

    def add(card)
      state.fetch(:cards).push(card.state)
    end

    def has_hint?(card_id:, color: nil, value: nil)
      state[:hints].any? do |hint|
        hint[:card_id] == card_id && hint[:color] == color && hint[:value] = value
      end
    end

    def add_hint(card_id:, color: nil, value: nil)
      if has_hint?(card_id: card_id, color: color, value: value)
        raise ArgumentError, "Cannot duplicated existing hint"
      end

      hint = { card_id: card_id }
      hint[:color] = color unless color.nil?
      hint[:value] = value unless value.nil?

      state[:hints].push(hint)
    end

    def remove(card_id)
      removed = nil
      state.fetch(:cards).reject! do |c|
        if c.fetch(:id) == card_id
          removed = c
          true
        end
      end
      if removed.nil?
        raise ArgumentError, "Card #{card_id} not in hand"
      end
      Card.new(removed)
    end
  end

  class Field
    def initialize(state)
      @state = state
    end

    def playable?(card)
      lane = @state.fetch(card.color, [])
      if lane.empty?
        card.value == 1
      else
        lane.last.value + 1 == card.value
      end
    end

    def play(card)
      unless playable?(card)
        raise ArgumentError, "Card #{card} is not playable this turn"
      end

      lane = @state[card.color.to_sym]
      if lane.nil?
        lane = []
        @state[card.color.to_sym] = lane
      end

      completes = lane.length + 1 == Config.values.length

      lane.push(card.state)

      if @state.values.all? { |l| l.length == Config.values.length }
        self.finished_at = Time.now
      end

      completes
    end
  end

  def hint_color(player, target_player_id, color)
    taking_turn(player) do
      check_color(color)
      spend_hint

      target_player = find_player(target_player_id)

      hand = hand_for(target_player)
      hinted = hand.cards.select { |c| c.is_color?(color) }

      if hinted.empty?
        raise ArgumentError,
              "Cannot give hint that does not apply to any card in hand"
      end

      hinted.each { |card| hand.add_hint(card: card.id, color: color) }
    end
  end

  def hint_value(player, target_player, value)
    taking_turn(player) do
      check_value(value)
      spend_hint

      target_player = find_player(target_player_id)

      hand = hand_for(target_player)
      hinted = hand.cards.select { |c| c.is_value?(value) }

      if hinted.empty?
        raise ArgumentError,
              "Cannot give hint that does not apply to any card in hand"
      end

      hinted.each { |card| hand.add_hint(card: card.id, value: value) }
    end
  end

  def play(player, card_id)
     taking_turn(player) do
      hand = hand_for(player)
      card = hand.remove(card_id)

      if field.playable?(card)
        completed_lane = field.play(card)
        reclaim_hint if completed_lane
      else
        dump(card)
        burn_fuse
      end
      return if finished?

      card = deck.draw
      unless card.nil?
        hand.add(card)
      end
    end
  end

  def discard(player, card_id)
    taking_turn(player) do
      unless can_discard?
        raise ArgumentError, "Cannot discard when max hints available"
      end

      hand = hand_for(player)
      card = hand.remove(card_id)
      dump(card)
      reclaim_hint
    end
  end

  private

  def check_color(color)
    unless Config.colors.include?(color)
      raise ArgumentError, "Unknown color #{color.inspect}; valid colors are #{Config.colors}"
    end
  end

  def check_value(value)
    unless Config.values.include?(value)
      raise ArgumentError, "Unknown value #{value.inspect}; valid values are #{Config.values}"      
    end
  end

  def deck
    @deck ||= Deck.new(state.fetch(:deck))
  end

  def field
    @field ||= Field.new(self, state.fetch(:field))
  end

  def hand_for(player)
    not_found = Proc.new do
      raise ArgumentError, "Could not find hand for player #{player.name}"
    end
    Hand.new(self,
             state.fetch(:hands)
               .find(not_found) { |h| h[:player_id] == player.id })
  end

  def taking_turn(player)
    unless started?
      raise ArgumentError, "Cannot take move in a game that has not started"
    end

    if finished?
      raise ArgumentError, "Cannot take move in finished game"
    end

    unless player == current_player
      raise ArgumentError, "Cannot take move on another player's turn"
    end

    yield

    modified! :state

    return if finished?

    if deck.empty?
      if last_player_id.nil?
        self.last_player_id = current_player.id
      elsif last_player_id == current_player.id
        self.finished_at = Time.now
      end
    end

    self.current_player = next_player.id
  end

  def spend_hint
    unless can_hint?
      raise ArgumentError, "No hints available"
    end

    state[:hint_counter] -= 1
  end

  def reclaim_hint
    return if state[:hint_counter] == Config.hint_count

    state[:hint_counter] += 1
  end

  def can_hint?
    state.fetch(:hint_counter) > 0
  end

  def dump(card)
    state[:discarded].push(card.state)
  end

  def burn_fuse
    state[:fuse_counter] -= 1
    unless state[:fuse_counter] > 0
      self.finished_at = Time.now
    end
  end

  def can_discard?
    state.fetch(:hint_counter) < Config.hint_count
  end

  def hand_size
    if players.count < 4
      5
    else
      4
    end
  end

  def deal
    hands = players.each_with_object({}) do |player, obj|
      obj[player.id] = Hand.new(player_id: player.id, cards: [], hints: [])
    end
    hand_size.times do |n|
      players.each do |p|
        hand = hands[p.id]
        hand.add(deck.draw)
      end
    end
    state[:hands] = hands.values.map(&:state)
  end

  def new_state
    { ready: [],

      fuse_counter: Config.fuse_len,
      hint_counter: Config.hint_count,
      deck: new_deck.shuffle,
      field: {},
      discarded: [],
      hands: [] }
  end

  def sorted_players
    players.sort_by(&:id)
  end

  def current_player
    player_id = state[:current_player]
    if player_id.nil?
      sorted_players.first
    else
      find_player(player_id)
    end
  end

  def current_player=(value)
    state[:current_player] = value.id
  end

  def next_player
    idx = sorted_players.index(current_player)
    if idx == players.count - 1
      next_player = sorted_players.first
    else
      next_player = sorted_players[idx + 1]
    end
  end

  def find_player(player_id)
    not_found = Proc.new do
      raise ArgumentError, "Could not find player #{player_id}"
    end

    players.find(not_found) { |p| p.id == player_id }
  end

  def last_player_id=(player)
    state[:last_player] = player.id
  end

  def last_player_id
    state.fetch(:last_player)
  end

  def new_deck
    Config.colors.product(Config.values).map.each_with_index do |(color, value), index|
      Card.new(card_id: index, color: color, value: value)
    end
  end
end
