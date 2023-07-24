'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 26/05/2021 by Igor Malasevschi


Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithRAF"
end sub

function getAdUrl(midroll as boolean) as string
    adUrl = m.top.prerrolAdUrl
    inventoryType = "pre"

    if midroll
        adUrl = m.top.midrollAdUrl
        inventoryType = "mid"
    end if

    adUrl = adUrl.Replace("[content_id]", m.top.contentID.toStr())
    adUrl = adUrl.Replace("[content_title]", m.top.name.escape())
    adUrl = adUrl.Replace("[content_category]", "Movies")
    adUrl = adUrl.Replace("[content_genre]", "Action Documentary Comedy Fantasy Romance".Escape())
    adUrl = adUrl.Replace("[content_duration]", m.top.duration.toStr())
    adUrl = adUrl.Replace("[ip]", getIpAddress())
    adUrl = adUrl.Replace("[inventory_type]", inventoryType)

    return adUrl
end function

'============= PLAY CONTENT WITH RAF =========='
sub playContentWithRAF()
    '//Set 24h duration for live'
    if m.top.duration = 0
        m.top.duration = 86400
    end if 

    adUrl = getAdUrl(false)

    adIface = Roku_Ads() 'RAF initialize
    print "Roku_Ads library version: " + adIface.getLibVersion()

    adIface.setDebugOutput(false) 'for debug pupropse
    adIface.setAdUrl(adUrl)

    'for generic measurements api
    adIface.enableAdMeasurements(true)

    adIface.setContentGenre("Action, Documentary, Comedy, Fantasy, Romance", false) ' if unset, ContentNode has it as []
    


    adIface.setContentLength(m.top.duration)
    adIface.setContentId(m.top.contentID.toStr())

    'Indicates whether the default Roku backfill ad service URL
    'should be used in case the client-configured URL fails (2 retries)
    'to return any renderable ads.
    adIface.setAdPrefs(false)
    'adIface.setAdExit(false)

    'Normally, would set publisher's ad URL here.  Uncomment following line to do so.
    'adIface.setAdUrl(m.videoContent.adUrl)
    'Otherwise uses default Roku ad server (with single preroll placeholder ad)

    'Returns available ad pod(s) scheduled for rendering or invalid, if none are available.
    adPods = adIface.getAds()

    m.top.keepPlaying = true
    'render pre-roll ads
    renderView = m.top.video.getParent()
    video = m.top.video

    if adPods <> invalid and adPods.count() > 0 then
        ?"****** rafIntegration ****** playContentWithRAF() -----> adPods: "; adPods
        m.top.keepPlaying = adIface.showAds(adPods, invalid, renderView)
    end if

    ?"****** rafIntegration ****** playContentWithRAF() -----> adPods: "; adPods
    ?"****** rafIntegration ****** playContentWithRAF() -----> adPods: "; adPods
    
    port = CreateObject("roMessagePort")

    if m.top.keepPlaying then
        video.observeField("position", port)
        video.observeField("state", port)

        if m.top.seekPos > 0
            video.seek = m.top.seekPos
        end if

        video.control = "play"
        renderView.focus = true
    end if


    playerPos = 0
    isPlayingPostroll = false
       
    while m.top.keepPlaying
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            if msg.GetField() = "position" then
                ' keep track of where we reached in content
                playerPosition = msg.GetData()

                if m.top.displayPrerollAd
                    m.top.displayPrerollAd = false
                    adUrl = getAdUrl(true)
                    adIface.setAdUrl(adUrl)
                    adPods = adIface.getAds()

                    if adPods <> invalid and adPods.count() > 0
                        print "PlayerTask: mid-roll ads, stopping video"
                        'ask the video to stop - the rest is handled in the state=stopped event below
                        video.control = "stop"
                    end if
                    stop
                end if


            else if msg.GetField() = "state" then
                curState = msg.GetData()
                print "PlayerTask: state = "; curState

                if curState = "stopped" then

                    if adPods = invalid or adPods.count() = 0  or isPlayingPostroll or m.top.keepPlaying = false then
                        exit while
                    end if

                    print "PlayerTask: playing midroll/postroll ads"
                    m.top.keepPlaying = adIface.showAds(adPods, invalid, renderView)

                   
                    if m.top.keepPlaying then
                        print "PlayerTask: mid-roll finished, seek to "; stri(playerPosition)
                        video.visible = true
                        video.seek = playerPosition
                        video.control = "play"
                        renderView.focus = true
                    end if

                else if curState = "finished" then
                    print "PlayerTask: main content finished"
                    ' render post-roll ads
                    adPods = adIface.getAds(msg)
                    if adPods = invalid or adPods.count() = 0 then
                        exit while
                    end if
                    print "PlayerTask: has postroll ads"
                    isPlayingPostroll = true
                    ' stop the video, the post-roll would show when the state changes to  "stopped" (above)
                    video.control = "stop"
                end if
            end if
            stop

        end if
    end while

    print "PlayerTask: exiting playContentWithAds()"
end sub
