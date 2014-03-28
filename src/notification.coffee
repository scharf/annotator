$ = jQuery

# Public: A simple notification system that can be used to display information,
# warnings and errors to the user. Display of notifications are controlled
# cmpletely by CSS by adding/removing the @options.classes.show class. This
# allows styling/animation using CSS rather than hardcoding styles.
class Annotator.Notification extends Delegator

  # Sets events to be bound to the @element.
  events:
    "click": "hide"

  # Default options.
  options:
    timeout: 5000
    html: "<div class='annotator-notice'></div>"
    classes:
      show:    "annotator-notice-show"
      info:    "annotator-notice-info"
      success: "annotator-notice-success"
      error:   "annotator-notice-error"

  # Public: Creates an instance of  Notification and appends it to the
  # document body.
  #
  # options - The following options can be provided.
  #           classes - A Object literal of classes used to determine state.
  #           html    - An HTML string used to create the notification.
  #
  # Examples
  #
  #   # Displays a notification with the text "Hello World"
  #   notification = new Annotator.Notification
  #   notification.show("Hello World")
  #
  # Returns
  constructor: (options) ->
    super $(@options.html).appendTo(document.body)[0], options

  destroy: ->
    if @element
      @element.remove()
      delete @element
  # Public: Displays the annotation with message and optional status. The
  # message will hide itself after 5 seconds or if the user clicks on it.
  #
  # message - A message String to display (HTML will be escaped).
  # status  - A status constant. This will apply a class to the element for
  #           styling. (default: Annotator.Notification.INFO)
  #
  # Examples
  #
  #   # Displays a notification with the text "Hello World"
  #   notification.show("Hello World")
  #
  #   # Displays a notification with the text "An error has occurred"
  #   notification.show("An error has occurred", Annotator.Notification.ERROR)
  #
  # Returns itself.
  show: (message, status=Annotator.Notification.INFO, autohide=false) =>
    if not @element
      @element = $(@options.html).appendTo(document.body)[0]
      Annotator.destroyables.push this
    $(@element)
      .addClass(@options.classes.show)
      .addClass(@options.classes[status])
      .html(message || "")
    if autohide
      setTimeout this.hide, @options.timeout
#    setTimeout this.hide, @options.timeout
    this

  # Public: Hides the notification.
  #
  # Examples
  #
  #   # Hides the notification.
  #   notification.hide()
  #
  # Returns itself.
  hide: =>
    if not @element
      return this
    $(@element).removeClass(@options.classes.show)
    this

# Constants for controlling the display of the notification. Each constant
# adds a different class to the Notification#element.
Annotator.Notification.INFO    = 'show'
Annotator.Notification.SUCCESS = 'success'
Annotator.Notification.ERROR   = 'error'

# Attach notification methods to the Annotation object on document ready.

notification = new Annotator.Notification
Annotator.destroyables.push notification
Annotator.showNotification = notification.show
Annotator.hideNotification = notification.hide

