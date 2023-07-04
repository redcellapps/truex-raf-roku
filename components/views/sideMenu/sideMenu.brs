'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi

sub init()
    m.iconList = m.top.findNode("iconList")
    m.menuList = m.top.findNode("menuList")
    m.menuList.ObserveField("rowItemSelected", "onItemSelected")
    m.showAnimation = m.top.FindNode("showAnimation")
    m.hideAnimation = m.top.FindNode("hideAnimation")
    m.focusTimer = m.top.FindNode("focusTimer")
    m.focusTimer.ObserveField("fire", "updateFocus")
    m.bigOverlay = m.top.FindNode("bigOverlay")
    m.lastRow = 0
end sub

'====== ON TTEM SELECTED =================='
sub onItemSelected()
    lastIconItem = m.iconList.content.getChild(m.lastRow).getChild(0)
    lastIconItem.selected = false

    selectedRow = m.menuList.rowItemSelected[0]
    m.lastRow = selectedRow

    newIconItem = m.iconList.content.getChild(selectedRow).getChild(0)
    newIconItem.selected = true

    newMenuItem = m.menuList.content.getChild(selectedRow).getChild(0)
    m.top.getParent().callFunc("setAction", newMenuItem)
end sub

'================ SET MENU CONTENT ==============='
function getSelectedItem() as object

    itemsCount = m.menuList.content.getChildCount()
    item = invalid

    itemIndex = -1

    for i = 0 to itemsCount - 1 step 1
        item = m.menuList.content.getChild(i).getChild(0)
        if item.selected
            m.lastRow = i
            return item
        end if
    end for

    return item
end function

'================ SET MENU CONTENT ==============='
function setMenuContent(params as object) as object

    data = CreateObject("roSGNode", "ContentNode")

    for each item in params.menuContent.items

        if item.visible
            row = data.CreateChild("ContentNode")
            menuItem = row.CreateChild("menuListContent")
            menuItem.posterUrl = item.imgUrl
            menuItem.name = item.name
            menuItem.actionTarget = item.actionTarget
            menuItem.id = item.id
            menuItem.selected = item.selected
        end if
    end for

    m.iconList.content = data
    m.menuList.content = data
end function

'=========== SET FOCUS ============'
sub setFocus()
    m.top.setFocus(m.top.focus)
end sub

'========= ON GET FOCUS =========
sub onGetFocus()
    setFocus()
end sub

'======= SHOW MENU ==============
sub showMenu()

    if m.menuList.hasFocus() = false and m.showAnimation.state <> "running" and m.hideAnimation.state <> "running"
        m.showAnimation.repeat = false
        m.showAnimation.control = "start"
        m.focusTimer.control = "start"
        m.menuList.jumpToRowItem = [m.lastRow, 0]
    end if
end sub

'======== HIDE MENU =============
sub hideMenu()

    m.showAnimation.control = "stop"

    if m.menuList.hasFocus() = true and m.hideAnimation.state <> "running"
        m.hideAnimation.repeat = false
        m.hideAnimation.control = "start"
    end if
end sub

'========= UPDATE FOCUS =========='
sub updateFocus()
    m.menuList.setFocus(true)
end sub


'//////////////////////
'///// EVENT HANDLERS
'/////////////////////'

function onKeyEvent(key as string, press as boolean) as boolean
    'print "[onKeyEvent topMenu ";key;" "; press; "]"

    handled = false

    if press
        if key = "back"
        else if key = "OK"
        else if key = "left"
        else if key = "right"
        else if key = "down"
        else if key = "up"
        else if key = "options"
        end if
    end if 'press'

    return handled
end function