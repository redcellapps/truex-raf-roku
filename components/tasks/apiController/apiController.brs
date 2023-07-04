'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 27/05/2021 by Igor Malasevschi

function apiController(apiUrl as string, country as string) as object
     instance = {
          apiUrl: apiUrl,
          country: country,
          getCategories: sub(platform as string, onCompleteFuncName = "" as string)
               url = m.apiUrl + "/categories?platform=" + platform  + "&type=movies&country=" + m.country 
               taskNode = CreateObject("roSGNode", "httpRequest")
               taskNode.url = url
               taskNode.functionName = "get"
               taskNode.observeField("response", onCompleteFuncName)
               taskNode.control = "RUN"
          end sub,

          getLiveTV: sub(platform as string, onCompleteFuncName = "" as string)
               url = m.apiUrl + "/categories?platform=" + platform + "&type=live&country=" + m.country 
               taskNode = CreateObject("roSGNode", "httpRequest")
               taskNode.url = url
               taskNode.functionName = "get"
               taskNode.observeField("response", onCompleteFuncName)
               taskNode.control = "RUN"
          end sub

          getRadios: sub(platform as string, onCompleteFuncName = "" as string)
               url = m.apiUrl + "/categories?platform=" + platform + "&type=radio&country=" + m.country 
               taskNode = CreateObject("roSGNode", "httpRequest")
               taskNode.url = url
               taskNode.functionName = "get"
               taskNode.observeField("response", onCompleteFuncName)
               taskNode.control = "RUN"
          end sub,

          getMediaItem: sub(id as object, onCompleteFuncName = "" as string)
               url = m.apiUrl + "/media_item?id=" + id.ToStr()
               taskNode = CreateObject("roSGNode", "httpRequest")
               taskNode.url = url
               taskNode.functionName = "get"
               taskNode.observeField("response", onCompleteFuncName)
               taskNode.control = "RUN"
          end sub,

          getCategory: sub(id as integer, onCompleteFuncName = "" as string)
               url = m.apiUrl + "/category?id=" + id.ToStr()
               taskNode = CreateObject("roSGNode", "httpRequest")
               taskNode.url = url
               taskNode.functionName = "get"
               taskNode.observeField("response", onCompleteFuncName)
               taskNode.control = "RUN"
          end sub
     }

     return instance
end function


