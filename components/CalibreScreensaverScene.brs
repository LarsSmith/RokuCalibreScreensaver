function init()
    print "CalibreScreensaverScene: init() called"

    ' Find the Screensaver child node
    m.screensaver = m.top.findNode("Screensaver")

    ' Observe the coverInitializationPending field on the Screensaver child
    if m.screensaver <> invalid
        m.screensaver.observeField("coverInitializationPending", "onCoverInitializationComplete")
    else
        print "CalibreScreensaverScene: Screensaver node not found"
    end if
end function

function onCoverInitializationComplete()
    if m.screensaver.coverInitializationPending = false
        ' Emit the onSceneLoaded event
        m.top.onSceneLoaded = true
        print "CalibreScreensaverScene: cover initialization complete. Attempting to send AppLaunchComplete signalBeacon."
        m.top.signalBeacon("AppLaunchComplete")
    end if
end function