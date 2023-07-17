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
  ' here
  m.bifData = CreateObject("roArray", 0, true)
  m.seekTimer = m.top.FindNode("seekTimer")
  m.seekTimer.observeField("fire", "fireSeek")

  m.seekFF = m.top.FindNode("seekFF")
  m.seekRew = m.top.FindNode("seekRew")
  m.speedLbl = m.top.FindNode("speedLbl")


  ' here
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
  ' here
  initBifData()

  m.seekData.clear()
  m.seekFileData.clear()
  ' here
  m.bifData.clear()

  m.tagOffset = getGlobal("midrollInterval")
end sub

'========== SET CONTROL PRESET =========
sub disableControls()
   m.controlsView.disabledControls = true
end sub

'=============== PLAY  STREAM ========================
sub playStream(mediaItem as object)
	?"****** playerScreen ****** playStream() -----> "

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

  ' stop
  if mediaItem.prerrolAdUrl <> "" or mediaItem.midrollAdUrl <> ""
    ' playContentWithRAF(mediaItem.prerrolAdUrl, mediaItem.midrollAdUrl, Int(mediaItem.duration))
    ?"****** playerScreen ****** playStream() -----> mediaItem: "; mediaItem
    ' url = "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4"
    ' url = m.player.content.URL
    ' initRafTask(mediaItem.prerrolAdUrl, mediaItem.midrollAdUrl, mediaItem, url)
    ' launchTruexAd()
    ' beginStream("https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4")
    beginStream(m.player.content.URL)

  else 
    m.player.control = "play"
  end if 

end sub

sub initRafTask(prerrolAdUrl as String, midrollAdUrl as String, mediaItem as object, url as string)
  ?"****** playerScreen ****** initRafTask() -----> "

  m.rafTask = CreateObject("roSGNode", "PlaybackTask")
  m.rafTask.video = m.player
  m.rafTask.adFacade = m.top.findNode("adFacade")
  m.rafTask.observeField("playerDisposed", "onPlaybackTaskEvent")

  m.rafTask.prerrolAdUrl = prerrolAdUrl
  m.rafTask.midrollAdUrl = midrollAdUrl
  m.rafTask.mediaItem = mediaItem
  m.rafTask.videoUrl = url
  m.rafTask.vmap = m.v

  m.rafTask.control = "run"
end sub

sub onPlaybackTaskEvent(event as object)
  name = event.getField()
  if name = "playerDisposed" then
    m.top.getParent().callFunc("closePlayerScreen", Int(m.player.position))
  end if
end sub

sub beginStream(url as string)
  ?"****** playerScreen ****** beginStream() -----> url "; url

  unpackStreamInformation()

  videoContent = CreateObject("roSGNode", "ContentNode")
  videoContent.url = url
  ' videoContent.title = m.streamData.title
  videoContent.streamFormat = "hls"
  videoContent.playStart = 0

  m.player.content = videoContent
  m.player.SetFocus(true)
  m.player.visible = true
  m.player.retrievingBar.visible = false
  m.player.bufferingBar.visible = false
  m.player.retrievingBarVisibilityAuto = false
  m.player.bufferingBarVisibilityAuto = false
  m.player.observeFieldScoped("position", "onVideoPositionChange")
  m.player.control = "play"
  m.player.EnableCookies()
end sub

sub onVideoPositionChange()
  ' ? "TRUE[X] >>> ContentFlow::onVideoPositionChange: " + Str(m.player.position) + " duration: " + Str(m.player.duration)
  ?"****** playerScreen ****** onVideoPositionChange() -----> m.vmap "; m.vmap

  if m.vmap = invalid or m.vmap.Count() = 0 then return
  playheadInPod = false

  ' Check to see if playback has entered a true[X] spot, and if so, start true[X].
  for each vmapEntry in m.vmap
      if vmapEntry.startOffset <> invalid and vmapEntry.endOffset <> invalid then
          if m.player.position >= vmapEntry.startOffset and m.player.position <= vmapEntry.endOffset then
							if m.adRenderer = invalid
									?"****** playerScreen ****** onVideoPositionChange() -----> vmapEntry.breakId "; vmapEntry.breakId
                  ?"****** playerScreen ****** onVideoPositionChange() -----> vmapEntry.vastUrl "; vmapEntry.vastUrl
                  m.currentAdBreak = vmapEntry
                  launchTruexAd()
              end if
              ' Do not allow video scrubbing while in the true[X] opt-in flow
              m.player.enableTrickPlay = false
              playheadInPod = true
          else
              m.player.enableTrickPlay = true
          end if
      end if 
  end for

  if m.adRenderer <> invalid and not playheadInPod then
      ? "TRUE[X] >>> ContentFlow::onVideoPositionChange: exiting pod, dismissing TAR"
      ' If we are not in a pod and TAR is active that is taken to mean playback has auto-advanced past the opt-in card 
      ' into the rest of the video ads without the viewer taking action to opt-in or out. 
      ' This scenario is known as an auto-advance opt-out (non user initiated opt-out)
      ' Therefore terminate TAR at this stage.
      m.adRenderer.action = { type : "stop" }
  end if

  m.lastVideoPosition = m.player.position
