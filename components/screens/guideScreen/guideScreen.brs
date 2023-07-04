'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 31/05/2021 by Igor Malasevschi


sub init()

end sub


'========= ON GET FOCUS =========
sub onGetFocus()
  setFocus()
end sub

'=========== SET FOCUS ============'
function setFocus() as boolean
  m.top.setFocus(m.top.focus)
end function

'//////////////////////
'///// EVENTS HANDLER
'/////////////////////'
function onKeyEvent(key as string, press as boolean) as boolean
  'print "onKeyEvent HOME ";key;" "; press

  if press

    if key = "back"

      m.top.getParent().callFunc("showMenu")
      return true

    else if key = "OK"

      m.top.getParent().callFunc("showMenu")
      return true

    else if key = "left"
      m.top.getParent().callFunc("showMenu")

      return true

    else if key = "right"

      return true

    else if key = "down"

      return true

    else if key = "up"
      return true

    end if
  end if 'press'

  return false

end function