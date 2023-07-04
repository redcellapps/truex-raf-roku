sub init()
    m.top.functionName = "execute"
end sub

sub execute()
    fileDirectory = m.top.fileDirectory

    fs = createObject("roFileSystem")
    list = fs.GetDirectoryListing(fileDirectory)
    for each item in list
        fs.delete(fileDirectory + item)
    end for
end sub

