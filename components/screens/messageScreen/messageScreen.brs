'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 25/05/2021 by Igor Malasevschi

sub init()
    m.errorLabel = m.top.FindNode("errorLabel")
    m.background = m.top.FindNode("background")
end sub

'========= DISPLAY ERROR MESSAGE  ==================='
sub displayErrorMessage (params as object) as object
    if type(params) = "roAssociativeArray"
        m.errorLabel.text = params.errorMessage
    end if
end sub


'=========== UPDATE LAYOUT ==============='
sub updateLayout()
    if m.top.height > 0 and m.top.width > 0
        m.errorLabel.width = m.top.width - 160
        m.errorLabel.height = m.top.height - 160

        m.background.height = m.top.height
        m.background.width = m.top.width

        posY = (m.top.height / 2) - 30
        m.errorLabel.translation = [80, posY]
    end if
end sub

'=========== SET FOCUS ============'
sub setFocus()
    m.top.setFocus(m.top.focus)
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
    setFocus()
end sub