end sub

sub launchTruexAd()
  decodedData = m.currentAdBreak
  if decodedData = invalid then return

	?"****** playerScreen ****** launchTruexAd() -----> m.player.position: "; m.player.position

  ' Hedge against Roku playhead imprecision by adding buffer so that non choice card content is not shown
  m.videoPositionAtAdBreakPause = m.player.position + 0.5
  ' Note: bumping the seek interval as the Roku player seems to have trouble seeking ahead to a specific time based on the type of stream.
  m.streamSeekDuration = decodedData.cardDuration + 3
  ' Populating the test ad from the local mock payload
  ' In a real world situation, the adParameters returned from the ad server will be populated similarly 
  ' for the One Stage type integration we're demonstrating here.
  adPayload = ParseJson(ReadAsciiFile(decodedData.vastPayload).trim())
  adPayload.placement_hash = decodedData.placementHash
  ' instantiate TruexAdRenderer and register for event updates
  m.adRenderer = m.top.createChild("TruexLibrary:TruexAdRenderer")
  m.adRenderer.observeFieldScoped("event", "onTruexEvent")
  ' use the companion ad data to initialize the true[X] renderer
  tarInitAction = {
      type: "init",
      adParameters: adPayload,
      supportsUserCancelStream: true, ' enables cancelStream event types, disable if Channel does not support
      slotType: UCase(getCurrentAdBreakSlotType()),
      logLevel: 1, ' Optional parameter, set the verbosity of true[X] logging, from 0 (mute) to 5 (verbose), defaults to 5
      channelWidth: 1920, ' Optional parameter, set the width in pixels of the channel's interface, defaults to 1920
      channelHeight: 1080 ' Optional parameter, set the height in pixels of the channel's interface, defaults to 1080
  }
	?"****** playerScreen ****** launchTruexAd() -----> tarInitAction: "; tarInitAction
  m.adRenderer.action = tarInitAction
  m.adRenderer.action = { type: "start" }
  m.adRenderer.focusable = true
  m.adRenderer.SetFocus(true)
end sub

function getCurrentAdBreakSlotType() as dynamic
	?"****** playerScreen ****** getCurrentAdBreakSlotType() -----> "

  if m.currentAdBreak = invalid then return invalid
  if m.currentAdBreak.podindex > 0 then return "midroll" else return "preroll"
end function

sub onTruexEvent(event as object)
	?"****** playerScreen ****** onTruexEvent() -----> "

  data = event.getData()
  if data = invalid then return else ? "TRUE[X] >>> ContentFlow::onTruexEvent(eventData=";data;")"

  if data.type = "adFreePod" then
      ' this event is triggered when a user has completed all the true[X] engagement criteria
      ' this entails interacting with the true[X] ad and viewing it for X seconds (usually 30s)
      ' user has earned credit for the engagement, set seek duration to skip the entire ad break
      m.streamSeekDuration = m.streamSeekDuration + m.currentAdBreak.videoAdDuration
  else if data.type = "adStarted" then
      ' this event is triggered when the true[X] Choice Card is presented to the user
  else if data.type = "adFetchCompleted" then
      ' this event is triggered when TruexAdRenderer receives a response to an ad fetch request
  else if data.type = "optOut" then
      ' this event is triggered when a user decides not to view a true[X] interactive ad
      ' that means the user was presented with a Choice Card and opted to watch standard video ads
      if not data.userInitiated then
          m.skipSeek = true
      end if
  else if data.type = "optIn" then
      ' this event is triggered when a user decides opt-in to the true[X] interactive ad
      m.player.control = "stop"
  else if data.type = "adCompleted" then
      ' this event is triggered when TruexAdRenderer is done presenting the ad
      ' if the user earned credit (via "adFreePod") their content will already be seeked past the ad break
      ' if the user has not earned credit their content will resume at the beginning of the ad break
      resumeVideoStream()
  else if data.type = "adError" then
      ' this event is triggered whenever TruexAdRenderer encounters an error
      ' usually this means the video stream should continue with normal video ads
      resumeVideoStream()
  else if data.type = "noAdsAvailable" then
      ' this event is triggered when TruexAdRenderer receives no usable true[X] ad in the ad fetch response
      ' usually this means the video stream should continue with normal video ads
      resumeVideoStream()
  else if data.type = "userCancel" then
      ' This event will fire when a user backs out of the true[X] interactive ad unit after having opted in. 
      ' Here we need to seek back to the beginning of the true[X] video choice card asset
      m.streamSeekDuration = 0
      resumeVideoStream()
  else if data.type = "userCancelStream" then
      ' this event is triggered when the user performs an action interpreted as a request to end the video playback
      ' this event can be disabled by adding supportsUserCancelStream=false to the TruexAdRenderer init payload
      ' there are two circumstances where this occurs:
      '   1. The user was presented with a Choice Card and presses Back
      '   2. The user has earned an adFreePod and presses Back to exit engagement instead of Watch Your Show button
      ? "TRUE[X] >>> ContentFlow::onTruexEvent() - user requested video stream playback cancel..."
      ' tearDown()
      ' m.top.event = { trigger: "cancelStream" }
  end if
