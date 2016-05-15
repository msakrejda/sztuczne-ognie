// Game is a series of Moves

// Move is either:
//   - play
//   - tell
//   - discard
//

playCard = (card) => {
  // remove card from hand
  // attempt to play on the field
  // if (success) {
  //   - if played card was value 5, increment hint_counter if != MAX_HINTS
  // } else {
  //   push on discard pile
  //   tick down fuse counter
  //   if fuse counter at zero
  //     - lose game
  // }
  // draw card if possible
}

// when drawing last card, flag last round: each player plays once,
// including the player who drew last card

tell = (player, info) => {
  // raise if no cards match
  // raise if hint_tokens is zero

  // give player the info (info is like { value: 2 } or { color: 'red' })
  // decrement hint_tokens
}

discard = (card) => {
  if (game.hint_tokens == MAX_HINTS) {
    // raise
  }

  // remove card from player's hand
  // place it on discard pile
  // increment hint_tokens
}



// player can:
//  - play a card
//  - discard a card
//  - give information


// Card (color, value)

// Player (id, name, hand []Card, knowledge []CardInfo)

// CardInfo (value, color, cards[])

// on the field, show:
//  - hint tokens
//  - fuse
//  - other players' hands
//  - own hand, obfuscated
//  - field
//  - discard pile (can be looked through eventually)
//  - indicate whose turn it is

import _ from 'lodash'

// submit turns to server
// connect via websocket, apply state changes as they come in

// an action takes the game state and a payload from the server
// and produces a new game state
const actions = {
  initialize = (game, data) => {
    return data
  }

  add_player = (game, data) => {
    let delta = { players: game.players.concat(new Player(data)) }
    return Object.assign({}, game, delta)
  }

  

  

  
}

class Turn {
  apply() {
    
  }
}

class Discard {
  
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

class Card {
  constructor(color, value) {
    this.color = color
    this.value = value
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
      return true
    } else {
      return false
    }
  }

  discard (card, discarded) {
    let cardIdx = this.hand.indexOf(card)
    if (cardIdx > 0) {
      this.hand.splice(cardIdx, 1)
      discarded.push(card)
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

deal = (deck, players) => {
  for (let i = 0; i < handSize(players.length); i++) {
    players.forEach(player => player.drawCard(deck))
  }
}

addPlayer = (id, name) => {
  game.players.push(new Player(id, name))
}

buildDeck = () => {
  let deck = []
  for (let value = 1; value <= 5; value++) {
    COLORS.forEach(color => deck.push(new Card(color, value)))
  }
}
