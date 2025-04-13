' This is the main entry point for the screensaver
sub RunScreenSaver() as void
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    scene = screen.createScene("CalibreScreensaverScene")
    screen.show()
    scene.signalBeacon("AppLaunchComplete")

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub

' This is the main entry point for the screensaver settings
sub RunScreenSaverSettings()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    scene = screen.createScene("CalibreScreensaverSettingsScene")
    screen.show()
    scene.signalBeacon("AppLaunchComplete")

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub