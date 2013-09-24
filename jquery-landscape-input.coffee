###
# this plugin is a solution for fixing landscape mode input style
# author: blackbing at gmail dot com
###
$.fn.landscapeInput = ()->
  $this = $(@)

  $this.each( (el)->
    $el = $(@)
    tagName = $el.prop('tagName')
    placeholder = $el.prop('placeholder')
    $readyElement = $("<#{tagName} placeholder='#{placeholder}' style='position:absolute;left:0;top:0;z-index:999999999999;width:100%;height:100%;font-size:18px;display:none;'>")

    $el.data('$readyElement', $readyElement)

    handover = (orientation='landscape')->
      $focusElement = $el
      $readyElement = $focusElement.data('$readyElement')
      if orientation is 'landscape'
        value = $focusElement.val()
        $focusElement.blur()
        $readyElement.val(value)
        .prop('selectionStart', value.length)
        .show().focus()

      else if orientation is 'portrait'
        value = $readyElement.val()
        $readyElement.hide().remove()
        $focusElement.val(value)
        .prop('selectionStart', value.length)
        .focus()

    orientationchanged = ($focusElement)->
      orientation = Math.abs window.orientation
      $readyElement = $focusElement.data('$readyElement')
      $readyElement.appendTo('body')
      if orientation is 90
        handover('landscape')
      else
        handover('portrait')

    $el.on('focusin', ($event)->
      $el = $(@)
      orientation = Math.abs window.orientation
      #check if landscape in originally
      if orientation is 90
        orientationchanged($el)
      if not $el.data('bind-orientation')
        $(window).on('orientationchange.focusin', _.debounce( (->orientationchanged($el)), 300))
        $el.data('bind-orientation', true)

      $event.preventDefault()
    )



  )

