' This is the main entry point for the screensaver
sub RunScreenSaver() as void
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    scene = screen.createScene("CalibreScreensaverScene")
    screen.show()

    while true
        msg = wait(0, port)
        if msg <> invalid
            print "Message received: "; type(msg)
            if type(msg) = "roSGScreenEvent"
                print "roSGScreenEvent received: "; msg.getEvent()
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

    while true
        msg = wait(0, port)
        if msg <> invalid
            if type(msg) = "roSGScreenEvent"
                print "roSGScreenEvent received: "; msg.getEvent()
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub