// Card (color, rank)

// Player (id, name, hand []Card, knowledge []CardInfo)

// CardInfo (rank, color, cards[])

import _ from 'lodash'

const gameState = {
  fuse_counter: 4,
  hint_tokens: 8,
  players: [],
  deck: [],
  discarded: []
}

const initialize = (message) => {
  console.log(message)
}

initialize('hello world')
