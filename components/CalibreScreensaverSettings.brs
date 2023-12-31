sub init()
    m.top.backgroundURI = "pkg:/images/icons/shelves-splash-screen-HD.png"
    screensaverSettings = m.top.findNode("SettingsGroup")

    m.SettingsList = m.top.findNode("SettingsList")
    m.SettingsList.content.CreateChild("ContentNode").title = Tr("Calibre Library Source")
    m.SettingsList.content.CreateChild("ContentNode").title = Tr("Scroll Speed")
    m.SettingsList.content.CreateChild("ContentNode").title = Tr("Book Cover Size")
    m.SettingsList.content.CreateChild("ContentNode").title = Tr("About")
    m.ENUM_SettingsList_Calibre_Library_Source = 0
    m.ENUM_SettingsList_Scroll_Speed = 1
    m.ENUM_SettingsList_Book_Cover_Size = 2
    m.ENUM_SettingsList_About = 3
    m.SettingsList.observeField("itemFocused", "FocusSettingsItem")
    m.SettingsList.observeField("itemUnfocused", "UnfocusSettingsItem")
    m.SettingsList.observeField("itemSelected", "SelectSettingsItem")

    m.SettingOptionsGroup = m.top.findNode("SettingOptionsGroup")

    m.CalibreLibrarySource = m.top.findNode("CalibreLibrarySource")
    m.CalibreLibrarySource.content.CreateChild("ContentNode").title = Tr("USB Drive")
    m.CalibreLibrarySource.content.CreateChild("ContentNode").title = Tr("Calibre Content Server")
    m.ENUM_CalibreLibrarySource_USB = 0
    m.ENUM_CalibreLibrarySource_Server = 1
    librarySource = GetRegistryLibrarySource()
    if librarySource <> invalid and librarySource = "server" 'TODO replace with const
        m.CalibreLibrarySource.checkedItem = m.ENUM_CalibreLibrarySource_Server
    else 'Either registry is configured for USB Drive OR use the default of USB Drive
        m.CalibreLibrarySource.checkedItem = m.ENUM_CalibreLibrarySource_USB
    end if
    m.CalibreLibrarySource.observeField("itemFocused", "FocusCalibreLibrarySource")
    m.CalibreLibrarySource.observeField("itemUnfocused", "HideInfoTip")
    m.CalibreLibrarySource.observeField("itemSelected", "SelectLibrarySource")

    m.ScrollSpeed = m.top.findNode("ScrollSpeed")
    m.ScrollSpeed.content.CreateChild("ContentNode").title = Tr("Slow")
    m.ScrollSpeed.content.CreateChild("ContentNode").title = Tr("Medium")
    m.ScrollSpeed.content.CreateChild("ContentNode").title = Tr("Fast")
    m.ScrollSpeed.content.CreateChild("ContentNode").title = Tr("Custom")
    m.ENUM_ScrollSpeed_Slow = 0
    m.ENUM_ScrollSpeed_Medium = 1
    m.ENUM_ScrollSpeed_Fast = 2
    m.ENUM_ScrollSpeed_Custom = 3
    speed = GetRegistryScrollSpeed()
    if speed = "slow" 
        m.ScrollSpeed.checkedItem = m.ENUM_ScrollSpeed_Slow
    else if speed = "medium" 
        m.ScrollSpeed.checkedItem = m.ENUM_ScrollSpeed_Medium
    else if speed = "fast"
        m.ScrollSpeed.checkedItem = m.ENUM_ScrollSpeed_Fast
    else if speed = "custom"
        m.ScrollSpeed.checkedItem = m.ENUM_ScrollSpeed_Custom
    end if
    m.ScrollSpeed.observeField("itemFocused", "FocusScrollSpeed")
    m.ScrollSpeed.observeField("itemUnfocused", "HideInfoTip")
    m.ScrollSpeed.observeField("itemSelected", "SelectScrollSpeedItem")

    m.BookCoverSize = m.top.findNode("BookCoverSize")
    m.BookCoverSize.content.CreateChild("ContentNode").title = Tr("Small")
    m.BookCoverSize.content.CreateChild("ContentNode").title = Tr("Medium")
    m.BookCoverSize.content.CreateChild("ContentNode").title = Tr("Large")
    m.ENUM_BookCoverSize_Small = 0
    m.ENUM_BookCoverSize_Medium = 1
    m.ENUM_BookCoverSize_Large = 2
    size = GetRegistryBookCoverSize()
    if size = "small"
        m.BookCoverSize.checkedItem = m.ENUM_BookCoverSize_Small
    else if size = "medium"
        m.BookCoverSize.checkedItem = m.ENUM_BookCoverSize_Medium
    else if size = "large"
        m.BookCoverSize.checkedItem = m.ENUM_BookCoverSize_Large
    end if
    m.BookCoverSize.observeField("itemFocused", "FocusBookCoverSize")
    m.BookCoverSize.observeField("itemUnfocused", "HideInfoTip")
    m.BookCoverSize.observeField("itemSelected", "SelectBookCoverSize")

    m.InfoTip = m.top.findNode("InfoTip")
    m.InfoTipPadTop = m.top.findNode("InfoTipPadTop")
    m.BufferRowBase = 24 'Used to pad the InfoTip so the tip aligns with the focused menu item
    m.BufferRowHeight = 72

    m.OneColLayout = m.top.findNode("OneColLayout")
    m.TwoColLayout = m.top.findNode("TwoColLayout")

    m.About = m.top.findNode("About")
    AboutText = Tr("Digital books are quite convenient. But I miss my physical book shelf. ")
    AboutText = AboutText + Tr("Be reminded of the books you read long ago... and those you still intend to read someday. ")
    AboutText = AboutText + Chr(10) + Chr(10) + "https://github.com/LarsSmith/RokuCalibreScreensaver"
    m.About.text = AboutText

    m.SettingsList.setFocus(true)
