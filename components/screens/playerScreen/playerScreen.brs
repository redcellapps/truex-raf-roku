'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 25/06/2021 by Igor Malasevschi

sub init()
  m.player = m.top.FindNode("player")
  m.player.SetCertificatesFile("common:/certs/ca-bundle.crt")
  m.player.retrievingBarVisibilityAuto = false
  m.player.bufferingBarVisibilityAuto = false
  m.player.observeField("state", "onPlayerStateChange")
  m.loadingIndicator = m.top.FindNode("loadingIndicator")
  m.detailsOverlay = m.top.findNode("detailsOverlay")
  m.checkStreamTimer = m.top.findNode("checkStreamTimer")
  m.checkStreamTimer.observeField("fire", "onCheckStreamTimer")
  m.startTimeLbl = m.top.findNode("startTimeLbl")
  m.progressBar = m.top.findNode("progressBar")
  m.currentPosGroup = m.top.findNode("currentPosGroup")
  m.currentPosThumb = m.top.findNode("currentPosThumb")
  m.nameLbl = m.top.findNode("nameLbl")
  m.errorLabel = m.top.findNode("errorLabel")
  m.controlsView = m.top.findNode("controlsView")
  m.controlsView.observeField("buttonSelected", "onControlsButtonSelected")
  m.controlsView.observeField("buttonFocused", "onControlsButtonFocused")
  m.thumbnailsView = m.top.findNode("thumbnailsView")
  
  m.seekData = CreateObject("roArray", 0, true)
  m.seekFileData = CreateObject("roArray", 0, true)
  m.bifData = CreateObject("roArray", 0, true)
  m.seekTimer = m.top.FindNode("seekTimer")
  m.seekTimer.observeField("fire", "fireSeek")

  m.seekFF = m.top.FindNode("seekFF")
  m.seekRew = m.top.FindNode("seekRew")
  m.speedLbl = m.top.FindNode("speedLbl")

  m.bifManager = BifManager()
  initFocus()
 end sub

'========== INIT PLAYER SCREEN ========'
sub initPlayerScreen()
  m.player.state = "none"
  m.player.content = invalid
  m.checkStreamTimer.control = "stop"
  m.isPlaying = false
  m.detailsOverlay.visible = false
  m.itemID = -1
  m.duration = 0
  m.startTimeLbl.text = ""
  m.currentPosGroup.translation = [-115, 766]
  m.itemType = ""
  m.pauseOffset = 0
  m.progressBar.width = 0
  m.errorLabel.text = ""
  m.errorLabel.visible = false
 
  m.playingSec = 0
  m.autoKeyPressed = false
  m.seekIndex = -1

  m.thumbnailsView.visible = false
  initBifData()

  m.seekData.clear()
  m.seekFileData.clear()
  m.bifData.clear()

  m.tagOffset = getGlobal("midrollInterval")
end sub

'========== SET CONTROL PRESET =========
sub disableControls()
   m.controlsView.disabledControls = true
end sub

'=============== PLAY  STREAM ========================
sub playStream(mediaItem as object)

  m.loadingIndicator.visible = true
  m.loadingIndicator.control = "start"

  initPlayerScreen()
  initSeekView()
  setDetails(mediaItem)

  videoContent = createObject("RoSGNode", "ContentNode")
  videoContent.streamformat = "hls"
  videoContent.url = mediaItem.mediaSource

  m.player.content = videoContent

  if m.seekPos > 0
    m.player.seek = m.seekPos
  end if

  if mediaItem.prerrolAdUrl <> "" or mediaItem.midrollAdUrl <> ""
    playContentWithRAF(mediaItem.prerrolAdUrl, mediaItem.midrollAdUrl, Int(mediaItem.duration))
  else 
    m.player.control = "play"
  end if 

end sub

'========== PLAY CONTENT WITH RAF ==========
sub playContentWithRAF(prerrolAdUrl as String, midrollAdUrl as String, duration as integer)
  m.rafIntegration = CreateObject("roSGNode", "rafIntegration")
  m.rafIntegration.observeField("state", "rafStateChanged")
  m.rafIntegration.video = m.player
  m.rafIntegration.prerrolAdUrl = prerrolAdUrl
  m.rafIntegration.midrollAdUrl = midrollAdUrl
  m.rafIntegration.contentID = m.itemID
  m.rafIntegration.duration = duration
  m.rafIntegration.seekPos = m.seekPos

  m.rafIntegration.control = "RUN"
end sub

sub rafStateChanged(pEvent as dynamic)
    response = pEvent.getData()

    if response = "stop"
      closeRafIntegration()
      m.top.getParent().callFunc("closePlayerScreen", Int(m.player.position))
    end if 
end sub

sub closeRafIntegration()
    if m.rafIntegration <> invalid
        m.rafIntegration.keepPlaying = false
        m.rafIntegration = invalid
    end if 
