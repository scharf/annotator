
class Task
  constructor: (name, todo, data) ->
    @_name = name
    @_todo = todo
    @_data = data
    @started = false
    @dfd = new jQuery.Deferred()
    @dfd.ready = (data) =>
      endTime = new Date().getTime()
      elapsedTime = endTime - @dfd.startTime
      console.log "Finished task '" + @_name + "' in " + elapsedTime + "ms."
      @dfd.resolve data
    @dfd.promise this

  start: => setTimeout =>
    if @started
      console.log "This task ('" + @_name + "') has already been started!"
      return
    console.log "Starting task '" + @_name + "'..."
    @dfd.startTime = new Date().getTime()
    @_todo @dfd, @_data

class DummyTask extends Task
  constructor: (name) ->
    super "Dummy: " + name, (task) => task.ready()

class TaskGen
  constructor: (name, todo) ->
    @name = name
    @todo = todo
    @count = 0

  create: (name, data) ->
    @count += 1
    name = @name + " #" + @count + ": " + name
    new Task name, @todo, data