end sub

'UI actions for the left-most column

function FocusSettingsItem() as void
    if m.SettingsList.itemFocused = m.ENUM_SettingsList_Calibre_Library_Source
        m.CalibreLibrarySource.visible = true
    else if m.SettingsList.itemFocused = m.ENUM_SettingsList_Scroll_Speed
        m.ScrollSpeed.visible = true
    else if m.SettingsList.itemFocused = m.ENUM_SettingsList_Book_Cover_Size
        m.BookCoverSize.visible = true
    else if m.SettingsList.itemFocused = m.ENUM_SettingsList_About
        m.TwoColLayout.visible = false
        m.OneColLayout.visible = true
    else
        print "FocusSettingsItem: Unknown SettingsList item focused"
    end if
end function

function UnfocusSettingsItem() as void
    if m.SettingsList.itemUnfocused = m.ENUM_SettingsList_Calibre_Library_Source
        m.CalibreLibrarySource.visible = false
    else if m.SettingsList.itemUnfocused = m.ENUM_SettingsList_Scroll_Speed
        m.ScrollSpeed.visible = false
    else if m.SettingsList.itemUnfocused = m.ENUM_SettingsList_Book_Cover_Size
        m.BookCoverSize.visible = false
    else if m.SettingsList.itemUnfocused = m.ENUM_SettingsList_About
        m.OneColLayout.visible = false
        m.TwoColLayout.visible = true
    else
        print "UnfocusSettingsItem: Unknown SettingsList item unfocused"
    end if
end function

function SelectSettingsItem() as void
    if m.SettingsList.itemSelected = m.ENUM_SettingsList_Calibre_Library_Source
        m.CalibreLibrarySource.setFocus(true)
    else if m.SettingsList.itemSelected = m.ENUM_SettingsList_Scroll_Speed
        m.ScrollSpeed.setFocus(true)
    else if m.SettingsList.itemSelected = m.ENUM_SettingsList_Book_Cover_Size
        m.BookCoverSize.setFocus(true)
    else if m.SettingsList.itemSelected = m.ENUM_SettingsList_About
        m.TwoColLayout.visible = false
        m.OneColLayout.visible = true
    else
        print "SelectSettingsItem: Unknown SettingsList item selected"
    end if    
end function

'UI actions for the center column

function HideInfoTip() as void 'Hide the InfoTip -- used anytime focus is lost
    'Perhaps we should stop the LocateCalibreLibraryTask because  when the task finishes, the InfoTip is made visible again
    'But this probably isn't needed because the task runs so quickly that no one feasibly navigates away before the task completes
    m.InfoTip.visible = false
end function

function FocusCalibreLibrarySource() as void
    if m.CalibreLibrarySource.itemFocused = m.ENUM_CalibreLibrarySource_USB
        'Should there just be one task that's reused? A new one for each focus may avoid race conditions
        m.LocateCalibreLibraryTask = CreateObject("roSGNode", "USBFileTask")
        m.LocateCalibreLibraryTask.locateLibraryTask = true
        m.LocateCalibreLibraryTask.observeField("state", "USBCalibreLibraryTaskDone")
        m.LocateCalibreLibraryTask.control = "run"       
    else if m.CalibreLibrarySource.itemFocused = m.ENUM_CalibreLibrarySource_Server
        serverAddress = GetRegistryLibraryAddress()
        if serverAddress <> invalid
            m.InfoTip.text = serverAddress
            'TODO trigger check that address is reachable
        else
            m.InfoTip.text = Tr("No IP Address set")
        end if
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight
        m.InfoTip.visible = true
    end if
end function

function USBCalibreLibraryTaskDone() as void
    if m.LocateCalibreLibraryTask.state = "done" OR m.LocateCalibreLibraryTask.state = "stop"
        if m.LocateCalibreLibraryTask.locateLibraryTaskDone
            m.InfoTip.text = Tr("Calibre Library found. ")
            'Perhaps display the name of the Calibre library found. But how many people have multiple libraries?
            'If multiple libraries are common, we need a dialog to checkbox select which libraries to include. 
            'For now just include all libraries for USB drives
            'For Calibre Content Servers, it's more tricky to navigate across libraries. Just use the default for now
        else
            infoTipText = Tr("No Calibre Library found. ")
            infoTipText = infoTipText + Chr(10) + Tr("Copy the 'Calibre' directory to the top level of the USB Drive. ")
            m.InfoTip.text = infoTipText
        end if
        m.InfoTipPadTop.height = m.BufferRowBase
        m.InfoTip.visible = true
    end if
end function

function SelectLibrarySource() as void
    if m.CalibreLibrarySource.itemSelected = m.ENUM_CalibreLibrarySource_USB
        SetRegistryLibrarySource("usb")
    else if m.CalibreLibrarySource.itemSelected = m.ENUM_CalibreLibrarySource_Server
        'Display the keyboard dialog to get the server address
        m.ContentServerAddressDialog = CreateObject("roSGNode", "StandardKeyboardDialog")
        m.ContentServerAddressDialog.title = Tr("Calibre Content Server Address")
        serverAddress = GetRegistryLibraryAddress()
        if serverAddress <> invalid
            m.ContentServerAddressDialog.text = serverAddress
        end if
        m.ContentServerAddressDialog.buttons = [Tr("Ok")]
        m.ContentServerAddressDialog.observeField("buttonSelected", "OnContentServerAddressSet")
        m.top.dialog = m.ContentServerAddressDialog
    end if
end function

function OnContentServerAddressSet() as void
    'TODO address verification - show error for invalid address formats and don't close

    'Setup the ServerFile Task first while we still have the address from the dialog
    m.ServerFileTask = CreateObject("roSGNode", "ServerFileTask")
    m.ServerFileTask.locateLibraryTask = true
    m.ServerFileTask.serverAddress = m.top.dialog.text
    m.ServerFileTask.observeField("state", "OnVerifyServer")

    'We cannot open a progress dialog until the current dialog is actually closed
    m.top.observeField("dialog", "OnContentServerAddressDialogClosed")
    m.top.dialog.close = true
    'Wait for the dialog to close before running the task to verify the server
