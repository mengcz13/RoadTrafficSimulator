'use strict'

require '../helpers'
_ = require 'underscore'
ControlSignals = require './control-signals'
Rect = require '../geom/rect'
Sensor = require './sensor'

class Intersection
  constructor: (@rect) ->
    @id = _.uniqueId 'intersection'
    @roads = []
    @inRoads = []
    @controlSignals = new ControlSignals this
    @carsPositions = {}
    @setSensor()

  @copy: (intersection) ->
    intersection.rect = Rect.copy intersection.rect
    result = Object.create Intersection::
    _.extend result, intersection
    result.roads = []
    result.inRoads = []
    result.controlSignals = ControlSignals.copy result.controlSignals, result
    result

  toJSON: ->
    obj =
      id: @id
      rect: @rect
      controlSignals: @controlSignals

  update: ->
    road.update() for road in @roads
    road.update() for road in @inRoads

  addCarPosition: (carPosition) ->
    throw Error 'car is already here' if carPosition.id of @carsPositions
    @carsPositions[carPosition.id] = carPosition

  removeCar: (carPosition) ->
    throw Error 'removing unknown car' unless carPosition.id of @carsPositions
    delete @carsPositions[carPosition.id]

  setSensor: ->
    # set 1 sensor for each intersection
    @sensor = new Sensor

  updateSensor: ->
    # update after we iterate over ALL cars!
    newCarList = _.map @carsPositions, (carPosition) -> carPosition.car
    @sensor.update newCarList

module.exports = Intersection
