function init()
    m.top.functionName = "getfiles"
    m.sampleCoverPath = "pkg:/images/covers/"
end function

function getfiles() as void
    'print "Loading sample covers"
    m.coverImagesWIP = []

    filesystem = CreateObject("roFileSystem")
    sampleCovers = filesystem.GetDirectoryListing(m.sampleCoverPath)
    for each cover in sampleCovers
        m.coverImagesWIP.Push(m.sampleCoverPath + cover)
        'print "Added sample cover picture " + cover
    end for
    
    m.top.coverImages = m.coverImagesWIP
    m.top.loadCoverImageTaskDone = true

    'print "Finished loading sample covers"
end function