end function

function OnContentServerAddressDialogClosed()
    if m.top.dialog = invalid
        'Now the keyboard dialog is confirmed as closed. We can open a progress dialog and start the task
        m.top.unobserveField("dialog")
        m.ServerVerificationDialog = CreateObject("roSGNode", "StandardProgressDialog")
        m.ServerVerificationDialog.title = Tr("Verifying server")
        m.top.dialog = m.ServerVerificationDialog

        m.ServerFileTask.control = "run"    
    end if
end function

function OnVerifyServer()
    if m.ServerFileTask.state = "done" OR m.ServerFileTask.state = "stop"
        'The task is complete. However, we may want to re-display the keyboard dialog. So wait for the progress dialog to close
        m.top.observeField("dialog", "OnServerVerificationDialogClosed")
        m.top.dialog.close = true
    end if
end function

function OnServerVerificationDialogClosed()
    if m.top.dialog = invalid
        'Now the progress dialog is confirmed as closed, we can process the results of the server verification task
        m.top.unobserveField("dialog")
        if m.ServerFileTask.locateLibraryTaskDone
            'Server verification succeeded. We can set the value in the registry
            SetRegistryLibrarySource("server") 'TODO replace with const
            SetRegistryLibraryAddress(m.ServerFileTask.serverAddress)
            m.InfoTip.text = m.ServerFileTask.serverAddress
        else
            'Server verification failed. Re-display the keyboard dialog with error message
            'For some reason, re-using the existimg dialog didn't work
            m.ContentServerAddressDialog = CreateObject("roSGNode", "StandardKeyboardDialog")
            m.ContentServerAddressDialog.title = Tr("Calibre Content Server Address")
            m.ContentServerAddressDialog.text = m.ServerFileTask.serverAddress
            m.ContentServerAddressDialog.message = [Tr("Server not found. Enter an IP address or hostname. For example http://192.168.1.5:8080"),
                                                    Tr("Look under Connect/share in Calibre to ensure the server is running and verify the address")]
            m.ContentServerAddressDialog.buttons = [Tr("Ok")]
            m.ContentServerAddressDialog.observeField("buttonSelected", "OnContentServerAddressSet")                                            
            m.top.dialog = m.ContentServerAddressDialog
        end if
    end if
end function

