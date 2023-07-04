function bifManager() as object
   instance = {
      dataset: CreateObject("roByteArray"),

      '============= GET BIF FILE  ============='
      getBifFile: sub(url as string, fileName as string, onCompleteFuncName = "" as string)
         taskNode = CreateObject("roSGNode", "downloadFileTask")
         taskNode.Url = url
         taskNode.fileName = "tmp:/" + fileName
         taskNode.observeField("response", onCompleteFuncName)
         taskNode.control = "RUN"
      end sub,

      '========== PARSE BIF FILE =================
      parseBifFile: function(fileName as string) as object
         bifData = []
         result = m.dataset.ReadFile("tmp:/" + fileName)

         if result = true
            bifVersion = -1

            if m.dataset.Count() > 0
               '//MARK: Debug Info'
               '0-7=magic number unique file identifier=offset
               if m.dataset.GetEntry(0) = &h89 and m.dataset.GetEntry(1) = &h42 and m.dataset.GetEntry(2) = &h49 and m.dataset.GetEntry(3) = &h46 and m.dataset.GetEntry(4) = &h0d and m.dataset.GetEntry(5) = &h0a and m.dataset.GetEntry(6) = &h1a and m.dataset.GetEntry(7) = &h0a
                  '//MARK: Debug Info'
                  'valid BIF File Identifier
                  '8-11=bif file format version number
                  if m.dataset.GetEntry(8) = 0 and m.dataset.GetEntry(9) = 0 and m.dataset.GetEntry(10) = 0 and m.dataset.GetEntry(11) = 0
                     '//MARK: Debug Info'
                     'Using Version 0 descrambler
                     bifVersion = 0
                  end if
               end if

               if bifVersion = 0
                  '//MARK: Debug Info'
                  '12-15=total number of bif file images
                  totalFrameCount = 0

                  if m.dataset.GetEntry(12) <> invalid and m.dataset.GetEntry(13) <> invalid and m.dataset.GetEntry(14) <> invalid and m.dataset.GetEntry(15) <> invalid
                     totalFrameCount = m.dataset[12] + (m.dataset[13]<<8) + (m.dataset[14]<<16) + (m.dataset[15]<<24)
                  end if

                  '//MARK: Debug Info'
                  '16-19=timestamp multiplier
                  timestampMultiplier = 0

                  if m.dataset.GetEntry(16) <> invalid and m.dataset.GetEntry(17) <> invalid and m.dataset.GetEntry(18) <> invalid and m.dataset.GetEntry(19) <> invalid
                     timestampMultiplier = m.dataset.GetEntry(16) + (m.dataset.GetEntry(17)<<8) + (m.dataset.GetEntry(18)<<16) + (m.dataset.GetEntry(19)<<24)
                  end if

                  if timestampMultiplier = 0 then timestampMultiplier = 1000 'if 0, BIF specification treats it as 1000ms
                  '//MARK: Debug Info'
                  '20-63=reserved for future expansion - all 00 bytes
                  'frame index table repeats until all frames are accounted for
                  '64-67=frame 0 index timestamp
                  '68-71=frame 0 absolute offset of frame
                  'last index frame
                  '0xffffffff
                  'followed by last byte of data +1
                  'initialize byte number counter
                  offset = 64
                  olderTimestamp = 0

                  'print "totalFrameCount " ;totalFrameCount

                  for index = 0 to totalFrameCount - 1 step 1 'run through entire index table
                     T1 = -1
                     T2 = -1
                     T3 = -1

                     if m.dataset.GetEntry(offset) <> invalid and m.dataset.GetEntry(offset + 1) <> invalid and m.dataset.GetEntry(offset + 2) <> invalid and m.dataset.GetEntry(offset + 3) <> invalid
                        T1 = m.dataset[offset] + (m.dataset[offset + 1]<<8) + (m.dataset[offset + 2]<<16) + (m.dataset[offset + 3]<<24)
                     end if

                     if m.dataset.GetEntry(offset + 4) <> invalid and m.dataset.GetEntry(offset + 5) <> invalid and m.dataset.GetEntry(offset + 6) <> invalid and m.dataset.GetEntry(offset + 7) <> invalid
                        T2 = m.dataset[offset + 4] + (m.dataset[offset + 5]<<8) + (m.dataset[offset + 6]<<16) + (m.dataset[offset + 7]<<24)
                     end if

                     if m.dataset.GetEntry(offset + 4 + 8) <> invalid and m.dataset.GetEntry(offset + 5 + 8) <> invalid and m.dataset.GetEntry(offset + 7 + 8) <> invalid
                        T3 = m.dataset[offset + 4 + 8] + (m.dataset[offset + 5 + 8]<<8) + (m.dataset[offset + 6 + 8]<<16) + (m.dataset[offset + 7 + 8]<<24)
                     end if

                     '//MARK: - associative array what hold, timeStamp,
                     'bufferStart, bufferEnd, used to get image from Byte Array.

                     'if T1 = 0
                     ''  T1 = 10000 * (index + 1)
                     'end if

                     ref = {
                        timestamp: Int(T1 * timestampMultiplier / 1000),
                        bufferStart: T2,
                        bufferEnd: T3
                     }
                     bifData.Push(ref)
                     offset = offset + 8
                  end for
               end if
            end if
         end if
         return bifData
      end function

      '==================== WRITE BYTES TO FILE =================='
      writeBytesToTempFile: function(fileName as string, bufferStart as integer, bufferEnd as integer) as boolean
         result = m.dataset.WriteFile("tmp:/" + fileName, bufferStart, bufferEnd)
         return result
      end function,

      '================== DELETE TEMP FILE =================
      deleteTempFile: function(fileName as object) as boolean
         if fileName <> invalid
            result = DeleteFile("tmp:/" + fileName)
            return result
         end if
         return false
      end function,

      deleteTempFiles: sub()
         taskNode = CreateObject("roSGNode", "CleanUpDirectoryTask")
         taskNode.fileDirectory = "tmp:/"
         taskNode.control = "RUN"
      end sub,

      checkFileExists: function(fileName as string) as object
         files = MatchFiles("tmp:/", fileName)
         return files
      end function
   }
   return instance
end function

