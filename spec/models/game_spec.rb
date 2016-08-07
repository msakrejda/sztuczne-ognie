require "spec_helper"

describe Game do
  describe Game::Card do
    describe "#id" do
      let(:card) { Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1) }

      it "is the card's id" do
        expect(card.id).to eq(0)
      end
    end

    describe "#color" do
      let(:card) { Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1) }
      
      it "is the card's color" do
        expect(card.color).to eq('red')
      end
    end

    describe "#value" do
      let(:card) { Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1) }
      
      it "is the card's value" do
        expect(card.value).to eq(1)
      end
    end
  end

  describe Game::Deck do
    describe "#empty?" do
      it "is true with an empty deck" do
        deck = Game::Deck.new([])
        expect(deck).to be_empty
      end

      it "is false with a non-empty deck" do
        deck = Game::Deck.new([ { 'id' => 1, 'color' => 'red', 'value' => 1 } ])
        expect(deck).to_not be_empty
      end
    end

    describe "#draw" do
      it "removes and returns the next card" do
        deck = Game::Deck.new([ { 'id' => 0, 'color' => 'blue', 'value' => 3 },
                                { 'id' => 1, 'color' => 'red', 'value' => 1 },
                                { 'id' => 2, 'color' => 'green', 'value' => 2 } ])
        3.times do |n|
          next_card = deck.draw
          expect(next_card).to be_a(Game::Card)
          expect(next_card.id).to eq(n)
        end

        expect(deck).to be_empty
      end

      it "returns nil when the deck is empty" do
        deck = Game::Deck.new([])
        expect(deck.draw).to be_nil
      end
    end
  end

  describe Game::Hand do
    let(:card) { { 'id' => 0, 'color' => 'blue', 'value' => 3 } }

    describe "#cards" do
      let(:hand) { Game::Hand.new('cards' => [ card ]) }

      it "lists the cards in hand" do
        cards = hand.cards
        expect(cards.length).to eq(1)

        card_in_hand = cards.first
        expect(card_in_hand).to be_a(Game::Card)
        expect(card_in_hand.state).to eq(card)
      end
    end

    describe "#add" do
      let(:hand) { Game::Hand.new('cards' => []) }

      it "adds a card to the hand" do
        hand.add(Game::Card.new(card))
        cards = hand.state.fetch('cards')
        expect(cards.length).to eq(1)
        c = cards.first
        expect(c).to eq(card)
      end
    end

    describe "#add_hint" do
      let(:hand) { Game::Hand.new('hints' => []) }

      it "adds hints about color" do
        hint = { card_id: 1, color: 'red' }
        hand.add_hint(**hint)
        expect(hand.state['hints'].length).to eq 1
        expect(hand.state['hints'].first['card_id']).to eq hint[:card_id]
        expect(hand.state['hints'].first['color']).to eq hint[:color]
      end

      it "adds hints about value" do
        hint = { card_id: 1, value: 3 }
        hand.add_hint(**hint)
        expect(hand.state['hints'].length).to eq 1
        expect(hand.state['hints'].first['card_id']).to eq hint[:card_id]
        expect(hand.state['hints'].first['value']).to eq hint[:value]
      end

      it "ignores duplicate hints" do
        hint = { card_id: 1, value: 3 }
        hand.add_hint(**hint)
        hand.add_hint(**hint)
        expect(hand.state['hints'].length).to eq 1
        expect(hand.state['hints'].first['card_id']).to eq hint[:card_id]
        expect(hand.state['hints'].first['value']).to eq hint[:value]
      end
    end

    describe "#remove" do
      let(:other_card) { { 'id' => 2, 'color' => 'green', 'value' => 3 } }
      let(:hand)       { Game::Hand.new('cards' => [ card, other_card ]) }

      it "removes a card from the hand and returns it" do
        result = hand.remove(card['id'])
        cards = hand.state.fetch('cards')
        expect(cards.length).to eq(1)
        expect(cards.first).to eq(other_card)

        expect(result.state).to eq(card)
      end

      it "raises if the card is not in hand" do
        expect do
          hand.remove(999)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe Game::Field do
    describe "#playable?" do
      it "is true if there is a position for this card" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1)
        f = Game::Field.new({})
        expect(f.playable?(card)).to be true
      end

      it "is false if the appropriate lane is not yet ready for this card" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 2)
        f = Game::Field.new({})
        expect(f.playable?(card)).to be false
      end

      it "is false if a card of same color and value has already been played" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1)
        f = Game::Field.new('red' => [ { 'id' => 1, 'color' => 'red',
                                         'value' => 1 } ] )
        expect(f.playable?(card)).to be false
      end
    end

    describe "#lane" do
      it "returns the relevant lane" do
        card_state = { 'id' => 0, 'color' => 'red', 'value' => 2 }
        f = Game::Field.new('red' => [ card_state ] )
        expect(f.lane('red')).to be_a Array
        expect(f.lane('red').length).to eq 1
        expect(f.lane('red').first).to eq card_state
        expect(f.lane('green')).to be_a Array
        expect(f.lane('green')).to be_empty
      end
    end

    describe "#play" do
      it "raises if the card is not playable" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 2)
        f = Game::Field.new({})
        expect(f.playable?(card)).to be false
        expect do
          f.play(card)
        end.to raise_error(ArgumentError)
      end

      it "places the card in an existing lane" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1)
        f = Game::Field.new('red' => [])
        expect(f.playable?(card)).to be true
        f.play(card)
        expect(f.lane(card.color)).to include(card.state)
      end

      it "allocates a new lane if necessary" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1)
        f = Game::Field.new({})
        expect(f.playable?(card)).to be true
        f.play(card)
        expect(f.lane(card.color)).to include(card.state)
      end

      it "returns true if the card completes a lane" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 5)
        f = Game::Field.new('red' => 4.times.map do |n|
                              { 'id' => n, 'color' => 'red', 'value' => (n + 1) }
                            end)
        expect(f.playable?(card)).to be true
        expect(f.play(card)).to be true
      end

      it "returns false if the card does not complete a lane" do
        card = Game::Card.new('id' => 0, 'color' => 'red', 'value' => 1)
        f = Game::Field.new({})
        expect(f.playable?(card)).to be true
        expect(f.play(card)).to be false
      end
    end

    describe "#completed?" do
      it "is true if the field has been completed" do
        id = 0
        f = Game::Field.new(Hash[Config.colors.map do |color|
                                   [ color, Config.values.map do |v|
                                       id += 1
                                       { 'id' => id, 'color' => color,
                                         'value' => v }
                                     end ]
                                 end])
        expect(f.completed?).to be true
      end

      it "is false if the field has not been completed" do
        id = 0
        f = Game::Field.new(Hash[Config.colors.map do |color|
                                   [ color, Config.values.reject do |v|
                                       v == 5 && color == 'red'
                                     end.map do |v|
                                       id += 1
                                       { 'id' => id, 'color' => color,
                                         'value' => v }
                                     end ]
                                 end])
        expect(f.completed?).to be false
      end
    end
  end
end
