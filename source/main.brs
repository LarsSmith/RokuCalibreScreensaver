'TODO make it also a channel with UI choices
'TODO add options for sort by title, sort by author 

function Main() as void
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    scene = screen.createScene("CalibreScreensaver") 'Creates scene CalibreScreensaver
    screen.show()

    scene.observeField("showSettingsFlag", port)
    scene.setFocus(true)
    
    print "testing access to scene member showSettingsFlag"
    print scene.showSettingsFlag.ToStr()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            print "msg received. type: " + msgType
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then exit while
            else if msgType = "roSGNodeEvent" AND msg.getField() = "showSettingsFlag" AND msg.getData() = true
                print "roSGNodeEvent received "
                print "node: " + msg.getNode()
                print "field name: " + msg.getField()
                print "data: " + msg.getData().ToStr()
                'scene.findNode(msg.getNode()).height = 400
                print "shut down and show settings scene"
                RunScreenSaverSettings()
                scene.showSettingsFlag = false

                'scene.init()
            end if
        end if
    end while
end function

sub RunScreenSaver()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    screen.createScene("CalibreScreensaver") 'Creates scene CalibreScreensavers
    screen.show()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then exit while
            end if
        end if
    end while
end sub

sub RunScreenSaverSettings()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    screen.createScene("CalibreScreensaverSettings")
    screen.show()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then exit while
            end if
        end if
    end while
end sub