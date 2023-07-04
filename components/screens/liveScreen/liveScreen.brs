'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 31/05/2021 by Igor Malasevschi

sub init()

  m.rowList = m.top.findNode("rowList")
  m.rowList.observeField("rowItemFocused", "onRowItemFocused")
  m.rowList.observeField("rowItemSelected", "onRowItemSelected")
  m.detailsScreen = m.top.findNode("detailsScreen")
  m.nameLbl = m.top.findNode("nameLbl")
  m.nameLbl.font.size = 50
  m.descriptionLbl = m.top.findNode("descriptionLbl")
  m.landscapeImgLow = m.top.findNode("landscapeImgLow")
  m.landscapeImgHigh = m.top.findNode("landscapeImgHigh")
  m.layersViewData = CreateObject("roArray", 0, true)
  m.loadingIndicator = m.top.findNode("loadingIndicator")
  m.messageScreen = m.top.findNode("messageScreen")
end sub

'========== INIT MOVIE SCREEN ============
sub initLiveTVScreen()
  m.nameLbl.text = ""
  m.descriptionLbl.text = ""
  m.rowlist.visible = false
  m.landscapeImgLow.uri = ""
  m.landscapeImgHigh.uri = ""
  m.messageScreen.visible = false
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
  setFocus()
end sub

'=========== SET FOCUS ============'
function setFocus() as boolean
  m.top.setFocus(m.top.focus)
  m.rowList.setFocus(m.top.focus)
end function

'============= ON ROW ITEM FOCUSED ============================
sub onRowItemFocused()
  col = m.rowlist.rowItemFocused[1]
  row = m.rowlist.rowItemFocused[0]

  itemDetails = m.rowlist.content.getChild(row).getChild(col)
  setItemDetails(itemDetails)
end sub

'============= ON ROW ITEM SELECTED ============================
sub onRowItemSelected()

  m.col = m.rowlist.rowItemFocused[1]
  m.row = m.rowlist.rowItemFocused[0]

  itemDetails = m.rowlist.content.getChild(m.row).getChild(m.col)
  getItem(itemDetails)
end sub

'=========== SET ITEM DETAILS ========='
sub setItemDetails(itemDetails as object)
  m.landscapeImgHigh.uri = ""

  if itemDetails.name <> invalid
    m.nameLbl.text = itemDetails.name
  end if

  if itemDetails.description <> invalid
    m.descriptionLbl.text = itemDetails.description
  end if

  if itemDetails.landscapeImgLow <> invalid
    m.landscapeImgLow.uri = itemDetails.landscapeImgLow
  end if

  if itemDetails.landscapeImgHigh <> invalid
    m.landscapeImgHigh.uri = itemDetails.landscapeImgHigh
  end if
end sub

'========== CLOSE DETAILS SCREEN ============
sub closeDetailsScreen()
  m.top.getParent().callFunc("showMenu")
  m.detailsScreen.visible = false

  if m.layersViewData.count() > 0
    initLiveTVScreen()
    layerObj = m.layersViewData.Pop()
    m.rowlist.content = layerObj.content
    m.rowlist.jumpToRowItem = [layerObj.row, layerObj.col]
    m.rowlist.visible = true
  end if
  setFocus()
end sub

'============= GET SELECTED CATEGORY ============='
function getSelectedCategory(index as integer) as object
  category = m.rowlist.content.getChild(index)
  return category
end function


'=========== SET ROW LIST CONTENT ============='
sub setRowListContent(categoriesData as object)
  data = CreateObject("roSGNode", "ContentNode")

  for each category in categoriesData
    if category.items.count() > 0
      row = data.CreateChild("ContentNode")
      row.title = category.name

      for each item in category.items
        itemRow = row.CreateChild("itemData")
        itemRow.categoryID = category.id
        itemRow.itemID = item.id
        itemRow.name = item.name
        itemRow.itemType = item.itemType
        itemRow.description = item.description
        itemRow.portraitImg = item.portraitImg
        itemRow.landscapeImgLow = item.landscapeImgLow
        itemRow.landscapeImgHigh = item.landscapeImgHigh
      end for
    end if
  end for

  m.rowlist.content = data
  m.rowList.visible = true
  m.rowList.setFocus(true)

  itemsCount = m.rowlist.content.getChildCount()
  if itemsCount = 0
    displayErrorMessage(m.global.noItemsError)
  end if
end sub


'========= DISPLAY ERROR MESSAGE ==================='
sub displayErrorMessage(message as object)

  params = {
    errorMessage: message
  }

  m.messageScreen.callFunc("displayErrorMessage", params)
  m.messageScreen.visible = true
end sub

'//////////////////////
'///// API CALLS
'/////////////////////'

'=============== GET LIVETV =========='
sub getLiveTV()
  m.loadingIndicator.visible = true
  m.loadingIndicator.control = "start"

  m.layersViewData.clear()
  initLiveTVScreen()

  apiUrl = getGlobal("apiUrl")
  countryCode = getCountryCode()
  platform = getGlobal("platform")

  m.apiController = apiController(apiUrl, countryCode)
  m.apiController.getLiveTV(platform, "onGetLiveTV")
end sub


'============== ON GET LIVETV ===========
function onGetLiveTV(pEvent as dynamic) as boolean

  m.loadingIndicator.visible = false
  m.loadingIndicator.control = "stop"

  response = pEvent.getData()

  if response.data <> invalid and response.data.items <> invalid

    'print "response.data "; response.data
    categoriesData = []
    fetchCategories(categoriesData, response.data)
    setRowListContent(categoriesData)
    m.top.getParent().callFunc("closeLoadingScreen")

  else
    displayErrorMessage(m.global.apiGenericError)
  end if

end function


'=========== GET ITEM ============
sub getItem(itemDetails as object)

  m.loadingIndicator.visible = true
  m.loadingIndicator.control = "start"

  layerObj = {
    content: m.rowlist.content,
    row: m.row,
    col: m.col
  }

  m.layersViewData.push(layerObj)

  initLiveTVScreen()
  'print "category "; m.category

  if itemDetails.itemType = "category"
    m.apiController.getCategory(itemDetails.itemID, "onGetCategory")
  else
    m.apiController.getMediaItem(itemDetails.itemID, "onGetMediaItem")
  end if
end sub

function onGetMediaItem(pEvent as dynamic) as boolean
  m.loadingIndicator.visible = false
  m.loadingIndicator.control = "stop"

  response = pEvent.getData()

  if response.data <> invalid

    portraitImg = getDefaultPortraitImg()
    landscapeImgLow = getDefaultLandscapeImg()
    landscapeImgHigh = getDefaultLandscapeImg()

    if response.data.img_portrait <> invalid and response.data.img_portrait <> ""
      portraitImg = response.data.img_portrait
    end if

    if response.data.img_landscape <> invalid
      if response.data.img_landscape.low <> invalid
        landscapeImgLow = response.data.img_landscape.low
      end if

      if response.data.img_landscape.high <> invalid
        landscapeImgHigh = response.data.img_landscape.high
      end if
    end if

     prerrolAdUrl = ""

     if response.data.preroll_ad <> invalid
        prerrolAdUrl = response.data.preroll_ad
    end if 
  
    detailsObj = {
      name: response.data.name,
      description: response.data.long_description,
      portraitImg: portraitImg,
      landscapeImgLow: landscapeImgLow,
      landscapeImgHigh: landscapeImgHigh,
      mediaSource: response.data.media_item_source,
      itemType: response.data.type,
      itemID: response.data.id,
      categoryData: m.rowlist.content,
      duration: 0,
      bifUrl: "",
      prerrolAdUrl: prerrolAdUrl,
      midrollAdUrl: ""
    }

    m.top.getParent().callFunc("hideMenu")

    m.detailsScreen.callFunc("setDetails", detailsObj)
    m.detailsScreen.visible = true
    m.detailsScreen.focus = true
  else
    displayErrorMessage(m.global.apiGenericError)
  end if
end function


function onGetCategory(pEvent as dynamic) as boolean
  m.loadingIndicator.visible = false
  m.loadingIndicator.control = "stop"

  response = pEvent.getData()

  if response.data <> invalid and response.data.items <> invalid
    categoriesData = []
    fetchCategories(categoriesData, response.data)
    setRowListContent(categoriesData)
  else
    displayErrorMessage(m.global.apiGenericError)
  end if

end function



'//////////////////////
'///// EVENTS HANDLER
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
  print "onKeyEvent liveScreen ";key;" "; press

  if press

    if key = "back"

      if m.layersViewData.count() > 0
        initLiveTVScreen()
        layerObj = m.layersViewData.Pop()
        m.rowlist.content = layerObj.content
        m.rowlist.visible = true
        m.rowlist.jumpToRowItem = [layerObj.row, layerObj.col]
        return true
      end if

      m.top.getParent().callFunc("showMenu")
      return true

    else if key = "OK"


      return true

    else if key = "left"
      m.top.getParent().callFunc("showMenu")

      return true

    else if key = "right"

      return true

    else if key = "down"

      return true

    else if key = "up"
      return true

    end if
  end if 'press'

  return false

end function