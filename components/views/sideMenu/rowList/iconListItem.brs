'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi

sub init()
      m.itemIcon = m.top.findNode("itemIcon")
      m.itemSelected = m.top.findNode("itemSelected")
      m.selected = false
end sub

'======== ITEM CONTENT CHANGED =============='
sub itemContentChanged()
      itemcontent = m.top.itemContent
      m.itemIcon.uri = itemcontent.posterUrl

      m.itemSelected.visible = false

      if itemcontent.selected
            m.itemSelected.visible = true
      end if
end sub



