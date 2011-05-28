golem = require("./golem")
vowpal = require("./vowpal")
card_info = require("./card_info").card_info
tests = exports

SUPPLY = {
  "Province": [4,8]
  "Duchy": [3,5]
  "Estate": [2,2]
  "Curse": [3,0]
}

tests['buy no cards'] = (test) ->
  choices = golem.buyChoices(SUPPLY, 10, 0, 0)
  test.deepEqual choices, [[]]
  test.done()

tests['buy one card for 6'] = (test) ->
  choices = golem.buyChoices(SUPPLY, 6, 0, 1)
  choices.sort()
  test.deepEqual choices, [[], ["Curse"], ["Duchy"], ["Estate"]]

  test.done()

tests['buy two cards for 8'] = (test) ->
  choices = golem.buyChoices(SUPPLY, 8, 0, 2)
  choices.sort()
  test.deepEqual choices, [
    []
    ["Curse"]
    ["Curse", "Curse"]
    ["Curse", "Duchy"]
    ["Curse", "Estate"]
    ["Curse", "Province"]
    ["Duchy"]
    ["Estate"]
    ["Estate", "Duchy"]
    ["Estate", "Estate"]
    ["Province"]
  ]

  test.done()

tests['buy out the estates'] = (test) ->
  choices = golem.buyChoices(SUPPLY, 6, 2, 6)
  choices.sort()
  test.deepEqual choices, [
    []
    ["Duchy"]
    ["Estate"]
    ["Estate", "Estate"]
  ]
  test.done()

DECK = {
  'Copper': 7
  'Estate': 3       # 3 VP     
  'Silver': 2
  'Gardens': 1      # 1 VP
  'Fairgrounds': 1  # 2 VP
  'Smithy': 2
  'vp': 8           # contains 2 chips
}

STARTDECK = {
  'Copper': 7
  'Estate': 3
  'vp': 3
}

SUPPLY2 = {
  'Province': [8,8]
  'Duchy': [8,5]
  'Mountebank': [10,5]
  'Festival': [10,5]
  'Smithy': [10,4]
  'Estate': [8,2]
  'Curse': [10,0]
}

tests['card info makes sense'] = (test) ->
  test.equal card_info['Copper'].isAction, false
  test.done()

tests['deck features'] = (test) ->
  features = golem.getDeckFeatures(DECK)
  test.equal features.n, 16
  test.equal features.nUnique, 6
  test.equal features.nActions, 2
  test.equal features.vp, 8
  test.equal features.cardvp, 6
  test.equal features.chips, 2
  test.equal features.deck['Copper'], 7
  test.equal features.unique['Copper'], 1
  test.equal features.deck['vp'], undefined
  test.equal features.unique['vp'], undefined
  test.done()

tests['normalize cards in starting deck'] = (test) ->
  norm = golem.normalizeDeck(golem.getDeckFeatures(STARTDECK))
  test.equal norm.Estate, 1.5
  test.equal norm.Copper, 3.5
  test.done()

tests['normalize features of starting deck'] = (test) ->
  norm = golem.normalizeDeck(golem.getDeckFeatures(STARTDECK))
  #test.equal norm.unique, 0.4
  #test.equal norm.n, 1.0
  test.equal norm.vp, 0.3
  test.equal norm.actions, 0
  test.done()

tests['overly simplified feature string'] = (test) ->
  featString = vowpal.featureString(
    'Test features',
    {me: DECK, you: STARTDECK}
  )
  test.equal featString, '0 1 "Test_features"|me Copper:7 Estate:3 Silver:2 Gardens:1 Fairgrounds:1 Smithy:2 vp:8 |you Copper:7 Estate:3 vp:3'
  test.done()

failure = (obj) -> test.ok(false)
tests['buy a Mountebank early'] = (test) ->
  test.expect(1)
  golem.chooseGain DECK, STARTDECK, SUPPLY2, 8, 1, 3, {
    succeed: (obj) ->
      test.deepEqual obj.best, ["Mountebank"]
      test.done()
    fail: failure
  }

tests['buy a Province later'] = (test) ->
  golem.chooseGain DECK, DECK, SUPPLY2, 8, 1, 24, {
    succeed: (obj) ->
      test.deepEqual obj.best, ["Province"]
      test.done()
    fail: failure
  }

tests['two provinces are better than one'] = (test) ->
  golem.chooseGain DECK, DECK, SUPPLY2, 16, 2, 15, {
    succeed: (obj) ->
      test.deepEqual obj.best, ["Province","Province"]
      test.done()
    fail: failure
  }
