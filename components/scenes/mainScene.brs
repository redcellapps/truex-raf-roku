'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 25/05/2021 by Igor Malasevschi

sub init()
    m.sideMenu = m.top.findNode("sideMenu")
    m.messageScreen = m.top.findNode("messageScreen")
    m.favoritesScreen = m.top.findNode("favoritesScreen")
    m.movieScreen = m.top.findNode("movieScreen")
    m.liveScreen = m.top.findNode("liveScreen")
    m.radioScreen = m.top.findNode("radioScreen")
    m.guideScreen = m.top.findNode("guideScreen")
    m.loadingScreen = m.top.findNode("loadingScreen")
    m.popupView = m.top.findNode("popupView")
    m.playerScreen = m.top.findNode("playerScreen")

    initLocalization()
    getConfigData()

     '//MARK : -DeepLinking Events'
    m.deeplLinkScreen = m.top.findNode("deeplLinkScreen")
    m.deepLinkingTask = createObject("roSgNode", "deepLinkingTask")
    m.deepLinkingTask.observefield("deeplinkData", "handleDeepLinkEvents")
    m.deepLinkingTask.control = "run"
end sub


'============ HANDLE DEEP LINK EVENTS ============='
sub handleDeepLinkEvents(pEvent as dynamic)
    deeplinkData = pEvent.getData()
    if deeplinkData <> invalid and deeplinkData.deepMediaType <> invalid and deeplinkData.deepContentId <> invalid
        m.deeplLinkScreen.callFunc("getItem", deeplinkData)
        m.deeplLinkScreen.visible = true
    else
        displayErrorMessage(m.global.deepLinkError)
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


'=========== GET CONFIG DATA ==============='
sub getConfigData()
    displayLoadigScreen()

    m.configController = configController()
    m.configController.getConfigFile("onGeconfigFile")
end sub

'========== ON GET CONFIG DATA ==========
sub onGeconfigFile(pEvent as dynamic)
    print "onGeconfigFile"

    response = pEvent.getData()

    if response <> invalid
        pData = ParseJson(response.data)
        setMenuContent(pData)
        setConfigGlobalData(pData)
        completeInitView()
    else
        '//MARK: - error message
        displayErrorMessage(m.global.configGenericError)
    end if

    m.configController = invalid

end sub


'========== SET CONFIG DATA  ===========
sub setConfigGlobalData(pData as object)
    setGlobal("host", pData.settings.host)
    setGlobal("apiUrl", pData.settings.apiUrl)
    setGlobal("platform", pData.settings.platform)
    setGlobal("midrollInterval", pData.ads.midrollInterval)
end sub

'=========== COMPLETE INVIT VIEW ============'
function completeInitView() as boolean

    if m.global.deepContentId <> invalid and m.global.deepMediaType <> invalid
        closeLoadingScreen()
        deeplinkData = {
            deepContentId: m.global.deepContentId,
            deepMediaType: m.global.deepMediaType
        }
        
        m.deeplLinkScreen.callFunc("getItem", deeplinkData)
        m.deeplLinkScreen.visible = true
        return true
    end if 

    selectMenuItem()
    
    return true
end function


'========== SELECT MENU ITEM ============'
sub selectMenuItem()
    item = m.sideMenu.callFunc("getSelectedItem")

    if item <> invalid
        setAction(item)
    end if

end sub

'========= SET MENU CONTENT ========='
sub setMenuContent(pData as object)
    m.sideMenu.callFunc("setMenuContent", pData)
    m.sideMenu.visible = true
end sub

'========= SET FOCUS '=========
sub setFocus()
    disableScreensFocus()

    if m.favoritesScreen.visible
        m.favoritesScreen.focus = true
    else if m.movieScreen.visible
        m.movieScreen.focus = true
    else if m.liveScreen.visible
        m.liveScreen.focus = true
    else if m.guideScreen.visible
        m.guideScreen.focus = true
    else if m.radioScreen.visible
        m.radioScreen.focus = true
    else
        m.top.setFocus(true)
    end if
end sub



'========= CLOSE VIEWS '=========
sub closeViews()
    disableScreensFocus()

    m.favoritesScreen.visible = false
    m.movieScreen.visible = false
    m.liveScreen.visible = false
    m.guideScreen.visible = false
    m.radioScreen.visible = false
