'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 04/06/2021 by Igor Malasevschi

sub init()
    m.itemImage = m.top.findNode("itemImage")
    m.imgFocused = m.top.findNode("imgFocused")
    m.nameLbl = m.top.findNode("nameLbl")
    m.nameLbl.font.size = 24

end sub

'============== ITEM CONTET CHANGED ================='
sub onContentChange()
    itemData = m.top.itemContent
    m.itemImage.uri = itemData.portraitImg

    'if itemData.displayName = true
    'm.nameLbl.text = itemData.name
    'end if
    'm.imgFocused.visible = false

end sub

'=========== ROW HAS FOCUS ================='
sub rowHasFocus()
    if m.top.rowHasFocus and m.top.focusPercent = 1
        m.imgFocused.visible = true
        m.nameLbl.color = "0xffffff"
    else
        m.imgFocused.visible = false
        'm.nameLbl.color = "0xB0B0B0"
        m.nameLbl.color = "0xCCCCCC"
    end if
end sub