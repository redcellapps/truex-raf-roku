'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 27/05/2021 by Igor Malasevschi

function configController() as object

    instance = {
        getConfigFile: sub(onCompleteFuncName = "" as string)
            taskNode = CreateObject("roSGNode", "configRequest")
            taskNode.observeField("response", onCompleteFuncName)
            taskNode.control = "RUN"
        end sub
    }

    return instance
end function




