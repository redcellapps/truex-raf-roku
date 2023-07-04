'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 16/08/2021 by Igor Malasevschi

'//////////////////////
'///// SEEK
'/////////////////////'

sub initBifData()
    m.bifId = ""
    m.bifManager.deleteTempFiles()
    m.seekFileData.clear()
end sub

'============== ON GET BIF URL =========='
sub getBifFile(bifUrl as string)
    print "getBifFile "
    fileName = "index.bif"
    m.bifManager.getBifFile(bifUrl, fileName, "onGetBifFile")
end sub


'=================== ON GET BIF FILE ==============='
sub onGetBifFile(pEvent as dynamic)
    print "onGetBifFile "

    data = pEvent.getData()

    if data <> "invalid"
        m.bifData = m.bifManager.parseBifFile("index.bif")
        unixTimeNow = getCurrentTime()
        m.bifId = (m.itemID).ToStr() + "_" + (unixTimeNow).ToStr()
    end if
end sub

'============ FIRE SEEK =============================='
sub fireSeek()
  updateThumbs()
end sub

'============= GENERATE SEEK DATA ==================='
sub generateBifData()
  if m.seekData.count() > 0  return

  items = Int(m.duration / 10)

  for index = 0 to items step 1

    timestamp = index * 10
    
    ref = {
      timestamp : timestamp,
      bufferStart: -1,
      bufferEnd: -1
    }

    m.seekData.push(ref)
  end for

 if (items * 10) < m.duration

    ref = {
      timestamp : Int(m.duration),
      buStart : -1,
      bufend : -1
    }

    m.seekData.push(ref)
  end if 
end sub


'========== GET INDEX IN BIF FILE =============='
function getIndexInBifData() as integer

  if m.seekPos = invalid
    return -1
  end if

  for index = 0 to m.seekData.count() - 1 step 1
    if m.seekPos < m.seekData[index].timestamp
      return index
    end if
  end for

  return -1
end function



'======== SEEK PLAYER TO POS  ================='
sub seekPlayerToPos()
    m.loadingIndicator.control = "start"
    m.loadingIndicator.visible = true
    
    m.player.seek = m.seekPos
    
    initSeekView()

    initFocus()
    setFocus()
    m.seekIndex = -1
    m.thumbnailsView.visible = false

end sub

'=========== UPDATE THUMBS ==========================='
sub updateThumbs()

  if m.seekMethod = "fastforward"
    m.seekFF.visible = true
    m.seekRew.visible = false

    if m.seekIndex < m.seekData.count() - 1
      oldIndex = m.seekIndex
      m.seekIndex = m.seekIndex + 1
      getSeekThumbs(oldIndex, m.seekIndex)
    else
      'initSeekView()
    end if

  else
    m.seekFF.visible = false
    m.seekRew.visible = true

    if m.seekIndex > 0
      oldIndex = m.seekIndex 
      m.seekIndex = m.seekIndex - 1
      getSeekThumbs(oldIndex, m.seekIndex)
    else
      'initSeekView()
    end if
  end if
end sub


'============  AUTOMATIC SEEK =============================='
function automaticSeek(seekMethod as string) as boolean

  if m.Player.state = "buffering" or m.seekData.count() = 0 or m.itemtype <> "movie"
    return false
  end if

  m.isPlaying = false
  m.player.control = "pause"
  m.autoKeyPressed = true

  if m.seekIndex = -1
    index = getIndexInBifData()
    if index >= 0
      oldIndex = m.seekIndex
      m.seekIndex = index
      getSeekThumbs(oldIndex, index)
    end if
  end if

  m.seekSpeed = m.seekSpeed + 1

  if m.seekSpeed = 4
    m.seekSpeed = 1
  end if

  if seekMethod <> m.seekMethod
    m.seekMethod = seekMethod
    m.seekSpeed = 1
  end if

  if m.seekSpeed = 1
    m.speedLbl.text = "1x"
    m.speedLbl.visible = true

  else if m.seekSpeed = 2
    m.speedLbl.text = "2x"
    m.speedLbl.visible = true
  else
    m.speedLbl.text = "3x"
    m.speedLbl.visible = true
  end if

  if seekMethod = "fastforward"
    m.seekFF.visible = true
    m.seekRew.visible = false
  else
    m.seekFF.visible = false
    m.seekRew.visible = true
  end if

  if m.seekSpeed = 1
    m.seekTimer.duration = "0.5"

  else if m.seekSpeed = 2
    m.seekTimer.duration = "0.25"
  else if m.seekSpeed = 3
    m.seekTimer.duration = "0.15"
  end if

  if m.seekTimer.control <> "start"
    m.seekTimer.control = "start"
  end if
