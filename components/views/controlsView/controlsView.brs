'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 10/06/2021 by Igor Malasevschi

sub init()
  m.focusedThumb = m.top.findNode("focusedThumb")
  m.nodeIndex = 0
  m.pauseThumb = m.top.findNode("pauseThumb")
  m.playThumb = m.top.findNode("playThumb")

  m.ffThumb = m.top.findNode("ffThumb")
  m.rewThumb = m.top.findNode("rewThumb")

  m.nextThumb = m.top.findNode("nextThumb")
  m.previousThumb = m.top.findNode("previousThumb")

  m.focusedRewThumb = m.top.findNode("focusedRewThumb")
  m.focusedCenterThumb = m.top.findNode("focusedCenterThumb")
  m.focusedFFThumb = m.top.findNode("focusedFFThumb")

  m.unfocusedFFThumb = m.top.findNode("unfocusedFFThumb")
  m.unfocusedRewThumb = m.top.findNode("unfocusedRewThumb")
end sub

'========== SET LIVE BUTTONS ==========='
sub setLiveButtons()
  m.nextThumb.visible = true
  m.previousThumb.visible = true
  m.ffThumb.visible = false
  m.rewThumb.visible = false

  m.unfocusedFFThumb.visible = true
  m.unfocusedRewThumb.visible = true
end sub

'========== SET LIVE BUTTONS ==========='
sub setMovieButtons()
  m.nextThumb.visible = false
  m.previousThumb.visible = false
  m.ffThumb.visible = true
  m.rewThumb.visible = true

  m.unfocusedFFThumb.visible = true
  m.unfocusedRewThumb.visible = true
end sub


'=========== SET FOCUS ============'
sub setFocus()
  'm.focusedThumb.visible = m.top.focus
  m.top.setFocus(m.top.focus)

  m.focusedRewThumb.visible = false
  m.focusedCenterThumb.visible = false
  m.focusedFFThumb.visible = false

  if m.top.focus
    m.top.buttonFocused = true
    if m.nodeIndex = -1
      m.focusedRewThumb.visible = true

    else if m.nodeIndex = 0
      m.focusedCenterThumb.visible = true
    else if m.nodeIndex = 1
      m.focusedFFThumb.visible = true
    end if
  else
    m.nodeIndex = 0
  end if
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
  setFocus()
end sub


'========== HIDE CONTROLS =======
sub disableControls()
  m.nextThumb.visible = false
  m.previousThumb.visible = false
  m.unfocusedFFThumb.visible = false
  m.unfocusedRewThumb.visible = false
end sub

'================== ON PLAYER STATE CHANGE ================'
sub onPlayerStateChange()
  if m.top.state = "error"
    m.pauseThumb.visible = false
    m.playThumb.visible = true

  else if m.top.state = "playing"

    m.playThumb.visible = false
    m.pauseThumb.visible = true

  else if m.top.state = "paused"
    m.pauseThumb.visible = false
    m.playThumb.visible = true

  else if m.top.state = "finished"
    m.pauseThumb.visible = false
    m.playThumb.visible = true

  else if m.top.state = "stopped"
    m.pauseThumb.visible = false
    m.playThumb.visible = true
  end if
end sub

'============= ON CONTROL KEY PRESS  =========='
sub onControlKeyPress()
  m.top.buttonSelected = m.nodeIndex
end sub


'//////////////////////
'///// EVENT HANDLERS
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
  'print "[onKeyEvent controlsView ";key;" "; press; "]"

  if press
    if key = "back"

    else if key = "down"
      return true
    else if key = "up"
      return false
    else if key = "left" and m.top.disabledControls = false
      if m.nodeIndex > -1
        m.nodeIndex = m.nodeIndex - 1
      end if
      setFocus()
      return true
    else if key = "right" and m.top.disabledControls = false
      if m.nodeIndex < 1
        m.nodeIndex = m.nodeIndex + 1
      end if
      setFocus()
      return true
    else if key = "OK"
      onControlKeyPress()
      return true

    else if key = "play"
      m.nodeIndex = 0
      setFocus()
    end if
  end if 'press'
  return false
end function