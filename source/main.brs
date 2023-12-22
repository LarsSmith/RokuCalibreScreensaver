sub RunScreenSaver()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    screen.createScene("CalibreScreensaver") 'Creates scene ScreensaverFade
    screen.show()

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

sub RunScreenSaverSettings()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    screen.createScene("CalibreScreensaverSettingsScene")
    screen.show()

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