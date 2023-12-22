'update readme
'TODO add background image options

function init()
    m.top.getScene().backgroundURI = "pkg:/images/gradient.png"
    
    m.LoadingDialog = m.top.findNode("LoadingDialog")
    m.LoadingDialog.title = Tr("Loading Covers")
    m.LoadingDialog.message = Tr("Depends on how many books you have in your library…")

    'Load cover height from registry
    m.BookCoverSize = GetRegistryBookCoverSize()
    m.COVER_HEIGHT = ConvertBookCoverSizeToPixels(m.BookCoverSize)
    m.TOP_PADDING = (1080 - m.COVER_HEIGHT) / 2
    m.COVER_PADDING = 20

    'Create the structure to hold the covers
    m.CoverRow = m.top.findNode("CoverRow")
    m.CoverRow.itemSpacings = [m.COVER_PADDING]
    m.CoverRow.translation = [0, m.TOP_PADDING]
    m.CoverRow.addItemSpacingAfterChild = false

    'Create the animation that slides the row of covers to the left
    m.CoverRowAnimation = m.top.findNode("CoverRowAnimation")
    m.CoverRowAnimation.observeField("state", "AnimationComplete")
    m.CoverRowAnimationInterpolator = m.top.findNode("CoverRowAnimationInterpolator")

    'This pending initialization flag allows us to iterative load the cover images and only begin sliding when sufficient images are loaded to fill the screen
    m.coverInitializationPending = true

    'Read the configured scroll speed from the registry
    'The actual animation speed in seconds is set for each call to SlideCovers()
    m.ScrollSpeed = GetRegistryScrollSpeed()

    'Determine which library source is configured
    LibrarySource = GetRegistryLibrarySource()
    if LibrarySource = "server" 'TODO replace with const
        'Create the thread that will locate cover jpg files from the Calibre Content Server
        m.ServerFileTask = CreateObject("roSGNode", "ServerFileTask")
        m.ServerFileTask.serverAddress = GetRegistryLibraryAddress()
        m.ServerFileTask.loadCoverImagesTask = true
        'When the task thread is done, call OnCoverListReadyServer()
        m.ServerFileTask.observeField("loadCoverImageTaskDone", "OnCoverListReadyServer")
        'Start the thread
        m.ServerFileTask.control = "run" 
    else 'LibrarySource = "usb" or unconfigured
        'Create the thread that will locate cover jpg files on the memory card
        m.USBFileTaskTask = CreateObject("roSGNode", "USBFileTask")
        'When the task thread is done, call OnCoverListReadyUSB()
        m.USBFileTaskTask.observeField("loadCoverImageTaskDone", "OnCoverListReadyUSB")
        'Start the thread
        m.USBFileTaskTask.control = "run"
    end if
end function

function OnCoverListReadyServer() as void
    if m.ServerFileTask.coverImages.Count() = 0
        'No covers were found. Load sample covers
        LoadSampleCovers()
        return
    end if

    m.coverImages = []
    'Copy the cover URLs from the task
    for each url in m.ServerFileTask.coverImages
        m.coverImages.Push(url)
    end for
    'Done with the task
    m.ServerFileTask = invalid

    initializeCovers()
end function

function OnCoverListReadyUSB() as void
    if m.USBFileTaskTask.coverImages.Count() = 0
        'No covers were found. Load sample covers
        LoadSampleCovers()
        return
    end if

    m.coverImages = []
    'Copy the cover URLs from the task
    for each url in m.USBFileTaskTask.coverImages
        m.coverImages.Push(url)
    end for
    'Done with the task
    m.USBFileTaskTask = invalid

    initializeCovers()
end function

function LoadSampleCovers() as void
    'Create a task to load sample covers from the package
    m.SampleCoverTask = CreateObject("roSGNode", "SampleCoverTask")
    'When the task thread is done, call OnCoverListReadyServer()
    m.SampleCoverTask.observeField("loadCoverImageTaskDone", "OnSampleCoversLoaded")
    'Start the thread
    m.SampleCoverTask.control = "run" 
end function

function OnSampleCoversLoaded() as void
    m.coverImages = []
    'Copy the cover URLs from the task
    for each url in m.SampleCoverTask.coverImages
        m.coverImages.Push(url)
    end for
    'Done with the task
    m.SampleCoverTask = invalid

    'Display text indicating that sample covers were used
    DefaultCoversUsed = m.top.findNode("DefaultCoversUsed")
    DefaultCoversUsed.translation = [(1920 / 2), 95]
    DefaultCoversUsed.color = "0x00dd00ff"
    DefaultCoversUsed.text = Tr("Calibre Library was not found or had too few covers. Using sample covers. Check library and settings.")
    DefaultCoversUsed.visible = true

    initializeCovers()
end function

function initializeCovers() 
    'Hide the loading dialog that was visible from initialization of the screensaver
    LoadingDialog = m.top.findNode("LoadingDialog")
    LoadingDialog.visible = false

    'Check that the there are a sufficient number of covers
    'TODO add error handling for insufficient coverImages? Or is one cover sufficient? Not if we add no duplication logic!!
    if m.coverImages.Count() < m.CoverRow.getChildCount()  
        'Should never occur since we have sample covers
        'Need to determine how to exit a screensaver
        print "Insufficient covers! m.picture.Count() of " + m.coverImages.Count().ToStr() + " < m.CoverRow.GetChildCount() of " + m.CoverRow.getChildCount().ToStr()
    end if

    'Begin iterative addition of covers until there are enough to fill the screen and start slide animation
    AddCover()
end function

function AddCover() as void
    'Add a new cover poster to the end of the CoverRow
    cover = m.CoverRow.createChild("Poster") 
    cover.id = "Cover" + m.CoverRow.getChildCount().ToStr()
    cover.height = m.COVER_HEIGHT
    cover.loadheight = m.COVER_HEIGHT
    cover.loadDisplayMode = "scaleToFill"
    cover.loadSync = false 'while true was useful for prototyping with USB library source, server library source cannot synchronously load
    'set the cover image loaded callback
    cover.observeField("loadStatus", "OnCoverImageLoaded")

    'TODO avoid dupes -- maybe config choice to provide a sequential option? 
    'Randomly select an intended cover
    intendedCover = m.coverImages[Rnd(m.coverImages.Count()) - 1] 'Rnd generates a integer between 1 and the argument
    'Check cover against other covers in CoverRow
    if intendedCover <> invalid then
        while CheckCoverConflicts(intendedCover)  'cover conflicts
            'Pick another cover and loop until there is no conflict
            intendedCover = m.coverImages[Rnd(m.coverImages.Count() - 1)]
        end while
    else
        print "intendedCover was invalid"
        print "m.coverImages count is " + m.coverImages.Count().ToStr()
    end if
    cover.uri = intendedCover
end function

function CheckCoverConflicts(coverUri as string) as boolean
    for i = 0 to (m.CoverRow.getChildCount() - 1)
        coverRowCover = m.CoverRow.getChild(i)
        if coverRowCover <> invalid then
            if coverRowCover.uri = coverUri then return true
        end if
    end for
    return false
end function

function OnCoverImageLoaded()
    rightmostCover = m.CoverRow.getChild(m.CoverRow.getChildCount() - 1) 'Peek at end of CoverRow
    if rightmostCover.loadStatus = "ready" then 'Cover image successfully loaded
        rightmostCover.unobserveField("loadStatus")
        'Because the image may be oversized and scaled down to fit, we don't know the scaled width
        determineWidth(rightmostCover)

        'Keep adding covers until we have enough covers to fill the screen plus enough to scroll away the left-most cover
        leftmostCover = m.CoverRow.getChild(0)
        requiredWidth = 1920 + leftmostCover.width 'TODO const the screen width?
        rightEdge = 0
        for each cover in m.CoverRow.getChildren(m.CoverRow.getChildCount(), 0)
            rightEdge += m.COVER_PADDING
            rightEdge += cover.width
        end for
        if rightEdge < requiredWidth then 'Needs more covers
            AddCover()
        else if m.coverInitializationPending 'Still initializing and now has sufficient covers to begin animating
            m.coverInitializationPending = false
            SlideCovers()
        else
            'AddCover is complete and there are enough covers
        end if
    else rightmostCover.loadStatus = "failed" 'Cover image failed to load
        print "Cover failed to load: " + rightmostCover.uri
        'TODO deal with failure. Skip to try another image? Remove the old imamge from m.coverImages?
        'There seem to be transient failures and retries based on log output. So need to better understand the internal retry logic
        'Should cover images retrieved from the server be cached onto the Roku tmp: volume? This might provide resiliance but the persistence of tmp: is iffy
    end if
end function

function determineWidth(cover) as boolean 'Set the poster width based on the scaling factor used for the bitmap height
    if (cover.bitmapHeight > 0)
        cover.width = cover.bitmapWidth * (cover.height / cover.bitmapHeight)
    else
        print "determineWidth() called on zero height cover"
    end if
end function

function SlideCovers() 'Initializes the animation of the covers sliding
    'Add another cover. This might cascade to add additional covers if the leftmost cover is particularly wide 
    'TODO race condition if add cover needs to add a 2nd cover, then it's not sliding correctly
    AddCover()

    'Use the width of the leftmost cover as the amount to shift
    leftmostCover = m.CoverRow.getChild(0)
    xShift = leftmostCover.width + m.COVER_PADDING
    m.CoverRowAnimationInterpolator.keyValue = [m.CoverRow.translation, [0 - xShift, m.TOP_PADDING]]
    'Adjust the slide speed based on a general average number of covers visible
    'Assume 3 covers for cover size large, 4 covers for cover size medium, 6 covers for cover size small
    'This fixes a pseudo-bug where the width of the cover affects how quickly it slides
    if m.BookCoverSize = "small"
        leftmostCoverSizeRatio = leftmostCover.width / (1920 / 5)
    else if m.BookCoverSize = "medium"
        leftmostCoverSizeRatio = leftmostCover.width / (1920 / 4)
    else if m.BookCoverSize = "large"
        leftmostCoverSizeRatio = leftmostCover.width / (1920 / 3)
    end if
    'Now set the animation duration based on the size of the left-most cover as a ratio to 'normal size' multiplied by the configured scroll speed
    m.CoverRowAnimation.duration = leftmostCoverSizeRatio * ConvertScrollSpeedToSeconds(m.ScrollSpeed)

    m.CoverRowAnimation.control = "start"
end function

function AnimationComplete() as void
    if m.CoverRowAnimation.state <> "stopped" 
        return
    else 'Animation is complete

        'Cleanup the leftmost cover (which is now off the left edge of the screen)
        m.CoverRow.removeChildrenIndex(1, 0) 'remove 1 child starting at index 0
        'And re-align the row with the left edge of the screen
        m.CoverRow.translation = [0, m.TOP_PADDING]

        'And restart the sliding animation
        SlideCovers()
    end if
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "right" then
            if m.CoverRowAnimation.state = "running" 
                m.CoverRowAnimation.duration = 0.3
                m.CoverRowAnimation.control = "pause"
            end if
        end if
    end if
    return true
end function