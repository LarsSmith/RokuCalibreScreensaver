function init()
    m.mode = "screensaver"
    m.screenSaver = m.top.findNode("Screensaver")
    m.screenSaver.setFocus(true)

    ' Observe key events
    m.top.observeField("keyEvent", "onKeyEventHandler")
end function

function onKeyEventHandler(event as Object)
    key = event.key
    press = event.isPressed
    handled = false

    if press then
        if key = "options" and m.mode = "screensaver" then
            print "options key pressed"
            m.screenSaver.visible = false
            m.top.removeChild(m.screenSaver)
            m.screenSaver = invalid
            m.top.backExitsScene = false
            m.settings = m.top.createChild("CalibreScreensaverSettings")
            m.settings.setFocus(true)
            m.mode = "settings"
            handled = true
        else if key = "back" and m.mode = "settings" then
            print "returning to screensaver"
            m.settings.visible = false
            m.top.removeChild(m.settings)
            m.settings = invalid
            m.top.backExitsScene = true
            m.screenSaver = m.top.createChild("CalibreScreensaver")
            m.screenSaver.setFocus(true)
            m.mode = "screensaver"
            handled = true
        end if
    end if

    return handled
end function