function FocusScrollSpeed() as void
    if m.ScrollSpeed.itemFocused = m.ENUM_ScrollSpeed_Slow
        m.InfoTip.text = Substitute(Tr("About {0} seconds per cover"), ConvertScrollSpeedToSeconds("slow").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_ScrollSpeed_Slow
        m.InfoTip.visible = true
    else if m.ScrollSpeed.itemFocused = m.ENUM_ScrollSpeed_Medium
        m.InfoTip.text = Substitute(Tr("About {0} seconds per cover"), ConvertScrollSpeedToSeconds("medium").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_ScrollSpeed_Medium
        m.InfoTip.visible = true
    else if m.ScrollSpeed.itemFocused = m.ENUM_ScrollSpeed_Fast
        m.InfoTip.text = Substitute(Tr("About {0} seconds per cover"), ConvertScrollSpeedToSeconds("fast").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_ScrollSpeed_Fast
        m.InfoTip.visible = true
    else if m.ScrollSpeed.itemFocused = m.ENUM_ScrollSpeed_Custom
        m.InfoTip.text = Substitute(Tr("About {0} seconds per cover"), ConvertScrollSpeedToSeconds("custom").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_ScrollSpeed_Custom
        m.InfoTip.visible = true
    end if
end function

function SelectScrollSpeedItem() as void
    if m.ScrollSpeed.itemSelected = m.ENUM_ScrollSpeed_Slow
        SetRegistryScrollSpeed("slow")
    else if m.ScrollSpeed.itemSelected = m.ENUM_ScrollSpeed_Medium
        SetRegistryScrollSpeed("medium")
    else if m.ScrollSpeed.itemSelected = m.ENUM_ScrollSpeed_Fast
        SetRegistryScrollSpeed("fast")
    else if m.ScrollSpeed.itemSelected = m.ENUM_ScrollSpeed_Custom
        m.CustomScrollSpeedDialog = CreateObject("roSGNode", "StandardPinPadDialog")
        m.CustomScrollSpeedDialog.title = Tr("Scroll Speed in Seconds")
        m.CustomScrollSpeedDialog.textEditBox.secureMode = false 'avoid masking digits with • character
        m.CustomScrollSpeedDialog.textEditBox.maxTextLength = -1 'avoid displaying underscores which suggest that multiple digits are expected
        m.CustomScrollSpeedDialog.buttons = [Tr("Ok")]
        m.CustomScrollSpeedDialog.observeField("buttonSelected", "OnCustomScrollSpeedSet")
        m.top.dialog = m.CustomScrollSpeedDialog
    end if
end function

function OnCustomScrollSpeedSet() as void
    SetRegistryScrollSpeed("custom")
    SetRegistryScrollSpeedCustomSecs(m.CustomScrollSpeedDialog.pin.ToInt())
    'TODO deal with no value set by backing out of the dialog. For now this is handled by the utility returning default if 'custom' is set but no set speed
    m.top.dialog.close = true
    m.InfoTip.text = Substitute(Tr("{0} seconds per cover"), m.CustomScrollSpeedDialog.pin)
    m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_ScrollSpeed_Custom
    m.InfoTip.visible = true
end function

function SelectBookCoverSize() as void
    if m.BookCoverSize.itemSelected = m.ENUM_BookCoverSize_Small
        SetRegistryBookCoverSize("small")
    else if m.BookCoverSize.itemSelected = m.ENUM_BookCoverSize_Medium
        SetRegistryBookCoverSize("medium")
    else if m.BookCoverSize.itemSelected = m.ENUM_BookCoverSize_Large
        SetRegistryBookCoverSize("large")
    end if
end function

function FocusBookCoverSize() as void
    if m.BookCoverSize.itemFocused = m.ENUM_BookCoverSize_Small
        m.InfoTip.text = Substitute(Tr("{0} pixels tall"), ConvertBookCoverSizeToPixels("small").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_BookCoverSize_Small
        m.InfoTip.visible = true
    else if m.BookCoverSize.itemFocused = m.ENUM_BookCoverSize_Medium
        m.InfoTip.text = Substitute(Tr("{0} pixels tall"), ConvertBookCoverSizeToPixels("medium").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_BookCoverSize_Medium
        m.InfoTip.visible = true
    else if m.BookCoverSize.itemFocused = m.ENUM_BookCoverSize_Large
        m.InfoTip.text = Substitute(Tr("{0} pixels tall"), ConvertBookCoverSizeToPixels("large").ToStr())
        m.InfoTipPadTop.height = m.BufferRowBase + m.BufferRowHeight * m.ENUM_BookCoverSize_Large
        m.InfoTip.visible = true
    end if
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if (key = "right") and (press=true) AND (m.SettingsList.hasFocus() = true)
        if m.SettingsList.itemFocused = m.ENUM_SettingsList_Calibre_Library_Source
            m.CalibreLibrarySource.setFocus(true)
        else if m.SettingsList.itemFocused = m.ENUM_SettingsList_Scroll_Speed
            m.ScrollSpeed.setFocus(true)
        else if m.SettingsList.itemFocused = m.ENUM_SettingsList_Book_Cover_Size
            m.BookCoverSize.setFocus(true)
        end if 
	    handled = true
	else if (key = "left") and (press=true) AND (m.SettingsList.hasFocus() = false)
        m.InfoTip.visible = false
		m.SettingsList.setFocus(true)
	    handled = true
	endif
    return handled    
end function
