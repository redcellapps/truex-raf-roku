'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 08/08/2021 by Igor Malasevschi

'========== INIT  ==========='
sub init()
   m.messageScreen = m.top.findNode("messageScreen")
   m.playerScreen = m.top.findNode("playerScreen")
end sub



'=========== GET ITEM ============
sub getItem(deeplinkData as object)
  
  apiUrl = getGlobal("apiUrl")
  countryCode = getCountryCode()

  m.apiController = apiController(apiUrl,countryCode)
  m.apiController.getMediaItem(deeplinkData.deepcontentid, "onGetMediaItem")
end sub

'============ ON GET MEDIA ITEM =========='
function onGetMediaItem(pEvent as dynamic) as boolean

  response = pEvent.getData()

  if response.data <> invalid

    prerrolAdUrl = ""

    if response.data.preroll_ad <> invalid
        prerrolAdUrl = response.data.preroll_ad
    end if 

    if response.data.midroll_ad <> invalid
        midrollAdUrl = response.data.midroll_ad
    end if
    
    mediaItem = {
      name: response.data.name,
      mediaSource: response.data.media_item_source,
      itemType: response.data.type,
      playerPos: 0,
      duration: response.data.duration,
      itemID: response.data.id,
      bifUrl: response.data.bif,
      prerrolAdUrl: prerrolAdUrl,
      midrollAdUrl: midrollAdUrl
    }
  
    playMediaItem(mediaItem)

  else
    displayErrorMessage(m.global.apiGenericError)
  end if
end function


'=========== PLAY MEDIA ITEM =========
sub playMediaItem(mediaItem as object)
  m.playerScreen.callFunc("playStream", mediaItem)
  
  if mediaItem.itemType <> "movie"
      m.playerScreen.callFunc("disableControls")
  end if 

  m.playerScreen.visible = true
  m.playerScreen.focus = true
end sub


'============== CLOSE PLAYER SCREEN ===============
function closePlayerScreen(playerPos as integer)
  m.playerScreen.callFunc("stopStream")
  m.playerScreen.visible = false
  m.top.getParent().callFunc("closeDeepLinkScreen")
end function

'========= DISPLAY ERROR MESSAGE ==================='
sub displayErrorMessage(message as object)

  params = {
    errorMessage: message
  }

  m.messageScreen.callFunc("displayErrorMessage", params)
  m.messageScreen.visible = true
end sub