###
# this plugin is a solution for fixing landscape mode input style
# author: blackbing at gmail dot com
# https://github.com/blackbing/jquery-landscape-input
###
debounce = (func, wait, immediate) ->
  timeout = undefined
  args = undefined
  context = undefined
  timestamp = undefined
  result = undefined
  ->
    context = this
    args = arguments
    timestamp = new Date()
    later = ->
      last = (new Date()) - timestamp
      if last < wait
        timeout = setTimeout(later, wait - last)
      else
        timeout = null
        result = func.apply(context, args)  unless immediate

    callNow = immediate and not timeout
    timeout = setTimeout(later, wait)  unless timeout
    result = func.apply(context, args)  if callNow
    result

$currentFocusIn = null
#check the screen width and width
#note: window.screen is untrusted, you will get screen width with pixel resolution in some browser
getScreen = do ->
  w = $(window).width()
  h = $(window).height()
  if w>h
    tmp = w
    w = h
    h = tmp
  ->
    orientation = Math.abs window.orientation
    if orientation is 90
      screen =
        width: h
        height: w
    else
      screen =
        width: w
        height: h
    screen

$.fn.landscapeInput = ()->
  $this = $(@)
  orientationchanged = ()->
    if not $currentFocusIn
      return
    $focusElement = $currentFocusIn
    $(window).off('resize.landscape')
    orientation = Math.abs window.orientation
    $readyElement = $focusElement.data('$readyElement')
    $readyElement.appendTo('body')
    if orientation is 90
      handover($focusElement, 'landscape')
      #if landscape, it need to considerate user hide keyboard
      $(window).on('resize.landscape', _.debounce( (->checkKeyboard($readyElement)), 200))
    else
      handover($focusElement, 'portrait')

  handover = ($focusElement, orientation='landscape', focus='focus')->
    $readyElement = $focusElement.data('$readyElement')
    if orientation is 'landscape'
      value = $focusElement.val()
      $focusElement.blur()
      $readyElement.val(value)
      .show()
      .prop('selectionStart', value.length)
      .focus()

    else if orientation is 'portrait'
      value = $readyElement.val()
      $readyElement.hide().remove()
      $focusElement.val(value)

      if focus is 'focus'
        $focusElement
        .focus()
        .prop('selectionStart', value.length)
      else
        $focusElement.blur()

  checkKeyboard = ( $readyElement )->
    orientation = Math.abs window.orientation
    if orientation is 90
      screen = getScreen()
      screenHeight = screen.height
      screenWidth = screen.width
      #it means keyboard is hided
      if $readyElement.height() > screenHeight/2
        handover($currentFocusIn, 'portrait', 'dontfocus')

  $(window).on('orientationchange.focusin', _.debounce(orientationchanged, 100))

  $this.each( (el)->
    $el = $(@)
    tagName = $el.prop('tagName')
    placeholder = $el.prop('placeholder')
    $readyElement = $("<#{tagName} placeholder='#{placeholder}' style='position:fixed;left:0;top:0;z-index:999999999999;width:100%;height:100%;font-size:18px;display:none;'>")

    $el.data('$readyElement', $readyElement)

    $el.on('focusin', ($event)->
      #make sure only one event will be triggered
      #$(window).off('orientationchange.focusin')
      $el = $(@)
      orientation = Math.abs window.orientation
      $currentFocusIn = $el
      o_changed = _.debounce(orientationchanged, 100)
      #check if landscape in originally
      if orientation is 90
        o_changed()

      $event.preventDefault()
    )
  )
