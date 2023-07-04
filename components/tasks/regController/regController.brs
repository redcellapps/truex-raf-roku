'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi

'=============== INIT REGCONTROLLER ====================
function regController() as object

	instance = {
		'========== REG READ ==========
		regRead: function(key as string, onCompleteFuncName = "" as string) as object
			taskNode = CreateObject("roSGNode", "regRequest")

			request = {
				key: key
			}
			taskNode.request = request
			taskNode.functionName = "regRead"
			taskNode.observeField("response", onCompleteFuncName)
			taskNode.control = "RUN"
		end function,

		'========== REG WRITE  ==========='
		regWrite: function(key as string, value as string, onCompleteFuncName = "" as string)
			taskNode = CreateObject("roSGNode", "regRequest")
			request = {
				key: key,
				value: value
			}
			taskNode.request = request
			taskNode.functionName = "regWrite"
			taskNode.observeField("response", onCompleteFuncName)
			taskNode.control = "RUN"
		end function,

		'========== REG DELETE  ==========='
		regDelete: function(key as string, onCompleteFuncName = "" as string)
			taskNode = CreateObject("roSGNode", "regRequest")
			request = {
				key: key
			}
			taskNode.request = request
			taskNode.functionName = "regDelete"
			taskNode.observeField("response", onCompleteFuncName)
			taskNode.control = "RUN"
		end function
	}

	return instance
end function