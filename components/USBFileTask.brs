function init()
    m.top.functionName = "getfiles"
    m.top.loadCoverImagesTask = false
    m.top.locateLibraryTask = false
    m.top.loadCoverImageTaskDone = invalid
    m.top.locateLibraryTaskDone = invalid
end function

function getfiles() as void
    print "Locating the files for coverImages"
    m.coverImagesWIP = []

    filesystem = CreateObject("roFileSystem")
    volumelist = filesystem.GetVolumeList()
    for each volume in volumelist 'Can a Roku device support multiple USB drives?
        if volume.Instr(0, "ext") > -1
            calibrePath = volume + "/Calibre"
            if filesystem.Exists(calibrePath)
                print "Calibre directory found at " + calibrePath
                calibreLibraries = filesystem.GetDirectoryListing(calibrePath)
                for each calibreLibrary in calibreLibraries
                    libraryPath = calibrePath + "/" + calibreLibrary
                    for each authorDirectory in filesystem.GetDirectoryListing(libraryPath)
                        authorPath = libraryPath + "/" + authorDirectory
                        for each titleDirectory in filesystem.GetDirectoryListing(authorPath)
                            titlePath = authorPath + "/" + titleDirectory
                            if filesystem.Exists(titlePath + "/cover.jpg")
                                if m.top.locateLibraryTask = true 'Purpose of task is only to verify a Calibre library exists and contains at least one book
                                    m.top.locateLibraryTaskDone = true
                                    return
                                end if 'Purpose of task is to build the entire list of book cover images
                                m.coverImagesWIP.Push(titlePath + "/cover.jpg")
                                'print "Added cover picture " + titlePath + "/cover.jpg"
                            end if
                        end for
                    end for
                end for
            end if
        end if
    end for


    m.top.coverImages = m.coverImagesWIP
    m.top.loadCoverImageTaskDone = true

    print "Finished locating files for coverImages"
end function

