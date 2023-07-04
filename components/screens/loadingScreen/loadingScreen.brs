'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 28/06/2021 by Igor Malasevschi

'========== INIT  ==========='
sub init()
   m.loadingIndicator = m.top.findNode("loadingIndicator")

end sub

'=========== ON CONTROL CHANGE ==============='
sub onControlChange()
   m.loadingIndicator.control = m.top.control
end sub

