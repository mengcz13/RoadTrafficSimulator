'use strict'

_ = require 'underscore'

class Sensor
  constructor: (@lane, @starting, @ending) ->
    @id = _.uniqueId 'Sensor'
    @carList = []
    @volumeIn = 0
    @volumeOut = 0

  @property 'carNum',
    get: -> @carList.length

  @property 'avgSpeed',
    get: ->
      speeds = _.map @carList, (car) -> car.speed
      return 0 if speeds.length is 0
      return (_.reduce speeds, (a, b) -> a + b) / speeds.length

  @property 'volume',
    get: -> @volumeOut

  update: (newCarList) ->
    sameCarList = _.intersection @carList, newCarList
    @volumeIn = newCarList.length - sameCarList.length
    @volumeOut = @carList.length - sameCarList.length
    @carList = newCarList

module.exports = Sensor