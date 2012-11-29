---
language: en
layout: page
title: "Node EACH"
date: 2012-11-14T21:33:20.540Z
comments: false
sharing: false
footer: false
github: https://github.com/wdavidw/node-each
---

<pre style="font-family:courier">
 _   _           _        ______           _     
| \ | |         | |      |  ____|         | |    
|  \| | ___   __| | ___  | |__   __ _  ___| |__  
| . ` |/ _ \ / _` |/ _ \ |  __| / _` |/ __| '_ \ 
| |\  | (_) | (_| |  __/ | |___| (_| | (__| | | |
|_| \_|\___/ \__,_|\___| |______\__,_|\___|_| |_| New BSD License
</pre>

Node Each is a single elegant function to iterate asynchronously over elements 
both in `sequential`, `parallel` and `concurrent` mode.

[Documentation for the Node Each is available here](http://www.adaltas.com/projects/node-each/).

Quick example
-------------

The following code traverse an array in `sequential` mode.

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.on('item', function(next, element, index) {
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.on('error', function(err) {
  console.log(err.message);
})
.on('end', function() {
  console.log('Done');
});
```

Or alternatively using the `both` event which combine the `error` and `end` events:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.on('item', function(next, element, index) {
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.on('both', function(err) {
  if(err){
    console.log(err.message);
  }else{
    console.log('Done');
  }
});
```

Installing
----------

Via git (or downloaded tarball):

```bash
git clone http://github.com/wdavidw/node-each.git
```

Then, simply copy or link the project inside a discoverable Node directory 
(eg './node_modules').

Via [npm](http://github.com/isaacs/npm):

```bash
npm install each
```

API
---

The `each` function signature is: `each(subject)`. 

-   `subject`   
    The subject to iterate. It can be an array, an object or 
    any other types in which case the behavior is similar to the one of an array.

The return object is an instance of `EventEmitter`.

The following properties and functions are available:

-   `parallel`   
    The second argument is optional and indicate wether or not you want the 
    iteration to run in `sequential`, `parallel` or `concurrent` mode. See below
    for more details about the different modes.
-   `paused`
    Indicate the state of the current event emitter
-   `readable`
    Indicate if the stream will emit more event

The following events are send:

-   `item`   
    Called for each iterated element. The arguments depends on the 
    subject type.
    The first argument, `next`, is a function to call at the end of your 
    callback. It may be called with an error instance to trigger the `error` event.
    For objects, the second and third arguments are the key and value 
    of each elements. For anything else, the second and third arguments are the 
    value and the index (starting at 0) of each elements.
-   `error`   
    Called only if an error occured. The iteration will be stoped on error meaning
    no `item` event will be called other than the ones already provisionned. Recieves
    an error object as its first argument and eventually a second argument. See 
    the `dealing with errors` section for more information.
-   `end`   
    Called only if all the callback have been handled successfully. No argument is 
    provided in the callback.
-   `both`   
    Called only once all the items have been handled. It is a conveniency event
    combining the `error` and `end` event in one call. Return the same arguments 
    than the `error` or `end` events depending on the operation outturn.

Parallelization modes
---------------------

-   `sequential`   
    Parallel is `false` or set to `1`, default if no parallel mode is defined.
    Callbacks are chained meaning each callback is called once the previous 
    callback is completed (after calling the `next` function argument).
-   `parallel`
    Parallel is `true`.
    All the callbacks are called at the same time and run in parallel.
-   `concurrent`
    Parallel is an integer.
    Only the defined number of callbacks is run in parallel.

Dealing with errors
-------------------

Error are declared by calling `next` argument in the `item` event with an error 
object as its first argument. An event `error` will be triggered and the 
iteration will be stoped. Note that in case of parallel and concurrent mode, 
the current callbacks are not canceled but no new element will be send to the 
`item` event.

The first element send to the `error` event is an error instance. In 
`sequential` mode, it is the event sent in the previous item `callback`. In 
`parallel` and `concurrent` modes, the second argument is an array will all 
the error sent since multiple errors may be thrown at the same time.

Traversing an array
-------------------

In `sequential` mode:

See the "Quick example" section.

In `parallel` mode:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.parallel( true )
.on('item', function(next, element, index) {
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.on('error', function(err, errors){
  console.log(err.message);
  errors.forEach(function(error){
    console.log('  '+error.message);
  });
})
.on('end', function(){
    console.log('Done');
});
```

In `concurrent` mode with 4 parallel executions:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.parallel( 4 )
.on('item', function(next, element, index) {
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.on('error', function(err, errors){
  console.log(err.message);
  errors.forEach(function(error){
    console.log('  '+error.message);
  });
})
.on('end', function(){
  console.log('Done');
});
```

Traversing an object
--------------------

In `sequential` mode:

```javascript
var each = require('each');
each( {id_1: 1, id_2: 2, id_3: 3} )
.on('item', function(next, key, value) {
  console.log('key: ', key);
  console.log('value: ', value);
  setTimeout(next, 500);
})
.on('error', function(err) {
  console.log(err.message);
})
.on('end', function() {
  console.log('Done');
});
```

In `concurrent` mode with 2 parallels executions

```javascript
var each = require('each');
each( {id_1: 1, id_2: 2, id_3: 3} )
.parallel( 2 )
.on('item', function(next, key, value) {
  console.log('key: ', key);
  console.log('value: ', value);
  setTimeout(next, 500);
})
.on('error', function(err, errors){
  console.log(err.message);
  errors.forEach(function(error){
    console.log('  '+error.message);
  });
})
.on('end', function(){
  console.log('Done');
});
```

Readable Stream
---------------

The deferred object return by each partially implement the Node Readable Stream 
API. It can be used to throttle the iteration with the `pause` and `resume` 
functions or to pipe the result to a writeable stream in which case it is your
responsibility to emit the `data` event.

```javascript
var fs = require('fs');
var each = require('each');

var eacher = each( {id_1: 1, id_2: 2, id_3: 3} )
.parallel(2)
.on('item', function(next, key, value) {
  setTimeout(function(){
    eacher.emit('data', key + ',' + value + '\n');
    next();
  }, 100);
})
.on('end', function(){
  console.log('Done');
});

eacher.pipe(
  fs.createWriteStream(__dirname + '/out.csv', { flags: 'w' })
);
```

Repetition with `times`
-----------------------

With the addition of the `times` function, you may now traverse an array 
or call a function multiple times.

We first implemented this functionality while doing performance 
assessment and needing to repeat a same set of metrics multiple times. The 
following sample will call 3 times the function `doSomeMetrics` with the same 
arguments.

```javascript
each([64, 128, 256, 512])
.times(3)
.on('item', function(next, testsize){
  doSomeMetrics(testsize, next);
}).on('end', function(){
  console.log 'done'
});
```

It is also possible to use `times` without providing any data. Here's how:

```javascript
count = 0
each()
.times(3)
.on('item', function(next){
  console.log count++
}).on('end', function(){
  console.log 'done'
});
```

Development
-----------

Node Each comes with a few example, all present in the "samples" folder. Here's how you may run each of them :

```bash
node samples/array_concurrent.js
node samples/array_parallel.js
node samples/array_sequential.js
node samples/object_concurrent.js
node samples/object_sequential.js
node samples/readable_stream.js
```

Tests are executed with mocha. To install it, simple run `npm install`, it will install
mocha and its dependencies in your project "node_modules" directory.

```bash
make test
```

    