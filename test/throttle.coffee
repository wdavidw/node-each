
each = require '../src'

describe 'throttle', ->
  
  it 'next before resume', (next) ->
    eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
    .parallel( 4 )
    .call (element, index, callback) ->
      if element.id is 2
        eacher.pause()
        setTimeout ->
          eacher.resume()
        , 100
      callback()
    .next (err, errors) ->
      should.not.exist err
      next()
      
  it 'next after resume', (next) ->
    eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
    .parallel( 4 )
    .call (element, index, callback) ->
      if element.id is 2
        eacher.pause()
        setTimeout ->
          eacher.resume()
          callback()
        , 100
      else
        callback()
    .next (err, errors) ->
      should.not.exist err
      next()
      
  it 'multiple pause # next before resume', (next) ->
    eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
    .parallel( 4 )
    .call (element, index, callback) ->
      if element.id % 2 is 0
        eacher.pause()
        setTimeout ->
          eacher.resume()
          callback()
        , 10 * element.id
      else
        callback()
    .next (err, errors) ->
      should.not.exist err
      next()
      
  it 'multiple pause # next after resume', (next) ->
    eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
    .parallel( 4 )
    .call (element, index, callback) ->
      if element.id % 2 is 0
        eacher.pause()
        setTimeout ->
          eacher.resume()
        , 10 * element.id
      callback()
    .next (err, errors) ->
      should.not.exist err
      next()
