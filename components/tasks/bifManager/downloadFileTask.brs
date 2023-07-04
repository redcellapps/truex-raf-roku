sub init()
    m.top.functionName = "execute"
end sub

sub execute()

    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")

    request.SetUrl(m.top.url)
    request.SetMessagePort(port)
    request.EnableCookies()
    request.EnableEncodings(true)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")

    fileName = m.top.fileName

    if request.AsyncGetToFile(fileName)

        msg = wait(0, port)
        if (type(msg) = "roUrlEvent")

            code = msg.GetResponseCode()
            
            if (code = 200)
                m.top.response = "success"
            else 
                m.top.response = "invalid"
                request.AsyncCancel()
            end if
        else if (msg = invalid)
            m.top.response = "invalid"
            request.AsyncCancel()
        end if
    end if
end sub

