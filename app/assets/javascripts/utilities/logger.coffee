class App.Logger
  @add_error: (error_object) ->
    @errors ||= []
    @errors.push(error_object)

jQueryInit = $.fn.init
$.fn.init = (selector, context) ->
  element = new jQueryInit(selector, context)
  if selector and element.length is 0
    App.Logger.add_error({selector_not_found: selector, stack_trace: printStackTrace()})

  element
