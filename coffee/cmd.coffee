#!/usr/bin/env node

'use strict'

require './helpers'
program = require 'commander'
_ = require 'underscore'
# Visualizer = require './visualizer/visualizer'
World = require './model/world'
settings = require './settings'

main = () ->
  console.log process.argv
  program
    .version '0.1.0'
    .option '-d, --delta', 'Set time delta between 2 updates'
    .option '-i, --input', 'Path to input json map file'
    .option '-o, --output', 'Path to output stats file'
    .option '--carnum', 'Number of cars', 100
    .option '--lanenum', 'Number of lanes', 2
    .option '--netsize', 'NxN road net', 5
    .option '--sensornum', 'Number of sensors on each lane', 3
    .parse process.argv

  world = new World()
  # world.load()
  if world.intersections.length is 0
    world.laneNum = program.lanenum
    world.netSize = program.netsize
    world.sensorNum = program.sensornum
    world.generateMap()
    world.carsNumber = program.carnum

  for i in [0..10000]
    world.onTick program.delta
    console.log world.instantSpeed


main()

# $ ->
#   canvas = $('<canvas />', {id: 'canvas'})
#   $(document.body).append(canvas)

#   window.world = new World()
#   world.load()
#   if world.intersections.length is 0
#     world.generateMap()
#     world.carsNumber = 100
#   window.visualizer = new Visualizer world
#   visualizer.start()
#   gui = new DAT.GUI()
#   guiWorld = gui.addFolder 'world'
#   guiWorld.open()
#   guiWorld.add world, 'save'
#   guiWorld.add world, 'load'
#   guiWorld.add world, 'clear'
#   guiWorld.add world, 'generateMap'
#   guiVisualizer = gui.addFolder 'visualizer'
#   guiVisualizer.open()
#   guiVisualizer.add(visualizer, 'running').listen()
#   guiVisualizer.add(visualizer, 'debug').listen()
#   guiVisualizer.add(visualizer.zoomer, 'scale', 0.1, 2).listen()
#   guiVisualizer.add(visualizer, 'timeFactor', 0.1, 10).listen()
#   guiWorld.add(world, 'carsNumber').min(0).max(200).step(1).listen()
#   guiWorld.add(world, 'instantSpeed').step(0.00001).listen()
#   guiWorld.add(world, 'laneNum').min(1).max(4).step(1).listen()
#   guiWorld.add(world, 'netSize').min(2).max(15).step(1).listen()
#   guiWorld.add(world, 'sensorNum').min(1).max(10).step(1).listen()
#   gui.add(settings, 'lightsFlipInterval', 0, 400, 0.01).listen()
