require "spec_helper"

describe Game do
  describe Game::Card do
    describe "#is_color?" do
      let(:card) { Game::Card.new(id: 0, color: 'red', value: 1) }
      
      it "is true when the card is of the specified color" do
        expect(card.is_color?('red')).to be true
      end

      it "is false when the card is of another color" do
        expect(card.is_color?('green')).to be false
      end
    end

    describe "#is_value?" do
      let(:card) { Game::Card.new(id: 0, color: 'red', value: 1) }
      
      it "is true when the card is of the specified value" do
        expect(card.is_value?(1)).to be true
      end

      it "is false when the card is of another value" do
        expect(card.is_value?(3)).to be false
      end
    end
  end

  describe Game::Deck do
    describe "#empty?" do
      it "is true with an empty deck" do
        deck = Game::Deck.new([])
        expect(deck).to be_empty
      end

      it "is false otherwise" do
        deck = Game::Deck.new([ { id: 1, color: 'red', value: 1 } ])
        expect(deck).to_not be_empty
      end
    end

    describe "#draw" do
      it "removes and returns the next card" do
        deck = Game::Deck.new([ { id: 0, color: 'blue', value: 3 },
                                { id: 1, color: 'red', value: 1 },
                                { id: 2, color: 'green', value: 2 } ])
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
    let(:card) { { id: 0, color: 'blue', value: 3 } }

    describe "#cards" do
      let(:hand) { Game::Hand.new(cards: [ card ]) }

      it "maps card state to card objects" do
        cards = hand.cards
        expect(cards.length).to eq(1)

        card_in_hand = cards.first
        expect(card_in_hand).to be_a(Game::Card)
        expect(card_in_hand.state).to eq(card)
      end
    end

    describe "#add" do
      let(:hand) { Game::Hand.new(cards: []) }

      it "adds a card to the hand" do
        hand.add(Game::Card.new(card))
        cards = hand.state.fetch(:cards)
        expect(cards.length).to eq(1)
        c = cards.first
        expect(c).to eq(card)
      end
    end

    describe "#remove" do
      let(:other_card) { { id: 2, color: 'green', value: 3 } }
      let(:hand)       { Game::Hand.new(cards: [ card, other_card ]) }

      it "removes a card from the hand and returns it" do
        result = hand.remove(card[:id])
        cards = hand.state.fetch(:cards)
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

    describe "#add_hint" do
      let(:hand) { Game::Hand.new(hints: []) }

      it "adds hints about color" do
        hint = { card_id: 1, color: 'red' }
        hand.add_hint(**hint)
        expect(hand.state[:hints]).to match_array([ hint ])
      end

      it "adds hints about value" do
        hint = { card_id: 1, value: 3 }
        hand.add_hint(**hint)
        expect(hand.state[:hints]).to match_array([ hint ])
      end

      it "refuses duplicate hints" do
        hint = { card_id: 1, value: 3 }
        hand.add_hint(**hint)

        expect do
          hand.add_hint(**hint)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
