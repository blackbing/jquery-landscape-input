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

    handover = (orientation='landscape', focus='focus')->
      $focusElement = $el
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
      screen = window.screen
      #it means keyboard is hided
      if $readyElement.height() > screen.height/2
        handover('portrait', 'dontfocus')

    orientationchanged = ($focusElement)->
      $(window).off('resize.landscape')
      orientation = Math.abs window.orientation
      $readyElement = $focusElement.data('$readyElement')
      $readyElement.appendTo('body')
      if orientation is 90
        handover('landscape')
        #if landscape, it need to considerate user hide keyboard
        $(window).on('resize.landscape', _.debounce( (->checkKeyboard($readyElement)), 200))
      else
        handover('portrait')

    $el.on('focusin', ($event)->
      $el = $(@)
      orientation = Math.abs window.orientation
      o_changed = _.debounce( (->orientationchanged($el)), 100)
      #check if landscape in originally
      if orientation is 90
        o_changed()
      if not $el.data('bind-orientation')
        $(window).on('orientationchange.focusin', o_changed)
        $el.data('bind-orientation', true)

      $event.preventDefault()
    )



  )

