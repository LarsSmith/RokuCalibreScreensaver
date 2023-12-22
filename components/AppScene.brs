function init()
    m.mode = "screensaver"
    m.screenSaver = m.top.findNode("Screensaver")
    m.screenSaver.setFocus(true)
end function


function onKeyEvent(key as String, press as Boolean) as Boolean
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
