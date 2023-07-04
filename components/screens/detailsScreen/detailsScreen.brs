'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 11/06/2021 by Igor Malasevschi


sub init()
  m.rowList = m.top.findNode("rowList")
  m.rowList.observeField("rowItemFocused", "onRowItemFocused")
  m.rowList.observeField("rowItemSelected", "onRowItemSelected")
  m.detailsScreen = m.top.findNode("detailsScreen")
  m.categoriesData = CreateObject("roArray", 0, true)
  m.nameLbl = m.top.findNode("nameLbl")
  m.nameLbl.font.size = 50
  m.descriptionLbl = m.top.findNode("descriptionLbl")
  m.landscapeImgLow = m.top.findNode("landscapeImgLow")
  m.landscapeImgHigh = m.top.findNode("landscapeImgHigh")
  m.mediaSource = ""
  m.playBtn = m.top.findNode("playBtn")
  m.playBtn.observeField("buttonSelected", "onPlayBtnKeyPress")
  m.playerScreen = m.top.findNode("playerScreen")
  m.playBtnLbl = m.top.findNode("playBtnLbl")
  m.loadingIndicator = m.top.findNode("loadingIndicator")
  m.resumeBtn = m.top.findNode("resumeBtn")
  m.resumeBtn.observeField("buttonSelected", "onResumeBtnKeyPress")
  m.resumeBtnLbl = m.top.findNode("resumeBtnLbl")
  m.favoritesBtn = m.top.findNode("favoritesBtn")
  m.favoritesBtn.observeField("buttonSelected", "onFavoritesBtnKeyPress")
  m.durationLbl = m.top.findNode("durationLbl")
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
  setFocus()
end sub

'=========== SET FOCUS ============'
sub setFocus()

  m.top.setFocus(m.top.focus)

  if m.nodeIndex = 0
    m.playBtn.setFocus(true)
  else if m.nodeIndex = 1
    if m.buttonsCount = 2
      m.favoritesBtn.setFocus(true)
    else if m.buttonsCount = 3
      m.resumeBtn.setFocus(true)
    end if
  else
    m.favoritesBtn.setFocus(true)
  end if
end sub

'========== INIT DETAILS SCREEN =========='
sub initDetailsScreen()
  print "initDetailsScreen"
  m.buttonsCount = 2
  m.nodeIndex = 0
  m.nameLbl.text = ""
  m.durationLbl.text = ""
  m.descriptionLbl.text = ""
  m.landscapeImgLow.uri = ""
  m.landscapeImgHigh.uri = ""
  m.mediaSource = ""
  m.playerScreen.visible = false
  m.playBtnLbl.text = ""
  m.itemID = -1
  m.rowList.visible = false
  m.rowlist.content = invalid
  m.portraitImg = ""
  m.bookmarkData = invalid
  m.isFavorite = false
  m.playerPos = 0
  m.duration = 0
  m.itemType = invalid
  m.col = 0
  m.row = 0
  m.autoPlay = false
  m.bifUrl = ""
  m.prerrolAdUrl = ""
  m.midrollAdUrl = ""
end sub

'============== HIDE DETAILS =========='
sub hideDetails()
  m.nameLbl.visible = false
  m.descriptionLbl.visible = false
  m.landscapeImgLow.visible = false
  m.landscapeImgHigh.visible = false
end sub

'============= DISPLAY DETAILS ========'
sub displayDetails()
  if m.playerPos >= 10
    m.resumeBtn.visible = true
    m.resumeBtnLbl.visible = true
  end if

  m.nameLbl.visible = true
  m.descriptionLbl.visible = true
  m.landscapeImgLow.visible = true
  m.landscapeImgHigh.visible = true
end sub

'========= SET DETAILS =========='
sub setDetails(detailsObj as object)

  initDetailsScreen()
  m.itemType = detailsObj.itemType
  initButtons()

  m.nameLbl.text = detailsObj.name

  m.descriptionLbl.text = detailsObj.description
  m.landscapeImgLow.uri = detailsObj.landscapeImgLow
  m.landscapeImgHigh.uri = detailsObj.landscapeImgHigh
  m.mediaSource = detailsObj.mediaSource
  m.itemID = detailsObj.itemID
  m.portraitImg = detailsObj.portraitImg
  m.duration = detailsObj.duration
  m.bifUrl = detailsObj.bifUrl
  m.prerrolAdUrl = detailsObj.prerrolAdUrl
  m.midrollAdUrl = detailsObj.midrollAdUrl


  if detailsObj.categoryData <> invalid
    setRowListContent(detailsObj.categoryData)
  end if

  getBookMarkItems()
