'use strict'

require '../helpers'
_ = require 'underscore'
Segment = require '../geom/segment'
Sensor = require './sensor'

class Lane
  constructor: (@sourceSegment, @targetSegment, @road, @sensorNum) ->
    @leftAdjacent = null
    @rightAdjacent = null
    @leftmostAdjacent = null
    @rightmostAdjacent = null
    @carsPositions = {}
    @update()
    @setSensors()

  toJSON: ->
    obj = _.extend {}, this
    delete obj.carsPositions
    obj

  @property 'sourceSideId',
    get: -> @road.sourceSideId

  @property 'targetSideId',
    get: -> @road.targetSideId

  @property 'isRightmost',
    get: -> this is @.rightmostAdjacent

  @property 'isLeftmost',
    get: -> this is @.leftmostAdjacent

  @property 'leftBorder',
    get: ->
      new Segment @sourceSegment.source, @targetSegment.target

  @property 'rightBorder',
    get: ->
      new Segment @sourceSegment.target, @targetSegment.source

  update: ->
    @middleLine = new Segment @sourceSegment.center, @targetSegment.center
    @length = @middleLine.length
    @direction = @middleLine.direction

  getTurnDirection: (other) ->
    return @road.getTurnDirection other.road

  getDirection: ->
    @direction

  getPoint: (a) ->
    @middleLine.getPoint a

  addCarPosition: (carPosition) ->
    throw Error 'car is already here' if carPosition.id of @carsPositions
    @carsPositions[carPosition.id] = carPosition

  removeCar: (carPosition) ->
    throw Error 'removing unknown car' unless carPosition.id of @carsPositions
    delete @carsPositions[carPosition.id]

  getNext: (carPosition) ->
    throw Error 'car is on other lane' if carPosition.lane isnt this
    next = null
    bestDistance = Infinity
    for id, o of @carsPositions
      distance = o.position - carPosition.position
      if not o.free and 0 < distance < bestDistance
        bestDistance = distance
        next = o
    next

  setSensors: ->
    @sensors = []
    @relativeSensorInterval = 1.0 / @sensorNum
    for i in [0..@sensorNum - 1]
      @sensors[i] = new Sensor this, @relativeSensorInterval * i, @relativeSensorInterval * (i + 1)

  updateSensors : ->
    newCarLists = []
    for i in [0..@sensorNum - 1]
      newCarLists[i] = []
    for id, carPosition of @carsPositions
      relativePosition = carPosition.relativePosition
      if relativePosition >= 0 && relativePosition <= 1
        car = carPosition.car
        sensorid = Math.floor (relativePosition / @relativeSensorInterval)
        newCarLists[sensorid].push car
    for i in [0..@sensorNum - 1]
      @sensors[i].update newCarLists[i]
      # if newCarLists[i].length > 1
      #   console.log @sensors[i]

module.exports = Lane
