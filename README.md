[![Build Status](https://secure.travis-ci.org/adaltas/node-each.png)](http://travis-ci.org/adaltas/node-each)

Node Each is a single elegant function to iterate asynchronously over elements 
both in `sequential`, `parallel` and `concurrent` mode.

Main functionnalities include:

* Iterate over arrays and objects
* Control the number of executed callbacks in parallel
* asynchronous and synchronous supported callbacks
* Run array elements and object key/pairs multiple times
* Filesystem traversal with globing support
* Multiple call detection in callback
* Full test coverage

## Usage

### Synchronous and sequential Mode

```javascript
each( [{id: 1}, {id: 2}, {id: 3}] )
.call( function(element, index){
  console.log('element: ', element, '@', index);
})
.then( function(err){
  console.log(err ? err.message : 'Done');
});
```

### Asynchronous and concurrent Mode

```javascript
each( [{id: 1}, {id: 2}, {id: 3}] )
.parralel(2)
.call( function(element, index, next){
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.then( function(err){
  console.log(err ? err.message : 'Done');
});
```

## Installation

Via git (or downloaded tarball): `git clone http://github.com/wdavidw/node-each.git`. Then, simply copy or link the project inside a discoverable Node directory (eg ‘./node_modules’).

Via npm: `npm install each`
API
---

The `each` function signature is: `each(subject)`. 

-   `subject`   
    The subject to iterate. It is usually an array or an object. Inserting a number
    or a string will behave like an array of one element and inserting null or undefined
    wont iterate over any element.

The return object is an instance of `EventEmitter`.

The following properties are available:

-   `paused`   
    Indicate the state of the current event emitter.
-   `readable`   
    Indicate if the stream will emit more event.
-   `started`  
    Number of callbacks which have been called.
-   `done`  
    Number of callbacks which have finished.
-   `total`   
    Total of registered elements.

The following functions are available:

-   `shift(items)`, `write(items)`   
    Add array elements or key/value pairs at the end of iteration.
-   `unshift(items)`   
    Add array elements or key/value pairs at the begining of the iteration, just after the last executed element.
-   `end()`   
    Stop the iteration, garanty that no item will be emitted after it is called.
-   `parallel(mode)`   
    The first argument is optional and indicate wether or not you want the 
    iteration to run in `sequential`, `parallel` or `concurrent` mode. See below
    for more details about the different modes.
-   `times()`   
    Repeat operation multiple times before passing to the next element, see `repeat`
-   `repeat()`   
    Repeat operation multiple times once all elements have been called, see `times`.
-   `sync()`   
    Run callbacks in synchronous mode, no next callback are provided, may throw an error.
-   `files([base], glob)`
    Emit file paths based on a directory or globbing expression.

The following events are emitted:

-   `item`   
    Called for each iterated element. Provided arguments depends on the 
    subject type and the number of arguments defined in the callback. More information
    below.
-   `error`   
    Called only if an error occured. The iteration will be stoped on error meaning
    no `item` event will be called other than the ones already provisionned. Recieves
    an error object as its first argument and eventually a second argument. See 
    the `dealing with errors` section for more information.   
-   `end`   
    Called only if all the callback have been handled successfully. The total number of traversed item is provided in the callback as the first argument.   
-   `both`   
    Called only once all the items have been handled. It is a conveniency event
    combining the `error` and `end` event in one call. Called with the error object or null as a first argument and the number of traversed items as the second argument. In case of an error, this number correspond to the number of item callbacks which called next. 

## Parallelization modes

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

## Callback arguments in "item" events

The last argument, `next`, is a function to call at the end 
of your callback. It may be called with an error instance to 
trigger the `error` event. An example worth a tousand words, 
see the code examples below for usage.

Inside array iteration, callback signature is `function([value], [index], next)`

```javascript
each([])
// 1 argument
.on('item', function(next){})
// 2 arguments
.on('item', function(value, next){})
// 3 arguments
.on('item', function(value, next){})
// 4 arguments
.on('item', function(value, index, next){})
// done
.on('end', function())
```

Inside object iteration, callback signature is `function([key], [value], [counter], next)`

```javascript
each([])
// 1 argument
.on('item', function(next){})
// 2 arguments
.on('item', function(value, next){})
// 3 arguments
.on('item', function(key, value, next){})
// 4 arguments
.on('item', function(key, value, counter, next){})
// done
.on('end', function())
```

## Dealing with errors

Error are declared by calling `next` argument in the `item` event with an error 
object as its first argument. An event `error` will be triggered and the 
iteration will be stoped. Note that in case of parallel and concurrent mode, 
the current callbacks are not canceled but no new element will be send to the 
`item` event.

The first argument passed to the `error` event callback is an error instance. In 
`sequential` mode, it is always the error that was thrown by the failed item callback. In 
`parallel` and `concurrent` modes, there may be more than one event thrown asynchrously. In such case, the error has a generic message such as `Multiple error $count` and the property `.errors` is an array giving access to each individual error.

It is possible to know the number of successful item callbacks in the `both` event by substracting the number of run callbacks provided as the second argument to the number of errors provided as the first argument.

```javascript
each([])
.on('item', function(next){ next() })
.on('both', function(err, count){
  succeed = count - err.errors.lenth
  console.log('Successful callbacks' + succeed);
})
```

## Traversing an array

In `sequential` mode:

See the "Quick example" section.

In `parallel` mode:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.parallel( true )
.on('item', function(element, index, next) {
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
.on('item', function(element, index, next) {
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

## Traversing an object

In `sequential` mode:

```javascript
var each = require('each');
each( {id_1: 1, id_2: 2, id_3: 3} )
.on('item', function(key, value, next) {
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
.on('item', function(key, value, next) {
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

## Traversing files

The "files" function is a globing utility which traverse the file 
system based on pattern matching. Multiple globing patterns may be
provided as an array or the function may be called multiple times.

```javascript
var each = require('each');
each()
.files('./**/*.js')
.files('./**/*.coffee')
.on('item', function(file, next) {
  console.log('Found "' + file + '"');
})
.on('end', function(){
  console.log('Done');
});
```

## Manual Throttle

Use `pause` and `resume` functions to throttle the iteration

## Repetition with `times` and `repeat`

With the addition of the `times` and `repeat` functions, you may now traverse an array 
or call a function multiple times. Note, you can not use those two functions at the same time.

We first implemented this functionality while doing performance 
assessment and needing to repeat a same set of metrics multiple times. The 
following sample will call 3 times the function `doSomeMetrics` with the same 
arguments.

```javascript
each(['a', 'b', 'c', 'd'])
.times(3)
.on('item', function(id, next){
  doSomeMetrics(id, next);
}).on('end', function(){
  console.log 'done'
});
```

The generated sequence is 'aaabbbcccddd'. In the same way, you could replace `times` by 
`repeat` and in such case, the generated sequence would have been `abcdabcdabcd`.

It is also possible to use `times` and `repeat` without providing any data. Here's how:

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

## Multiple call detection in callback

An error will be throw with the message "Multiple call detected" if the `next` argument in the `item` callback is called multiple times. However, if `end` event has already been thrown, the only way to catch the error is by registering to the "uncaughtException" event of `process`.

## Examples

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