end function

'============ MANUAL SEEK =============================='
function manualSeek(seekMethod as string) as boolean

  if m.autoKeyPressed
    m.autoKeyPressed = false
    initSeekView()
    return false
  end if

  if m.Player.state = "buffering" or m.seekData.count() = 0 or m.itemtype <> "movie"
    return false
  end if

  m.isPlaying = false
  m.player.control = "pause"
  m.seekMethod = seekMethod
  m.seekTimer.duration = "0.15"
  m.seekTimer.control = "start"
  m.seekSpeed = 0

  if m.seekIndex = -1
    index = getIndexInBifData()
    if index >= 0
      oldIndex = m.seekIndex
      m.seekIndex = index
      getSeekThumbs(oldIndex, index)
    end if

    return true
  end if

  if seekMethod = "fastforward"

    m.seekFF.visible = true
    m.seekRew.visible = false

    if m.seekIndex < m.seekData.count() - 1
      oldIndex = m.seekIndex
      m.seekIndex = m.seekIndex + 1

      getSeekThumbs(oldIndex, m.seekIndex)
    end if
  else
    m.seekFF.visible = false
    m.seekRew.visible = true

    if m.seekIndex > 0
      oldIndex = m.seekIndex
      m.seekIndex = m.seekIndex - 1
      getSeekThumbs(oldIndex, m.seekIndex)
    end if
  end if

  return true
end function


'======== GET SEEK THUMBS ==============='
sub getSeekThumbs(oldPos as integer, newPos as integer)
  m.seekPos = m.seekData[newPos].timestamp

  updateProgressBar(m.seekPos)
  updateSeekPos(m.seekPos)

  m.thumbnailsView.callFunc("clearSeekThumbs")
  getVisibleData(oldPos, newPos)
  displayVisibleThumbs(oldPos, newPos)
end sub


'========= FILE SEEK EXIST ================= '
function fileSeekExist(file as string) as boolean
    list = m.bifManager.checkFileExists(file)
    return list.count() > 0
end function


sub getVisibleData(oldPos as integer, newPos as integer)
    startIndex = newPos - 2
    endIndex = newPos + 2

    for index = startIndex to endIndex step 1
        'if index >= 0 and endIndex < m.seekData.count() 
         ''  fileName = "frame_" + m.bifID + "_" + (0).ToStr() + ".jpg"
          '' m.seekFileData.push(fileName)

           if index >= 0 and endIndex < m.bifData.count() and  m.bifData[index].bufferStart > 0 and m.bifData[index].bufferEnd > 0
                 fileName = "frame_" + m.bifID + "_" + (index).ToStr() + ".jpg"
                 if not fileSeekExist(fileName)
                    result = m.bifManager.writeBytesToTempFile(fileName, m.bifData[index].bufferStart, m.bifData[index].bufferEnd)
                    if result
                         'm.seekFileData.Pop()
                         m.seekFileData.push(fileName)
                     end if 
                end if
         end if
      'end if 
    end for

    if newPos < oldPos
        if m.seekFileData.count() > 5
            fileName = m.seekFileData.Pop()
            m.seekFileData.Unshift(fileName)

            fileName = m.seekFileData.Pop()
            m.bifManager.deleteTempFile(fileName)
        end if
    else
        while m.seekFileData.count() > 5
            fileName = m.seekFileData.Shift()
            m.bifManager.deleteTempFile(fileName)
        end while
    end if
end sub




'============ DISPLAY VISIBLE THUMBS ==========='
function displayVisibleThumbs(oldPos as integer, newPos as integer) as boolean

    if m.seekFileData.count() = 0
        m.thumbnailsView.visible = false
        return false
    end if

    m.thumbnailsView.visible = true

    if newPos = 0
        m.thumbnailsView.callFunc("fillSeeks", 2, m.seekFileData)
    else if newPos = 1
        m.thumbnailsView.callFunc("fillSeeks", 1, m.seekFileData)
    else if newPos = m.seekData.count() - 2
         m.thumbnailsView.callFunc("fillSeeks", -1, m.seekFileData)
     else if newPos = m.seekData.count() - 1
         m.thumbnailsView.callFunc("fillSeeks", -2, m.seekFileData)
    else
        m.thumbnailsView.callFunc("fillSeeks", 0, m.seekFileData)
    end if 
end function

