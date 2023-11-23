'Library Source

function GetRegistryLibrarySource() as dynamic
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("LibrarySource")
        return section.Read("LibrarySource")
    endif
    return invalid
end function

function SetRegistryLibrarySource(source as string) as void
    section = CreateObject("roRegistrySection", "General")
    section.Write("LibrarySource", source)
    section.Flush()
end function

function GetRegistryLibraryAddress() as dynamic
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("LibraryAddress")
        return section.Read("LibraryAddress")
    endif
    return invalid
end function

function SetRegistryLibraryAddress(address as string) as void
    section = CreateObject("roRegistrySection", "General")
    section.Write("LibraryAddress", address)
    section.Flush()
end function

'Scroll Speed

function ConvertScrollSpeedToSeconds(speed as string) as integer
    if speed = "slow" 
        return 25
    else if speed = "medium" 
        return 12
    else if speed = "fast"
        return 8
    else if speed = "custom"
        return GetRegistryScrollSpeedCustomSecs()
    else
        print "ConvertScrollSpeedToSeconds: invalid scroll speed"
        return 12
    end if
end function

function GetRegistryScrollSpeed() as string
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("ScrollSpeed")
        return section.Read("ScrollSpeed")
    endif
    return "medium"
end function

function SetRegistryScrollSpeed(speed as string) as void
    section = CreateObject("roRegistrySection", "General")
    section.Write("ScrollSpeed", speed)
    section.Flush()
end function

function IsRegistryScrollSpeedCustom() as boolean
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("ScrollSpeed")
        if section.Read("ScrollSpeed") = "custom"
            return true
        end if
    end if
    return false
end function

function GetRegistryScrollSpeedCustomSecs() as integer
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("ScrollSpeedCustomSecs")
        return section.Read("ScrollSpeedCustomSecs").ToInt()
    endif
    return ConvertScrollSpeedToSeconds("medium") 'default is medium if custom speed is not set
end function

function SetRegistryScrollSpeedCustomSecs(seconds as integer) as void
    section = CreateObject("roRegistrySection", "General")
    section.Write("ScrollSpeedCustomSecs", seconds.ToStr())
    section.Flush()
end function

'Book cover size

function ConvertBookCoverSizeToPixels(size as string) as integer
    if size = "small" 
        return 500
    else if size = "medium" 
        return 700
    else if size = "large"
        return 1080
    else
        print "ConvertBookCoverSizeToPixels: invalid book cover size"
        return 700
    end if
end function

function GetRegistryBookCoverSize() as string
    section = CreateObject("roRegistrySection", "General")
    if section.Exists("BookCoverSize")
        return section.Read("BookCoverSize")
    endif
    return "medium"
end function

function SetRegistryBookCoverSize(size as string) as void
    section = CreateObject("roRegistrySection", "General")
    section.Write("BookCoverSize", size)
    section.Flush()
end function