end sub


'========= SET ACTION '=========
sub setAction(data as object)

    closeViews()

    m.sideMenu.callFunc("hideMenu")

    if data.actionTarget = "favorites"
        getFavoritesScreen()
    else if data.actionTarget = "movies"
        getMoviesScreen()
    else if data.actionTarget = "live"
        getLiveScreen()
    else if data.actionTarget = "guide"
        getGuideScreen()
    else if data.actionTarget = "radio"
        getRadioScreen()
    else
        m.top.setFocus(true)
    end if
end sub



'========= GET FAVORITES SCREEN ==================='
sub getFavoritesScreen()
    m.favoritesScreen.visible = true
    m.favoritesScreen.focus = true
    m.favoritesScreen.callFunc("getFavorites")
end sub

'========= GET MOVIES SCREEN ==================='
sub getMoviesScreen()
    m.movieScreen.visible = true
    m.movieScreen.focus = true
    m.movieScreen.callFunc("getCategories")
end sub

'========= GET LIVE SCREEN ==================='
sub getLiveScreen()
    m.liveScreen.visible = true
    m.liveScreen.focus = true
    m.liveScreen.callFunc("getLiveTV")
end sub

'========= GET GUIDE SCREEN ==================='
sub getGuideScreen()
    m.guideScreen.visible = true
    m.guideScreen.focus = true
end sub


'========= GET RADIO SCREEN ==================='
sub getRadioScreen()
    m.radioScreen.visible = true
    m.radioScreen.focus = true
    m.radioScreen.callFunc("getRadios")
end sub

'========= DISABLE SCREEN FOCUS ========'
sub disableScreensFocus()
    m.favoritesScreen.focus = false
    m.movieScreen.focus = false
    m.liveScreen.focus = false
    m.guideScreen.focus = false
    m.radioScreen.focus = false
end sub

'============== SHOW MENU ==============='
sub showMenu()
    if m.sideMenu.visible = false
        m.sideMenu.visible = true
        return
    end if
    m.sideMenu.callFunc("showMenu")
    m.sideMenu.focus = true
end sub

'============== HIDE MENU ==============='
sub hideMenu()
    m.sideMenu.visible = false
end sub



'========== DISPLAY LOADING SCREEN ======
sub displayLoadigScreen()
    m.loadingScreen.visible = true
    m.loadingScreen.control = "start"
end sub

'======= HIDE LOGIN SCREEN =============='
function closeLoadingScreen()
    m.loadingScreen.visible = false
    m.loadingScreen.control = "stop"
end function

'================ QUIT APPLICATION ==========='
sub quitApplication()
    m.sideMenu.callFunc("hideMenu")

    params = {
        title: m.global.closeTitle,
        unpairDevice: false
    }
    m.popupView.callFunc("displayPopup", params)
    m.popupView.focus = true
    m.popupView.visible = true

end sub

'======= CLOSE POPUP SCREEN =============
sub closePopupScreen(params as object)

    if params.close
        m.top.exitApp = true
    else
        m.popupView.visible = false
        setFocus()
    end if
end sub


'========== CLOSE DEEP LINK SCREEN ========='
sub closeDeepLinkScreen()
    m.deeplLinkScreen.visible = false
    selectMenuItem()

end sub

'//////////////////////
'///// EVENTS HANDLER
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
    'print "[onKeyEvent MAIN ";key;" "; press; "]"
    handled = false
    if press
        if key = "back"

             if m.deeplLinkScreen.visible
                m.deeplLinkScreen.visible = false
                m.global.deepContentId = invalid 
                m.global.deepMediaType = invalid
                selectMenuItem()
                return true
            end if


            if m.messageScreen.visible
                m.top.exitApp = true
                return true
            end if

            quitApplication()
            return true

        else if key = "OK"

            handled = true

        else if key = "left"

            if m.sideMenu.focus = false
                m.sideMenu.callFunc("showMenu")
                m.sideMenu.focus = true
            end if

            handled = true

        else if key = "right"
            m.sideMenu.callFunc("hideMenu")
            setFocus()
            handled = true

        else if key = "down"


            handled = true

        else if key = "up"

            handled = true
        end if
    end if 'press'

    return handled
end function