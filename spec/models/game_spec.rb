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
end
