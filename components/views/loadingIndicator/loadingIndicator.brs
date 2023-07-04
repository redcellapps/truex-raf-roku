'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 28/06/2021 by Igor Malasevschi

'========== INIT  ==========='
sub init()
   m.bulletsGroup = m.top.findNode("bulletsGroup")
   m.bulletsFocusedGroup = m.top.findNode("bulletsFocusedGroup")
   m.loadingTimer = m.top.findNode("loadingTimer")
   m.loadingTimer.observeField("fire", "onLoadingTimer")
   initIndicatorView()
end sub



'=========== ON CONTROL CHANGE ==============='
sub onControlChange()
   if m.top.control = "start"
      startIndicator()
   else
      stopIndicator()
   end if 
end sub

'=========== ON CONTROL CHANGE ==============='
sub startIndicator()
  m.loadingTimer.control = "start"

end sub

'========== RESET INDICATOR VIEW ========'
sub stopIndicator()
   m.loadingTimer.control = "stop"
   m.nodeIndex = 0  

   for index = 0 to m.bulletsFocusedGroup.getChildCount() - 1
        child = m.bulletsFocusedGroup.getChild(index)
        child.visible = false

        if index = 0
          child.visible = true
        end if 
    end for 
end sub
'=========== INIT LOADING SCREEN =========='
sub initIndicatorView()
  m.nodeIndex = 0  
  totalCount = 3
  
  bulletPosX = (1920 - (totalCount * 34) - (totalCount - 1) * 10) / 2
  offsetX = bulletPosX

  for index = 0 to totalCount - 1 step 1
      bullet = createObject("roSGNode", "Poster")
      bullet.translation = [offsetX, 700]
      bullet.width = 34
      bullet.height = 34
      bullet.uri = "pkg:/images/loadingIndicator/bullet.png"
      m.bulletsGroup.appendChild(bullet)

      bulletFocused = createObject("roSGNode", "Poster")
      bulletFocused.translation = [offsetX, 700]
      bulletFocused.uri = "pkg:/images/loadingIndicator/bullet_focused.png"
      bulletFocused.width = 34
      bulletFocused.height = 34
      bulletFocused.visible = false

      if index = 0
          bulletFocused.visible = true
      end if 
           
      m.bulletsFocusedGroup.appendChild(bulletFocused)
      offsetX = offsetX + 50
   end for
end sub


'============ ON LOADING TIMER =========='
sub onLoadingTimer()
   
   child = m.bulletsFocusedGroup.getChild(m.nodeIndex)
   if child <> invalid
        child.visible = false
   end if 

   if m.nodeIndex < m.bulletsFocusedGroup.getChildCount() - 1 
      m.nodeIndex = m.nodeIndex + 1
   else
     m.nodeIndex = 0
   end if 

  child = m.bulletsFocusedGroup.getChild(m.nodeIndex)
  if child <> invalid
      child.visible = true
  end if 
end sub



'=========== UPDATE LAYOUT ==============='
sub updateLayout()
   m.bulletsGroup.translation = [0, m.top.posY]
   m.bulletsFocusedGroup.translation = [0, m.top.posY]
end sub




