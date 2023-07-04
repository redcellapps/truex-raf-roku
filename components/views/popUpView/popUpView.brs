'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 14/07/2021 by Igor Malasevschi

sub init()
   m.noBtn = m.top.findNode("noBtn")
   m.noBtn.observeField("buttonSelected", "onNoBtnPress")
   m.yesBtn = m.top.findNode("yesBtn")
   m.yesBtn.observeField("buttonSelected", "onYesBtnPress")
   m.unpairDevice = false
   m.titleLbl = m.top.findNode("titleLbl")
   m.nodeIndex = 1
end sub

'========== ON CLOSE BTN PRESS ======='
sub onNoBtnPress()
   params = {
      close: false,
      unpairDevice: m.unpairDevice
   }
   m.top.getParent().callFunc("closePopupScreen", params)
end sub

'========= ON CANCEL BTN PRESS ======='
sub onYesBtnPress()

   params = {
      close: true,
      unpairDevice: m.unpairDevice
   }
   m.top.getParent().callFunc("closePopupScreen", params)
end sub

'======== SET FOCUS =============='
sub setFocus()
   m.top.setFocus(m.top.focus)
   m.noBtn.setFocus(false)
   m.yesBtn.setFocus(false)

   if m.nodeIndex = 0
      m.yesBtn.setFocus(m.top.focus)
   else
      m.noBtn.setFocus(m.top.focus)
   end if
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
   setFocus()
end sub

function displayPopup(params as object) as object
   m.titleLbl.text = params.title
   if params.unpairDevice <> invalid
      m.unpairDevice = params.unpairDevice
   end if
end function

'//////////////////////
'///// EVENT HANDLERS
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
   'print "[onKeyEvent popupScreen ";key;" "; press; "]"

   handled = false

   if press
      if key = "back"
         onNoBtnPress()
         handled = true

      else if key = "OK"

         handled = true

      else if key = "left"

         if m.nodeIndex > 0
            m.nodeIndex = m.nodeIndex - 1
         end if

         setFocus()
         handled = true

      else if key = "right"

         if m.nodeIndex < 1
            m.nodeIndex = m.nodeIndex + 1
         end if
         setFocus()
         handled = true

      else if key = "down"
         handled = true

      else if key = "up"
         handled = true

      else if key = "options"
         handled = true
      end if
   end if 'press'

   return handled
end function