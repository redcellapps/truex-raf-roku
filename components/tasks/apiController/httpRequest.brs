'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi


'========== INIT  ==========='
sub init()
end sub


'=========== URL GET REQUEST ================='
sub get()
  #if vscode_proxy
    url = urlProxy(m.top.url)
  #else
    url = m.top.url
  #end if

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

function urlProxy(url as string) as string
  if left(url, 4) <> "http" then return url
  ' This address is <HOST_RUNNING_CHARLES>:<CHARLES_PORT>
  proxyAddress = "192.168.0.111:8888"

  ' Make sure we have not already formatted this url
  ' This can lead to a recursive address
  if not url.inStr(proxyAddress) > -1 then
    if url <> invalid and proxyAddress <> invalid
      proxyPrefix = "http://" + proxyAddress + "/;"
      currentUrl = url

      ' Double check again. You really don't want a recursive address
      if currentUrl.inStr(proxyPrefix) = 0 then
        return url
      end if

      ' Combine the addresses together resulting in the following format:
      ' <HOST_RUNNING_CHARLES>:<CHARLES_PORT>;<ORIGINAL_ADDRESS>
      proxyUrl = proxyPrefix + currentUrl
      return proxyUrl
    end if
  end if

  return url
end function
