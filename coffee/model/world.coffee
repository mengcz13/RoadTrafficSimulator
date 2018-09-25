'use strict'

{random} = Math
require '../helpers'
_ = require 'underscore'
Car = require './car'
Intersection = require './intersection'
Road = require './road'
Pool = require './pool'
Rect = require '../geom/rect'
settings = require '../settings'

class World
  constructor: ->
    @set {}
    @laneNum = 2
    @netSize = 5
    @sensorNum = 5

  @property 'instantSpeed',
    get: ->
      speeds = _.map @cars.all(), (car) -> car.speed
      return 0 if speeds.length is 0
      return (_.reduce speeds, (a, b) -> a + b) / speeds.length

  set: (obj) ->
    obj ?= {}
    @intersections = new Pool Intersection, obj.intersections
    @roads = new Pool Road, obj.roads
    @cars = new Pool Car, obj.cars
    @carsNumber = 0
    @time = 0

  save: ->
    data = _.extend {}, this
    delete data.cars
    localStorage.world = JSON.stringify data

  load: (data) ->
    data = data or localStorage.world
    data = data and JSON.parse data
    return unless data?
    @clear()
    @carsNumber = data.carsNumber or 0
    for id, intersection of data.intersections
      @addIntersection Intersection.copy intersection
    for id, road of data.roads
      road = Road.copy road
      road.source = @getIntersection road.source
      road.target = @getIntersection road.target
      @addRoad road

  generateMap: ->
    @clear()
    minX = 0
    maxX = @netSize - 1
    minY = 0
    maxY = @netSize - 1
    intersectionsNumber = (0.8 * (maxX - minX + 1) * (maxY - minY + 1)) | 0
    map = {}
    laneNum = @laneNum
    netSize = @netSize
    gridSize = settings.gridSize
    step = 5 * gridSize
    @carsNumber = 100
    sensorDist = step / @sensorNum
    while intersectionsNumber > 0
      x = _.random minX, maxX
      y = _.random minY, maxY
      unless map[[x, y]]?
        rect = new Rect step * x, step * y, gridSize, gridSize
        intersection = new Intersection rect
        @addIntersection map[[x, y]] = intersection
        intersectionsNumber -= 1
    for x in [minX..maxX]
      previous = null
      for y in [minY..maxY]
        intersection = map[[x, y]]
        if intersection?
          if random() < 0.9
            @addRoad new Road intersection, previous, laneNum, sensorDist if previous?
            @addRoad new Road previous, intersection, laneNum, sensorDist if previous?
          previous = intersection
    for y in [minY..maxY]
      previous = null
      for x in [minX..maxX]
        intersection = map[[x, y]]
        if intersection?
          if random() < 0.9
            @addRoad new Road intersection, previous, laneNum, sensorDist if previous?
            @addRoad new Road previous, intersection, laneNum, sensorDist if previous?
          previous = intersection

    @shortestPaths = @_calcShortestPaths()

    null

  _calcShortestPaths: ->
    dists = {}
    nexts = {}
    conns = {}
    for roadid, road of @roads.all()
      sid = road.source.id
      tid = road.target.id
      conns[[sid, tid]] = road.length
      dists[[sid, tid]] = road.length
      nexts[[sid, tid]] = [tid, ]
    for id, intersection of @intersections.all()
      conns[[id, id]] = 0
      dists[[id, id]] = 0
      nexts[[id, id]] = []
    for iiid, ii of @intersections.all()
      for ijid, ij of @intersections.all()
        conn = conns[[iiid, ijid]]
        if not conn?
          dists[[iiid, ijid]] = Infinity
          nexts[[iiid, ijid]] = []

    for kid, k of @intersections.all()
      for iid, i of @intersections.all()
        for jid, j of @intersections.all()
          newdist = dists[[iid, kid]] + dists[[kid, jid]]
          if (newdist < dists[[iid, jid]])
            dists[[iid, jid]] = newdist
            nexts[[iid, jid]] = nexts[[iid, kid]]
          else if (newdist == dists[[iid, jid]])
            nexts[[iid, jid]] = _.union(nexts[[iid, jid]], nexts[[iid, kid]])
    nexts

  clear: ->
    @set {}

  onTick: (delta) =>
    throw Error 'delta > 1' if delta > 1
    @time += delta
    @refreshCars()
    for id, intersection of @intersections.all()
      intersection.controlSignals.onTick delta
    for id, car of @cars.all()
      car.move delta
      @removeCar car unless car.alive
    @updateSensors()

  refreshCars: ->
    @addRandomCar() if @cars.length < @carsNumber
    @removeRandomCar() if @cars.length > @carsNumber

  addRoad: (road) ->
    @roads.put road
    road.source.roads.push road
    road.target.inRoads.push road
    road.update()

  getRoad: (id) ->
    @roads.get id

  addCar: (car) ->
    @cars.put car

  getCar: (id) ->
    @cars.get(id)

  removeCar: (car) ->
    @cars.pop car

  addIntersection: (intersection) ->
    @intersections.put intersection

  getIntersection: (id) ->
    @intersections.get id

  addRandomCar: ->
    target = _.sample @intersections.all()
    road = _.sample @roads.all()
    if road?
      lane = _.sample road.lanes
      @addCar new Car target, @shortestPaths, lane if lane?

  removeRandomCar: ->
    car = _.sample @cars.all()
    if car?
      @removeCar car

  updateSensors: ->
    for id, road of @roads.all()
      road.updateSensors()
    for id, intersection of @intersections.all()
      intersection.updateSensor()

module.exports = World
