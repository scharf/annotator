#
# 
class Annotator.Plugin.Categories extends Annotator.Plugin
  
  events:
    "annotationCreated": "updateAnnotation"
    "annotationUpdated": "updateAnnotation"
    "annotationsLoaded": "updateLoadedAnnotations"


#
#  Usage in the HTML file:
#          options.categories = {
#                    'errata':'annotator-hl-errata', 
#                    'comment':'annotator-hl-comment', 
#                    'suggestion':'annotator-hl-suggestion' };
#
#  annotator.addPlugin('Categories', options.categories);
#  
#  In .css add entries like these for each category
#
# .annotator-hl.annotator-hl-errata {
#    background: rgba(169, 37, 0, 0.5);
#    color: black;
#}
#


    
    
  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  # field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  # input: null
  
  fields: []
  
  
  options:
    categories: {}
  


  constructor: (element, categories) -> 
    super
    @options.categories = categories


  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    $(document).bind({
      "keypress":   this.processKeypress
    })

    @annotator.adder.remove()
    
    i = 0
    
    for cat,color of @options.categories
      if i == 0
        isChecked = true
      else
        isChecked = false
      i = i + 1
      field = @annotator.editor.addField({
        type: 'checkbox'
        label:  cat
        value: cat
        hl: color
        checked: isChecked
        load:   this.updateField
        submit: this.setAnnotationCat
      })
    
      # replace default input created by editor with a select field
      id = Annotator.$(field).find(':input').attr('id')
      select = '<li class="annotator-item annotator-checkbox"><input type="radio" name="category" id="' + id + '" placeholder="' + cat + '" />'
      select += '<label for="' + id + '">' + cat + '</label>';
      select += '</li>'
      newfield = Annotator.$(select)
      Annotator.$(field).replaceWith(newfield)
            
      @fields[i - 1] = newfield[0] # field

    @viewer = @annotator.viewer.addField({
      load: this.updateViewer
    })

    # Add a filter to the Filter plugin if loaded.
    if @annotator.plugins.Filter
      @annotator.plugins.Filter.addFilter
        label: 'Categories'
        property: 'category'
        isFiltered: Annotator.Plugin.Categories.filterCallback

    # @input = $(@field).find(':input')
  
  
  
   setViewer: (viewer, annotations) ->
     v = viewer
  
  # set the highlights of the annotation here.
   updateAnnotation: (annotation) ->
    annotation.permissions['read'] = [];
    cat = annotation.category
    highlights = annotation.highlights
    
    console.log highlights
    
    if cat    
      for h in highlights
        # h.className = h.className + ' ' + this.options.categories[cat]
        h.className = 'annotator-hl' + ' ' + this.options.categories[cat]
        


  # Annotator.Editor callback function. Updates the radio buttons with the
  # category attached to the provided annotation.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be edited.
  #
  # Examples
  #
  #   field = $('<li><input /></li>')[0]
  #   plugin.updateField(field, {tags: ['apples', 'oranges', 'cake']})
  #   field.value # => Returns 'apples oranges cake'
  #
  # Returns nothing.
  updateField: (field, annotation) =>
    id = '#'+Annotator.$(field).find(':input').attr('id')
    cat = field.childNodes[0].placeholder 
    cat2 = annotation.category
    val = false
    val = true if cat == cat2
    $(id).prop('checked', val)
    # $(field).find(':input').prop('checked', val);
    # $(field).find(':input').val(category)

  # Annotator.Editor callback function. Updates the annotation field with the
  # data retrieved from the @input property.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be updated.
  #
  # Examples
  #
  #   annotation = {}
  #   field = $('<li><input value="cake chocolate cabbage" /></li>')[0]
  #
  #   plugin.setAnnotationTags(field, annotation)
  #   annotation.tags # => Returns ['cake', 'chocolate', 'cabbage']
  #
  # Returns nothing.
  setAnnotationCat: (field, annotation) =>
    # check if the radio button is checked
   	# console.log field
   	id = '#'+Annotator.$(field).find(':input').attr('id')
   	radio = Annotator.$(id)[0]
    if radio.checked
      annotation.category = radio.placeholder


 #
 # Displays the category of the annotation when on the viewer
 #
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.category?
      arr = $.makeArray( annotation.category )
      field.addClass('annotator-category').html(->
        string = $.map(arr,(cat) ->
            '<span class="annotator-hl annotator-hl-' + annotation.category + '">' + Annotator.$.escape(cat) + '</span>'
        ).join('')
      )
    else
      field.remove()

  #
  # keyboard shortcuts
  #
  processKeypress: (event) =>
    switch event.keyCode 
      when 104 then @onAdd(event, 'highlight')
      when 117 then @onAdd(event, 'underline')
      when 114 then @onAdd(event, 'rect')
      when 98  then @onAdd(event, 'bold')
      else console.log event


  onAdd: (event, category) ->
    ranges = @annotator.getSelectedRanges()
    if ranges.length == 0
      console.log 'empty sel'
      return
    
    event.preventDefault()
    annotation = @annotator.setupAnnotation(@annotator.createAnnotation())
    annotation.category = category
    @annotator.publish('annotationCreated', [annotation])

    annotation

  #
  # update the previous saved annotations
  #
  updateLoadedAnnotations: -> 
    annotations = @annotator.element.find('.annotator-hl:visible')
    for ann in annotations
      annotation = $(ann).data("annotation")
      cat = annotation.category
      highlights = annotation.highlights
        
      if cat    
        for h in highlights
          h.className = 'annotator-hl' + ' ' + this.options.categories[cat]
      
