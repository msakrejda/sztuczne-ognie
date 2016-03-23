// Card (color, value)

// Player (id, name, hand []Card, knowledge []CardInfo)

// CardInfo (value, color, cards[])

import _ from 'lodash'

const game = {
  id: '',
  players: [],

  fuse_counter: 4,
  hint_tokens: 8,
  deck: [],
  discarded: [],
  field: [],

  turn: 'player_id'
}

const app = {
  controller: () => {

  },
  view: () => {

  }
}

handSize = (playerCount) => {
  if (playerCount < 3) {
    return 5
  } else {
    return 4
  }
}

isNext = (lane, card) => {
  if (lane.length === 0) {
    return card.value === 1
  }
  let last = lane[lane.length - 1]
  return last.color === card.color && (last.value + 1) === card.value
}

class Field {
  constructor (discarded) {
    this.lanes = {}
    this.discarded = discarded
  }

  play (card) {
    let lane = this.lanes[card.color]
    if (lane === undefined) {
      lane = []
      this.lanes[card.color] = lane
    }
    if (isNext(lane, card)) {
      lane.push(card)
      return true
    } else {
      return false
    }
  }
}

class Player {
  constructor(id, name) {
    this.id = id
    this.name = name
    this.hand = []
    this.info = []
  }

  drawCard (deck) {
    if (deck.length > 0) {
      this.hand.push(deck.shift())
    }
  }

  discard (card, discardPile) {
    let cardIdx = this.hand.indexOf(card)
    if (cardIdx > 0) {
      this.hand.splice(cardIdx, 1)
      discardPile.push(cardIdx)
    }
  }

  learn (info) {
    if (info.value) {
      this.info.push(this.hand.select(card => card.value == info.value))
    } else if (info.color) {
      this.info.push(this.hand.select(card => card.color == info.color))
    } else {
      // throw
    }
  }
}

contents = (hand) => {
  return {
    values: _.uniq(hand.map(card => card.value)),
    colors: _.uniq(hand.map(card => card.color))
  }
}

deal = () => {
  for (let i = 0; i < handSize(players.length); i++) {
    players.forEach(player => player.drawCard(deck))
  }
}

addPlayer = (id, name) => {
  game.players.push(new Player(id, name))
}

// player can:
//  - play a card
//  - discard a card
//  - give information

playCard = (card) => {
  // remove card from hand
  // attempt to play on the field
  // if (success) {
  //   - if played card was value 5, claim token if available
  //   - draw card
  // } else {
  //   push on discard pile
  //   tick down fuse counter
  //   if fuse counter at zero
  //     - lose game
  //   else
  //     - draw card
  // }
}

tell = (player, info) => {
  // info is like { value: 2 } or { color: 'red' }
  // raise if no cards match
}

discard = (card) => {
  
}