end sub

'=============== STOP  STREAM ========================
sub stopStream()
  m.player.control = "stop"
  closeRafIntegration()
end sub

'============== SET DETAILS =================='
sub setDetails(mediaItem as object)
  m.nameLbl.text = mediaItem.name
  m.itemType = mediaItem.itemType
  m.seekPos = mediaItem.playerPos
  m.itemID = mediaItem.itemID

  if m.itemtype = "movie"
     m.controlsView.callFunc("setMovieButtons")
     updateProgressBar(mediaItem.playerPos)
     updateSeekPos(mediaItem.playerPos)

     if mediaItem.bifUrl <> invalid and mediaItem.bifUrl <> ""
       getBifFile(mediaItem.bifUrl)
     end if 
  else
    m.controlsView.callFunc("setLiveButtons")

    m.startTime = getEventStartTime()
    m.endTime  = m.startTime  + 3600 * 24
    m.duration = m.endTime - m.startTime
    
    m.startTimeLbl.text =  getCurrentData() + ", " + getCurrentTimeFormatted()

    eventStartOffset = getEventStartOffset()
    updateProgressBar(eventStartOffset)
  end if

  m.detailsOverlay.visible = true
end sub


'=========== SET FOCUS ============'
sub setFocus()

  if m.nodeIndex = 0
    m.top.setFocus(m.top.focus)
    m.controlsView.focus = false
    m.currentPosThumb.visible = true
  else
    m.controlsView.focus = true
    m.currentPosThumb.visible = false
  end if
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
  setFocus()
end sub

'========== INIT FOCUS =========='
sub initFocus()
  m.nodeIndex = 0
  m.controlsView.focus = false
end sub

'=========== 'INIT SEEK VIEW ================
sub initSeekView()
  m.elapsedSec = 0
  m.seekTimer.duration = "0.15"
  m.seekTimer.control = "stop"
  m.seekMethod = ""
  m.seekSpeed = 0
  m.seekFF.visible = false
  m.seekRew.visible = false
  m.speedLbl.visible = false
end sub

'============ ON VIDEO PLAYER STATE CHANGE ========================='
sub onPlayerStateChange() as object
  print "player - ["; m.player.state ; "]"

  m.controlsView.state = m.player.state

  if m.player.state = "error"
    m.isPlaying = false
    m.loadingIndicator.control = "stop"
    m.loadingIndicator.visible = false
    m.detailsOverlay.visible = true
    displayErrorMessage(m.global.playerError)
    m.checkStreamTimer.control = "stop"

  else if m.player.state = "playing"
    m.isPlaying = true
    m.checkStreamTimer.control = "start"
    m.loadingIndicator.control = "stop"
    m.loadingIndicator.visible = false

    if m.itemType = "movie" and m.duration = 0
      m.duration = m.player.duration
      updateSeekPos(m.seekPos)
      updateProgressBar(m.seekPos)
      generateBifData()
    end if

  else if m.player.state = "finished"
    m.isPlaying = false
    m.loadingIndicator.control = "stop"
    m.loadingIndicator.visible = false
    m.checkStreamTimer.control = "stop"

    if m.errorLabel.visible = false and m.itemType = "movie"
      closeRafIntegration()
      m.top.getParent().callFunc("getNextMediaItem")
    end if

  else if m.player.state = "stopped"
    m.isPlaying = false
    m.loadingIndicator.control = "stop"
    m.loadingIndicator.visible = "false"
    m.checkStreamTimer.control = "stop"

  else if m.player.state = "buffering"
    m.isPlaying = false
    m.loadingIndicator.control = "start"
    m.loadingIndicator.visible = "true"
    m.detailsOverlay.visible = true
    m.elapsedSec = 0 
  end if
end sub

'=============== ON CHECK STREAM TIMER ============='
sub onCheckStreamTimer()

  if m.isPlaying
    if m.elapsedSec >= 5 and m.elapsedSec < 10 and m.detailsOverlay.visible
      m.detailsOverlay.visible = false
      initFocus()
      setFocus()
    end if

    m.elapsedSec = m.elapsedSec + 1
    m.playingSec = m.playingSec + 1

    if m.rafIntegration <> invalid and (m.playingSec >= m.tagOffset)
        m.playingSec = 0
        m.rafIntegration.displayPrerollAd = true
    end if 

    if  m.itemType = "movie"
        updateSeekPos(m.player.position)
        updateProgressBar(m.player.position)
    end if 
  end if

  if  m.itemType <> "movie"
      m.startTimeLbl.text =  getCurrentData() + ", " + getCurrentTimeFormatted()

      eventStartOffset = getEventStartOffset()
      updateProgressBar(eventStartOffset)
  end if 
end sub