end sub

'========== INIT BUTTONS ==========='
sub initButtons()
  m.buttonsCount = 2
  m.nodeIndex = 0

  m.resumeBtn.visible = false
  m.resumeBtnLbl.visible = false
  m.favoritesBtn.translation = [459, 469]
  m.favoritesBtn.focusBitmapUri = "pkg:/images/detailsScreen/favorites_add_focused.png"
  m.favoritesBtn.focusFootprintBitmapUri = "pkg:/images/detailsScreen/favorites_add.png"

  if m.itemType = "radio"
    m.playBtnLbl.text = "Play Radio"
  else if m.itemType = "movie"
    m.playBtnLbl.text = "Watch Now"
  else
    m.playBtnLbl.text = "Play Live"
  end if
end sub

'=========== UPDATE BUTTONS ===========
sub updateButtons()
  if m.playerPos >= 10 and m.itemType = "movie"
    m.buttonsCount = 3
    m.favoritesBtn.translation = [815, 469]
    m.resumeBtn.visible = true
    m.resumeBtnLbl.visible = true
  end if

  if m.isFavorite
    m.favoritesBtn.focusBitmapUri = "pkg:/images/detailsScreen/favorites_remove_focused.png"
    m.favoritesBtn.focusFootprintBitmapUri = "pkg:/images/detailsScreen/favorites_remove.png"
  else
    m.favoritesBtn.focusBitmapUri = "pkg:/images/detailsScreen/favorites_add_focused.png"
    m.favoritesBtn.focusFootprintBitmapUri = "pkg:/images/detailsScreen/favorites_add.png"
  end if

end sub


'============ GET ITEM ROW ============'
function getItemRow(itemObj as object, categoryID as object) as object
  itemRow = invalid

  if m.itemID <> itemObj.itemID
    itemRow = CreateObject("roSGNode", "itemData")
    itemRow.categoryID = categoryID
    itemRow.itemID = itemObj.itemID
    itemRow.name = itemObj.name
    itemRow.itemType = itemObj.itemType
    itemRow.description = itemObj.description
    itemRow.portraitImg = itemObj.portraitImg
    itemRow.displayName = true
    itemRow.landscapeImgLow = itemObj.landscapeImgLow
    itemRow.landscapeImgHigh = itemObj.landscapeImgHigh
  end if

  return itemRow
end function

'=========== SET ROW LIST CONTENT ============='
sub setRowListContent(category as object)

  data = CreateObject("roSGNode", "ContentNode")
  row = data.CreateChild("ContentNode")
  row.title = "You may also like"


  for rowIndex = 0 to category.getChildCount() - 1 step 1
    categoryObj = category.getChild(rowIndex)

    if categoryObj.getChildCount() > 0

      for colIndex = 0 to categoryObj.getChildCount() - 1 step 1
        itemObj = categoryObj.getChild(colIndex)

        itemRow = getItemRow(itemObj, category.categoryID)
        if itemRow <> invalid
          row.appendChild(itemRow)
        end if
      end for

    else
      itemRow = getItemRow(categoryObj, category.categoryID)

      if itemRow <> invalid
        row.appendChild(itemRow)
      end if
    end if
  end for

  if data.getChild(0).getChildCount() > 0
    m.rowlist.content = data
    m.rowList.visible = true
  end if
end sub


'=========== SET ROW LIST CONTENT ============='
sub setRowListContentOld(category as object)

  data = CreateObject("roSGNode", "ContentNode")
  row = data.CreateChild("ContentNode")
  row.title = "You may also like"

  for index = 0 to category.getChildCount() - 1 step 1
    item = category.getChild(index)
    if m.itemID <> item.itemID
      itemRow = row.CreateChild("itemData")
      itemRow.categoryID = category.categoryID
      itemRow.itemID = item.itemID
      itemRow.name = item.name
      itemRow.itemType = item.itemType
      itemRow.description = item.description
      itemRow.portraitImg = item.portraitImg
      itemRow.displayName = true
      itemRow.landscapeImgLow = item.landscapeImgLow
      itemRow.landscapeImgHigh = item.landscapeImgHigh
    end if
  end for

  if data.getChild(0).getChildCount() > 0
    m.rowlist.content = data
    m.rowList.visible = true
  end if
end sub

