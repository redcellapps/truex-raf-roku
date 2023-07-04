'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 25/05/2021 by Igor Malasevschi

sub main(args as Dynamic)
    '//MARK: -'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.global = screen.getGlobalNode()

   
    '//MARK : - add deep linking feature'
    if (args.contentId <> invalid) and (args.mediaType <> invalid)
         m.global.addFields({deepContentId : args.contentId})
         m.global.addFields({deepMediaType : args.mediaType})
    end if

    '//MARK : -Create a scene and load /components/mainScene.xml'
    scene = screen.CreateScene("mainScene")
    screen.show()
    scene.observeField("exitApp", m.port)
    scene.signalBeacon("AppLaunchComplete")
    scene.setFocus(true)

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
            field = msg.getField()
            if field = "exitApp" then
                return
            end if
        end if
    end while
end sub