'=============== Play Stream ========================
sub playPause()

  if (not m.player.state = "paused") and (not m.player.state = "playing")
    return
  end if

  m.elapsedSec = 0
  m.detailsOverlay.visible = true

  if m.isPlaying
    m.player.control = "pause"
    m.isPlaying = false
  else
    m.player.control = "resume"
  end if

  m.thumbnailsView.visible = false
end sub


'=============== ON CONTROLS BUTTON SELECTED ============='
sub onControlsButtonSelected()

  if m.controlsView.buttonSelected = -1
    if m.itemType = "movie"
         automaticSeek("rewind")
    else
      m.top.getParent().callFunc("getPreviousMediaItem")
    end if

  else if m.controlsView.buttonSelected = 0
    if m.seekIndex = -1
        playPause()
    else if m.itemType = "movie" and m.seekIndex >= 0 and m.seekData.count() > 0
        seekPlayerToPos()
    end if

  else if m.controlsView.buttonSelected = 1
    if m.itemType = "movie"
         automaticSeek("fastforward")
    else
      m.top.getParent().callFunc("getNextMediaItem")
    end if
  end if

end sub

sub onControlsButtonFocused()
  m.elapsedSec = 0
end sub

'============  UPDATE PROGRESS BAR  ==============='
sub updateProgressBar(playerPos as double)

  if m.duration > 0 and playerPos <= m.duration
    percents = playerPos * 100 / m.duration
    width = 1626 * percents / 100
    m.progressBar.width = width
  end if
end sub

'================== UPDATE SEEK POSITION ==============='
sub updateSeekPos(seekPos as double)

  m.seekPos = seekPos
  if m.duration > 0 and seekPos <= m.duration
    percents = seekPos * 100 / m.duration
    width = 1626 * percents / 100
    posX = width + 147

    if m.itemType = "movie" 
      m.startTimeLbl.text = dateFromIntegerToString(seekPos) + " / " + dateFromIntegerToString(m.duration)
    end if

    m.currentPosGroup.translation = [posX - 17, 766]
  end if
end sub


'============ GET EVENT START OFFSET =========='
function getEventStartOffset() as integer
  return getCurrentTime() - m.startTime
end function


sub displayErrorMessage(message as object)
  m.errorLabel.text = message
  m.errorLabel.visible = true

  if m.itemType = "movie"
    m.detailsOverlay.visible = false
  end if
end sub



'//////////////////////
'///// EVENTS HANDLER
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
  'print "onKeyEvent playerScreen ";key;" "; press

  if press = false

    if m.autoKeyPressed = false
      initSeekView()
    end if
  end if


  if press

    if key = "back"

      if m.autoKeyPressed = true
        m.autoKeyPressed = false
        initSeekView()
        return true
      end if

      if m.player.state = "buffering"
          closeRafIntegration()
          m.top.getParent().callFunc("closePlayerScreen", m.seekPos)
          return true
      end if 

       if m.detailsOverlay.visible
        m.detailsOverlay.visible = false
        initFocus()
        setFocus()
       
        if m.player.state = "paused"
          playPause()
        end if
        return true
      end if

      closeRafIntegration()
      m.top.getParent().callFunc("closePlayerScreen", Int(m.player.position))
      return true

    else if key = "OK"

      if m.errorLabel.visible = true 
        return true
      end if

      m.elapsedSec = 0
      m.detailsOverlay.visible = true

      if m.seekIndex >= 0 and m.seekData.count() > 0
          seekPlayerToPos()
      end if 

      return true

    else if key = "play"

      if m.seekIndex >= 0 and m.seekData.count() > 0
        seekPlayerToPos()
        return true
      end if 
      
      playPause()
      return true


    else if key = "left"

      if m.errorLabel.visible = true
        return true
      end if

      m.detailsOverlay.visible = true
      initSeekView()
      manualSeek("rewind")

      return true

    else if key = "right"

      if m.errorLabel.visible = true
        return true
      end if

      m.detailsOverlay.visible = true
      initSeekView()
      manualSeek("fastforward")

      return true

    else if key = "rewind"

      if m.errorLabel.visible = true 
        return true
      end if

      m.detailsOverlay.visible = true
      initFocus()
      setFocus()
      automaticSeek("rewind")
      return true

    else if key = "fastforward"

      if m.errorLabel.visible = true 
        return true
      end if

      m.detailsOverlay.visible = true
      initFocus()
      setFocus()

      automaticSeek("fastforward")
      return true

    else if key = "down"
      m.elapsedSec = 0

      'if m.detailsOverlay.visible = false
      m.detailsOverlay.visible = true
      ''   return true
      'end if

      m.nodeIndex = 1

      setFocus()

      return true

    else if key = "up"
      m.elapsedSec = 0

      'if m.detailsOverlay.visible = false
      m.detailsOverlay.visible = true
      ''    return true
      'end if

      initFocus()
      setFocus()
      return true

    end if
  end if 'press'

  return false

end function