end sub

sub resumeVideoStream()
  ' destroyTruexAdRenderer()
	?"****** playerScreen ****** resumeVideoStream() -----> "

  if m.player <> invalid then
      m.player.SetFocus(true)
      if m.skipSeek = invalid then
          ' resume playback from the appropriate post true[X] card point (opt-out case) or for a completed ad (opt-in + complete)
          m.player.control = "play"
          ' m.player.seek = m.videoPositionAtAdBreakPause + m.streamSeekDuration
          ' ? "TRUE[X] >>> ContentFlow::resumeVideoStream(position=" + StrI(m.player.position) + ", seek=" + StrI(m.videoPositionAtAdBreakPause + m.streamSeekDuration) + ")"
      else
          ' do not touch playhead if opted out by auto-advancing past the card point
          ' ? "TRUE[X] >>> ContentFlow::resumeVideoStream, skipped seek (position=" + StrI(m.player.position) + ")"
      end if
      m.skipSeek = invalid
      m.currentAdBreak = invalid
      m.streamSeekDuration = invalid
      m.videoPositionAtAdBreakPause = invalid
  end if
end sub

function unpackStreamInformation() as boolean
  if m.global.streamInfo = invalid then
			?"****** playerScreen ****** unpackStreamInformation() -----> m.global.streamInfo: "; m.global.streamInfo
      return false
  end if
  jsonStreamInfo = ParseJson(m.global.streamInfo)[0]
  if jsonStreamInfo = invalid then
			?"****** playerScreen ****** unpackStreamInformation() -----> jsonStreamInfo: "; jsonStreamInfo
      return false
  end if
  preprocessVmapData(jsonStreamInfo.vmap)

  ' define the test stream
  m.streamData = {
      title: jsonStreamInfo.title,
      url: jsonStreamInfo.url,
      vmap: jsonStreamInfo.vmap,
      type: "vod"
  }
	?"****** playerScreen ****** unpackStreamInformation() ----->  m.streamData: "; m.streamData
  return true
end function

sub preprocessVmapData(vmapJson as object)
	?"****** playerScreen ****** preprocessVmapData() ----->  vmapJson: "; vmapJson

  if vmapJson = invalid or Type(vmapJson) <> "roArray" return
  m.vmap = []

  for i = 0 to vmapJson.Count() - 1
      vmapEntry = vmapJson[i]
      timeOffset = vmapEntry.timeOffset
      duration = vmapEntry.cardDuration
      videoAdDuration = vmapEntry.videoAdDuration

      if timeOffset <> invalid and duration <> invalid then
          ' trim ms portion
          timeOffset = timeOffset.Left(8)
          timeOffsetComponents = timeOffset.Split(":")
          timeOffsetSecs = timeOffsetComponents[2].ToInt() + timeOffsetComponents[1].ToInt() * 60 + timeOffsetComponents[0].ToInt() * 3600
          timeOffsetEnd = timeOffsetSecs + duration.ToInt()
          vmapEntry.startOffset = timeOffsetSecs
          vmapEntry.endOffset = timeOffsetEnd
          vmapEntry.cardDuration = duration.ToInt()
          vmapEntry.videoAdDuration = videoAdDuration.ToInt()
          vmapEntry.podindex = i
          m.vmap.Push(vmapEntry)
      end if
  end for
end sub

'========== PLAY CONTENT WITH RAF ==========
' sub playContentWithRAF(prerrolAdUrl as String, midrollAdUrl as String, duration as integer)
'   m.rafIntegration = CreateObject("roSGNode", "rafIntegration")
'   m.rafIntegration.observeField("state", "rafStateChanged")
'   m.rafIntegration.video = m.player
'   m.rafIntegration.prerrolAdUrl = prerrolAdUrl
'   m.rafIntegration.midrollAdUrl = midrollAdUrl
'   m.rafIntegration.contentID = m.itemID
'   m.rafIntegration.duration = duration
'   m.rafIntegration.seekPos = m.seekPos

'   m.rafIntegration.control = "RUN"
' end sub

' sub rafStateChanged(pEvent as dynamic)
'     response = pEvent.getData()

'     if response = "stop"
'       closeRafIntegration()
'       m.top.getParent().callFunc("closePlayerScreen", Int(m.player.position))
'     end if 
' end sub

' sub closeRafIntegration()
'     if m.rafIntegration <> invalid
'         m.rafIntegration.keepPlaying = false
'         m.rafIntegration = invalid
'     end if 
' end sub

'=============== STOP  STREAM ========================
sub stopStream()
  m.player.control = "stop"
  ' closeRafIntegration()
end sub

'============== SET DETAILS =================='
sub setDetails(mediaItem as object)
	?"****** playerScreen ****** setDetails() -----> "

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
      ' closeRafIntegration()
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
          ' closeRafIntegration()
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

      ' closeRafIntegration()
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

