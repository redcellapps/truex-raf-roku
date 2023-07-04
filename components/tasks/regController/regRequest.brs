'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi


'========== INIT  ==========='
sub init()

end sub

function regRead()
  section = getAppTitle()
  request = m.top.request
  key = request.key
  registrySection = CreateObject("roRegistrySection", section)
  if registrySection.Exists(key)
    data = registrySection.Read(key)
  else
    data = invalid
  end if

  m.top.response = {
    data: data,
    key: key
  }
end function

'========== REG WRITE  ==========='
function regWrite()
  section = getAppTitle()
  request = m.top.request
  key = request.key
  value = request.value
  registrySection = CreateObject("roRegistrySection", section)
  registrySection.Write(key, value)
  data = registrySection.Flush()

  m.top.response = {
    data: data,
    key: key
  }
end function

'========== REG WRITE  ==========='
function regDelete()
  section = getAppTitle()
  request = m.top.request
  key = request.key
  registrySection = CreateObject("roRegistrySection", section)
  registrySection.Delete(key)
  data = registrySection.Flush()

  m.top.response = {
    data: data,
    key: key
  }

end function

