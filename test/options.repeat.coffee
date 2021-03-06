
each = require '../src'

describe 'repeat', ->
  
  describe 'sequential', ->
    
    it 'should run nothing 10 times', (next) ->
      
      started = ended = 0
      each()
      .parallel(null)
      .repeat(10)
      .call (element, index, callback) ->
        # Check provided values
        started.should.eql ended
        should.not.exist element
        index.should.eql 0
        started++
        setTimeout ->
          ended++
          started.should.eql ended
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      data = ['a', 'b', 'c']
      each(data)
      .parallel(null)
      .repeat(10)
      .call (element, index, callback) ->
        # Check provided values
        started.should.eql ended
        element.should.eql data[started % data.length]
        index.should.eql started % data.length
        started++
        setTimeout ->
          ended++
          started.should.eql ended
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 30
        next()

  describe 'parallel', ->
    
    it 'should run nothing 10 times', (next) ->
      started = ended = 0
      each()
      .parallel(true)
      .repeat(10)
      .call (element, index, callback) ->
        started.should.eql 0
        ended.should.eql 0
        process.nextTick -> started++
        setTimeout ->
          ended++
          started.should.eql 10
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 10
        ended.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      each(['a', 'b', 'c'])
      .parallel(true)
      .repeat(10)
      .call (element, index, callback) ->
        started.should.eql 0
        ended.should.eql 0
        process.nextTick -> started++
        setTimeout ->
          ended++
          started.should.eql 30
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 30
        next()

  describe 'concurrent', ->
    
    it 'should run nothing 10 times', (next) ->
      started = ended = 0
      each()
      .parallel(3)
      .repeat(10)
      .call (element, index, callback) ->
        started++
        setTimeout ->
          ended++
          (started - ended).should.be.below 3
          callback()
        , 100
      .error next
      .next ->
        started.should.eql 10
        ended.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      each(['a', 'b', 'c'])
      .parallel(3)
      .repeat(10)
      .call (element, index, callback) ->
        started++
        setTimeout ->
          running = started - ended
          total = 10 * 3
          if started is 30
          then running.should.eql started - ended
          else running.should.eql 3
          ended++
          callback()
        , 100
      .error next
      .next ->
        ended.should.eql 30
        next()
