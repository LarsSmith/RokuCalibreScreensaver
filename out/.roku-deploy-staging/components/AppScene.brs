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
            m.top.removeChildIndex(0)
            m.top.createChild("CalibreScreensaverSettings")
            handled = true
        end if
    end if
    return handled
end function