'============= ON ROW ITEM SELECTED ============================
sub onRowItemSelected()
  m.col = m.rowlist.rowItemFocused[1]
  m.row = m.rowlist.rowItemFocused[0]

  itemDetails = m.rowlist.content.getChild(m.row).getChild(m.col)
  getItem(itemDetails.itemID)
end sub


'=========== PLAY MEDIA ITEM ========='
sub playMediaItem()
  mediaItem = {
    name: m.nameLbl.text,
    mediaSource: m.mediaSource,
    itemType: m.itemType,
    playerPos: m.playerPos,
    duration: m.duration,
    itemID: m.itemID,
    bifUrl: m.bifUrl,
    prerrolAdUrl: m.prerrolAdUrl,
    midrollAdUrl: m.midrollAdUrl

  }

  m.playerScreen.callFunc("playStream", mediaItem)
  m.playerScreen.visible = true
  m.playerScreen.focus = true
end sub

'========== ON PLAYBTN KEYPRESS ============
sub onPlayBtnKeyPress()
  m.playerPos = 0
  initButtons()

  if m.isFavorite = false
    clearBookmark()
  else
    setBookmark()
  end if

  playMediaItem()
end sub


'============= ON RESUME PLAYBTN KEYPRESS ========='
sub onResumeBtnKeyPress()
  playMediaItem()
end sub

'============== CLOSE PLAYER SCREEN ===============
function closePlayerScreen(playerPos as integer)
  m.autoPlay = false

  m.playerScreen.callFunc("stopStream")
  m.playerScreen.focus = false
  m.playerScreen.visible = false
  setFocus()

  m.playerPos = playerPos

  if playerPos >= 10 and m.itemType = "movie"
    setBookMark()
  end if

  initButtons()
  updateButtons()
end function

'============== ON FAVORITES BTN KEYPRESS ========'
sub onFavoritesBtnKeyPress()
  m.isFavorite = not m.isFavorite
  setBookMark()
  updateButtons()
end sub



'============= GET NEXT CHANNEL =========
sub getNextMediaItem()

  nextChannel = invalid

  if m.rowlist.content <> invalid and m.rowlist.content.getChildCount() > 0

    if m.col < m.rowlist.content.getChild(0).getChildCount() - 1
      m.col = m.col + 1
    else
      m.col = 0
    end if

    nextChannel = m.rowlist.content.getChild(0).getChild(m.col)

    if nextChannel <> invalid
      m.playerScreen.callFunc("stopStream")

      mediaItem = {
        name: nextChannel.name,
        itemType: nextChannel.itemType,
        playerPos: 0
      }

      m.playerScreen.callFunc("setDetails", mediaItem)
      m.autoPlay = true
      getItem(nextChannel.itemID)
    end if
  end if
end sub

'============= GET PREVIOUS CHANNEL =========
sub getPreviousMediaItem()

  previousChannel = invalid

  if m.rowlist.content <> invalid and m.rowlist.content.getChildCount() > 0

    if m.col > 0
      m.col = m.col - 1
    else
      m.col = m.rowlist.content.getChild(0).getChildCount() - 1
    end if

    previousChannel = m.rowlist.content.getChild(0).getChild(m.col)

    if previousChannel <> invalid
      m.playerScreen.callFunc("stopStream")

      mediaItem = {
        name: previousChannel.name,
        itemType: previousChannel.itemType,
        playerPos: 0
      }

      m.playerScreen.callFunc("setDetails", mediaItem)
      m.autoPlay = true
      getItem(previousChannel.itemID)
    end if
  end if
end sub


'//////////////////////
'///// API CALLS
'/////////////////////'

'=========== GET ITEM ============
sub getItem(itemID as object)

  m.loadingIndicator.visible = true
  m.loadingIndicator.control = "start"

  apiUrl = getGlobal("apiUrl")
  countryCode = getCountryCode()

  apiController = apiController(apiUrl, countryCode)
  apiController.getMediaItem(itemID, "onGetMediaItem")
end sub

