'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi


'========== INIT  ==========='
sub init()
end sub


'=========== URL GET REQUEST ================='
sub get()
  url = m.top.url
  port = CreateObject("roMessagePort")
  request = CreateObject("roUrlTransfer")
  request.SetMessagePort(port)
  request.EnableCookies()
  request.SetCertificatesFile("common:/certs/ca-bundle.crt")
  request.AddHeader("Connection", "Keep-Alive")
  request.SetUrl(url)

  if (request.AsyncGetToString())
    msg = wait(0, port)
    if (type(msg) = "roUrlEvent")
      code = msg.GetResponseCode()

      pData = {
        data: ParseJson(msg.GetString()),
        code: code
        'msg: msg.GetString()
      }

    else if (msg = invalid)
      pData = {
        data: invalid
      }
      request.AsyncCancel()
    end if

    m.top.response = pData
  end if
end sub





