'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 27/05/2021 by Igor Malasevschi

sub init()
  m.top.functionName = "getConfigFile"
end sub

'========== GET CONFIG FILE  ==========='
function getConfigFile() as object
  path = "pkg:/config/config.txt"
  data = invalid

  queryFile = ReadAsciiFile(path)

  if len(queryFile) > 0
    data = queryFile
  end if

  pData = {
    data: data
  }

  m.top.response = pData
end function