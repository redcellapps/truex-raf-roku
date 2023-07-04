'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi

sub init()
   m.itemSelected = m.top.findNode("itemSelected")
   m.top.observeField("focusedChild", "focusChanged")
   m.itemLabel = m.top.findNode("itemLabel")
   m.background = m.top.findNode("background")
end sub

'=========== ROW HAS FOCUS ================='
sub rowHasFocus()
   m.itemSelected.visible = m.top.rowHasFocus and (m.top.focusPercent = 1)
end sub

'======== ITEM CONTENT CHANGED =============='
sub itemContentChanged()
   itemcontent = m.top.itemContent
   m.itemLabel.text = itemcontent.name
end sub

'======== ITEM CONTENT CHANGED =============='
sub rowFocusPercentChanged()
   scale = 0

   if m.top.rowHasFocus
      scale = (m.top.rowFocusPercent * 0.4)
   end if

   if scale <= 0.3
      m.itemSelected.visible = false
   else if scale > 0.3
      m.itemSelected.visible = true
   end if
end sub







