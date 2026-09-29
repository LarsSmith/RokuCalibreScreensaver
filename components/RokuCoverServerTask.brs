sub init()
    m.top.functionName = "loadCatalog"
end sub

sub loadCatalog()
    ' Always signal completion, including failures, to allow sample-cover fallback.
    m.top.coverImages = FetchRokuCoverCatalog(m.top.serverAddress)
    m.top.loadCoverImageTaskDone = true
end sub

function FetchRokuCoverCatalog(address as string) as object
    covers = []
    base = NormalizeRokuCoverServerAddress(address)
    ' Catalog and files are served at the origin, not in a subdirectory.
    originPattern = CreateObject("roRegex", "^https?://[^/?# ]+$", "i")
    if not originPattern.IsMatch(base) then return covers

    transfer = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.SetUrl(base + "/catalog.json")
    if not transfer.AsyncGetToString() then return covers
    event = Wait(10000, port)
    if event = invalid
        transfer.AsyncCancel()
        return covers
    end if
    if Type(event) <> "roUrlEvent" then return covers
    if event.GetResponseCode() <> 200 then return covers
    return ParseRokuCoverCatalog(event.GetString(), base)
end function

function ParseRokuCoverCatalog(body as string, base as string) as object
    covers = []
    catalog = ParseJson(body)
    if Type(catalog) <> "roAssociativeArray" then return covers
    if Type(catalog.libraries) <> "roArray" then return covers
    seen = {}
    seen.SetModeCaseSensitive()
    for each library in catalog.libraries
        if Type(library) = "roAssociativeArray"
            if Type(library.books) = "roArray"
                for each book in library.books
                    if Type(book) = "roAssociativeArray"
                        if Type(book.cover) = "roString" or Type(book.cover) = "String"
                            cover = book.cover.Trim()
                            url = ""
                            if Left(cover, 1) = "/" and Left(cover, 2) <> "//"
                                ' Preserve the percent encoding supplied by the Python server.
                                url = base + cover
                            else if LCase(Left(cover, 7)) = "http://" or LCase(Left(cover, 8)) = "https://"
                                url = cover
                            end if
                            if url <> ""
                                if not seen.DoesExist(url)
                                    seen[url] = true
                                    covers.Push(url)
                                end if
                            end if
                        end if
                    end if
                end for
            end if
        end if
    end for
    return covers
end function