'============ ON GET MEDIA ITEM ==========
function onGetMediaItem(pEvent as dynamic) as boolean
  m.loadingIndicator.visible = false
  m.loadingIndicator.control = "stop"

  response = pEvent.getData()

  if response.data <> invalid

    itemDetails = m.rowlist.content.getChild(m.row).getChild(m.col)

    tempName = m.nameLbl.text
    m.nameLbl.text = itemDetails.name
    itemDetails.name = tempName

    tempDescription = m.descriptionLbl.text
    m.descriptionLbl.text = itemDetails.description
    itemDetails.description = tempDescription

    tempLandscapeImgLow = m.landscapeImgLow.uri
    m.landscapeImgLow.uri = itemDetails.landscapeImgLow
    itemDetails.landscapeImgLow = tempLandscapeImgLow

    tempLandscapeImgHigh = m.landscapeImgHigh.uri
    m.landscapeImgHigh.uri = itemDetails.landscapeImgHigh
    itemDetails.landscapeImgHigh = tempLandscapeImgHigh

    tempPortraitImg = m.portraitImg
    m.portraitImg = itemDetails.portraitImg
    itemDetails.portraitImg = tempPortraitImg

    tempItemID = m.itemID
    m.itemID = itemDetails.itemID
    itemDetails.itemID = tempItemID

    tempItemType = m.itemType
    m.itemType = itemDetails.itemType
    itemDetails.itemType = tempItemType

    m.duration = response.data.duration
    
    m.bifUrl = response.data.bif

    prerrolAdUrl = ""

    if response.data.preroll_ad <> invalid
        m.prerrolAdUrl = response.data.preroll_ad
    end if 

    if response.data.midroll_ad <> invalid
        m.midrollAdUrl = response.data.midroll_ad
    end if


    m.mediaSource = response.data.media_item_source
    m.playBtn.setFocus(true)

    m.isFavorite = false
    m.playerPos = 0

    initButtons()
    getBookmarkItem()

    if m.autoPlay
      playMediaItem()
    end if

  else

  end if

end function



'//////////////////////
'///// REGISTRY
'/////////////////////'

sub setBookMark()

  itemObj = {
    itemID: m.itemID,
    name: m.nameLbl.text,
    description: m.descriptionLbl.text,
    playerPos: m.playerPos,
    isFavorite: m.isFavorite,
    landscapeImgLow: m.landscapeImgLow.uri,
    landscapeImgHigh: m.landscapeImgHigh.uri,
    portraitImg: m.portraitImg,
    itemType: m.itemType
  }

  bookMark = bookMark()
  m.bookmarkData = bookMark.setBookmark(itemObj, m.bookmarkData)

  'print "m.bookmarkData "; m.bookmarkData
  regController = regController()
  regController.regWrite("bookmark", FormatJSON(m.bookmarkData), "")

  'regController.regWrite("bookmark", "", "")
end sub


'============== GET BOOKMARK ITEMS =============='
function getBookMarkItems()
  print "getBookMarkItems"
  regController = regController()
  regController.regRead("bookmark", "onGetBookMarkItems")
end function


'============= ON GET BOOKMARK ITEM ==========='
sub onGetBookMarkItems(pEvent as dynamic)
  response = pEvent.getData()

  'print "response " ;response

  if response.data <> invalid and response.data <> ""
    m.bookmarkData = ParseJSON(response.data)
    getBookmarkItem()
  end if
end sub

'=============== GET BOOKMARK ITEM ============='
sub getBookmarkItem()

  bookMark = bookMark()
  itemObj = bookMark.getBookmarkItem(m.itemID, m.bookmarkData)

  if itemObj <> invalid
    m.isFavorite = itemObj.isFavorite
    m.playerPos = itemObj.playerPos
    updateButtons()
  end if
end sub

'============== CLEAR BOOKMARK =========='
sub clearBookmark()
  bookMark = bookMark()
  m.bookmarkData = bookMark.clearBookmark(m.itemID, m.bookmarkData)
  regController = regController()
  regController.regWrite("bookmark", FormatJSON(m.bookmarkData), "")
end sub


'//////////////////////
'///// EVENTS HANDLER
'/////////////////////'
function onKeyEvent(key as string, press as boolean) as boolean
  'print "onKeyEvent detailsScreen ";key;" "; press

  if press

    if key = "back"

      m.top.getParent().callFunc("closeDetailsScreen")
      return true

    else if key = "OK"


      return true

    else if key = "left"
      if m.nodeIndex > 0
        m.nodeIndex = m.nodeIndex - 1
        setFocus()
      end if

      return true

    else if key = "right"

      if m.nodeIndex < m.buttonsCount - 1
        m.nodeIndex = m.nodeIndex + 1
        setFocus()
      end if

      return true

    else if key = "down"

      if m.rowlist.visible
        m.rowlist.setFocus(true)
      end if

      return true

    else if key = "up"
      setFocus()
      return true

    end if
  end if 'press'

  return false

end function