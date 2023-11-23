function init()
    m.timeout = 5000 'ms = 5 seconds
    'TODO tidy up unused fields
    m.top.functionName = "requestfiles"
    m.top.serverAddress = ""
    m.top.loadCoverImagesTask = false
    m.top.locateLibraryTask = false
    m.top.loadCoverImageTaskDone = false
    m.top.locateLibraryTaskDone = false
end function

function requestfiles() as void
    m.coverImagesWIP = []

    if m.top.locateLibraryTask then 'Task is to verify that server exists
        serverCheck = CreateObject("roUrlTransfer")
        port = CreateObject("roMessagePort")
        serverCheck.setMessagePort(port)
        serverCheck.setUrl(m.top.serverAddress + "/mobile")
        serverCheck.setRequest("GET")

        if serverCheck.AsyncGetToString()
            msg = Wait(m.timeout, serverCheck.getPort())
            if msg = invalid
                serverResponse = ""
            else if Type(msg) = "roUrlEvent" then
                serverResponse = msg.GetString()
            end if
        else
            'async call failed
            serverResponse = ""
        end if
            
        if serverResponse.Len() <> 0
            m.top.locateLibraryTaskDone = true
        else
            m.top.locateLibraryTaskDone = false
        end if
    else if m.top.loadCoverImagesTask then 'Task is to load coverImages
        serverCheck = CreateObject("roUrlTransfer")
        port = CreateObject("roMessagePort")
        serverCheck.setMessagePort(port)
        'example URL http://127.0.0.1:8080/mobile?search=&order=descending&sort=timestamp&num=10&library_id=Main&start=11
        'TODO memory profile of handling the HTML response. Tune size of queries per page?
        queryStartIndex = 1
        'TODO set as const
        m.QUERY_BOOKS_PER_PAGE = 100
        while true
            'TODO how to handle multiple libraries? configuration UI to multi-select libraries?
            url = Substitute("{0}/mobile?search=&order=descending&sort=timestamp&num={1}&library_id=Main&start={2}", m.top.serverAddress , m.QUERY_BOOKS_PER_PAGE.ToStr(), queryStartIndex.ToStr())
            serverCheck.setUrl(url)
            serverCheck.setRequest("GET")
            if serverCheck.AsyncGetToString()
                msg = Wait(m.timeout, serverCheck.getPort())
                if msg = invalid
                    exit while
                else if Type(msg) = "roUrlEvent" then
                    serverResponse = msg.GetString()
                end if
            else
                'async call failed
                exit while
            end if
            if serverResponse.Len() <> 0
                'Scan HTML response for book thumbnail URLs
                if serverResponse.Instr(0, "/get/thumb/") < 0 then exit while 'No thumbnails were found -- presumably the query is beyond the end of the library
                thumbnailIndex = 0
                while true
                    thumbnailIndex = serverResponse.Instr(thumbnailIndex, "/get/thumb/")
                    if thumbnailIndex = -1 then exit while 'No more thumbnails found
                    thumbnailIndex = thumbnailIndex + "/get/thumb/".Len() 'move the index beyond the current found thumbnail for the next loop
                    endIndex = serverResponse.Instr(thumbnailIndex, "/")
                    bookID = serverResponse.Mid(thumbnailIndex, endIndex - thumbnailIndex)
                    m.coverImagesWIP.Push(Substitute("{0}/get/cover/{1}/Main", m.top.serverAddress, bookID))
                    print "Added cover picture " + bookID
                end while
                queryStartIndex += m.QUERY_BOOKS_PER_PAGE
            else
                'server error response
            end if
        end while

        
        m.top.coverImages = m.coverImagesWIP
        m.top.loadCoverImageTaskDone = true
        
    end if
end function