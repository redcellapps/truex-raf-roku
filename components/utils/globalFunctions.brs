'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 14/06/2021 by Igor Malasevschi



sub setGlobal(key as string, value as dynamic)
  if (type(value) = invalid) then
    if (m.global.hasField(key)) then
      m.global.key = invalid
    end if
  else
    if (m.global.hasField(key)) then
      m.global.setField(key, value)
    else
      obj = {}
      obj[key] = value
      m.global.addFields(obj)
    end if
  end if
end sub

function getGlobal(key as string) as dynamic
  if (m.global.hasField(key)) then
    return m.global.getField(key)
  end if

  return invalid
end function


'============== GET APP TITLE ================
function getAppTitle() as string
  appInfo = CreateObject("roAppInfo")
  title = appInfo.GetValue("title")

  return title
end function


'=============== GET EVENT START TIME ==========='
function getEventStartTime() as integer
  date = CreateObject("roDateTime")
  date.toLocalTime()
  hours = date.GetHours()
  minutes = date.Getminutes()
  seconds = date.GetSeconds()

  startTime = date.AsSeconds() - (hours * 3600) - (minutes * 60) - seconds
  return startTime
end function


'========== GET CURRENT TIME ==================
function getCurrentTime() as integer
  date = CreateObject("roDateTime")
  date.toLocalTime()
  return date.AsSeconds()
end function



'============ Get Data from Seconds ======================'
function getDataFromSeconds(seconds as integer) as string
  date = CreateObject("roDateTime")
  date.FromSeconds(seconds)
  date.ToLocalTime()

  dayOfWeek = ""
  dateOfMonth = str(date.GetDayOfMonth()).trim()
  year = date.AsDateString("short-month-no-weekday")
  day = date.GetDayOfWeek()

  if day = 0
    dayOfWeek = "Sun"
  else if day = 1
    dayOfWeek = "Mon"
  else if day = 2
    dayOfWeek = "Tue"
  else if day = 3
    dayOfWeek = "Wed"
  else if day = 4
    dayOfWeek = "Thu"
  else if day = 5
    dayOfWeek = "Fri"
  else if day = 6
    dayOfWeek = "Sat"
  end if
  return dayOfWeek + " " + dateOfMonth + "/" + Right(year, 2)
end function


'============ Get Data from Seconds ======================'
function getCurrentData() as string
  date = CreateObject("roDateTime")
  date.ToLocalTime()

  dayOfWeek = ""
  dateOfMonth = str(date.GetDayOfMonth()).trim()
  year = date.AsDateString("short-month-no-weekday")
  day = date.GetDayOfWeek()

  if day = 0
    dayOfWeek = "Sun"
  else if day = 1
    dayOfWeek = "Mon"
  else if day = 2
    dayOfWeek = "Tue"
  else if day = 3
    dayOfWeek = "Wed"
  else if day = 4
    dayOfWeek = "Thu"
  else if day = 5
    dayOfWeek = "Fri"
  else if day = 6
    dayOfWeek = "Sat"
  end if
  return dayOfWeek + " " + dateOfMonth
end function



'==== GET TIME FROM SECONDS =============================='
function getCurrentTimeFormatted() as string

  date = CreateObject("roDateTime")
  date.toLocalTime()

  hours = date.GetHours()
  minutes = date.Getminutes()


  ampm = "AM"

  if hours = 0
    hours = 12
  else if hours > 12
    hours = hours - 12
    ampm = "PM"
  else if hours = 12
    ampm = "PM"
  end if

  hoursStr = str(hours).trim()
  minutesStr = str(minutes).trim()

  if hoursStr.len() = 1
    hoursStr = "0" + hoursStr
  end if

  if minutesStr.len() = 1
    minutesStr = "0" + minutesStr
  end if

  result = hoursStr + ":" + minutesStr + " " + ampm

  return result
end function

'============ GET TIME FROM SECONDS ============
function dateFromIntegerToString(time as integer) as string
  date = CreateObject("roDateTime")
  date.FromSeconds(time)

  hours = (date.GetHours()).toStr()
  minutes = (date.GetMinutes()).toStr()
  seconds = (date.GetSeconds()).toStr()


  if (len(minutes) = 1) then
    minutes = "0" + minutes
  end if

  if (len(seconds) = 1) then
    seconds = "0" + seconds
  end if

  result = minutes + ":" + seconds

  if (len(hours) = 1) and hours <> "0" then
    hours = "0" + hours
    result = hours + ":" + result
  end if


  return result
end function



'==== GET TIME FROM SECONDS =============================='
function dateFromIntegerToStringUSA(time as integer) as string

  date = CreateObject("roDateTime")
  date.FromSeconds(time)
  'date.toLocalTime()

  hours = date.GetHours()
  minutes = date.Getminutes()


  ampm = "AM"

  if hours = 0
    hours = 12
  else if hours > 12
    hours = hours - 12
    ampm = "PM"
  else if hours = 12
    ampm = "PM"
  end if

  hoursStr = str(hours).trim()
  minutesStr = str(minutes).trim()

  if hoursStr.len() = 1
    hoursStr = "0" + hoursStr
  end if

  if minutesStr.len() = 1
    minutesStr = "0" + minutesStr
  end if

  result = hoursStr + ":" + minutesStr + " " + ampm

  return result
end function


'=========== GET COUNTRY CODE ======='
function getCountryCode() as string
  di = CreateObject("roDeviceInfo")
  return di.GetCountryCode()
end function


'============ GET IP ADDRESS ======'
function getIpAddress() as string
  di = CreateObject("roDeviceInfo")
  return di.GetConnectionInfo().ip
end function