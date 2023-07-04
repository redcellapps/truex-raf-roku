'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi

sub init()
  m.top.functionName = "listenInput"
end sub

function listenInput()
  port = createobject("romessageport")
  inputObject = createobject("roInput")
  inputObject.setmessageport(port)

  while true
    msg = port.waitmessage(500)
    if type(msg) = "roInputEvent" then
      if msg.isInput()
        deeplinkData = msg.getInfo()


        ' pass the deeplink to UI
        if deeplinkData.DoesExist("mediaType") and deeplinkData.DoesExist("contentID")
          deeplink = {
            deepContentId: deeplinkData.contentID,
            deepMediaType: deeplinkData.mediaType
          }

          m.top.deeplinkData = deeplink
        end if
      end if
    end if
  end while
end function
