
class Task
  constructor: (name, todo, data) ->
    unless todo?
      throw new Error "Trying to define task with no code!"
    @taskID = name # TODO
    @_name = name
    @_todo = todo
    @_data = data
    @started = false
    @subTasks = {}
    @dfd = new jQuery.Deferred()

    @dfd._notify = @dfd.notify
    @dfd.notify = (data) =>
      @dfd._notify $.extend data, task: this, taskName: @_name

    @dfd.ready = (data) =>
      endTime = new Date().getTime()
      elapsedTime = endTime - @dfd.startTime
      @dfd.notify
        progress: 1
        text: "Finished in " + elapsedTime + "ms."
      @dfd.resolve data
    @dfd.promise this


  start: => setTimeout =>
    if @started
      console.log "This task ('" + @_name + "') has already been started!"
      return
    @dfd.notify
      progress: 0
      text: "Starting"
    @dfd.startTime = new Date().getTime()
    @_todo @dfd, @_data

  addSubTask: (weight, task) =>
    if task.taskID is 1 then throw new Error "WTF"
    @subTasks[task.taskID] =
      weight: weight
      progress: 0
      text: "no info about this subtask"
    task.progress (info) =>
      task = info.task
      delete info.task
      taskInfo = @subTasks[task.taskID]
      $.extend taskInfo, info

      progress = 0
      for countId, countInfo of @subTasks
        progress += countInfo.progress * countInfo.weight
      report =
        progress: progress

      if info.text?
        report.text = task._name + ": " + info.text

      @dfd.notify report

  createSubTask: (weight, name, todo, data) ->
    task = new Task name, todo, data
    this.addSubTask weight, task
    task

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
