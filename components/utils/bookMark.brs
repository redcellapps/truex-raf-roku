'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 27/05/2021 by Igor Malasevschi

function bookMark() as object
  instance = {

    '==================== SET BOOKMARK ================================='
    setBookmark: function(itemObj as object, bookmarkData as object) as object

      bookmarkList = []

      bookmarkObj = {
        id: itemObj.itemID,
        name: itemObj.name,
        long_description: itemObj.description,
        img_landscape: {
          low: itemObj.landscapeImgLow,
        high: itemObj.landscapeImgHigh },
        img_portrait: itemObj.portraitImg,
        isFavorite: itemObj.isFavorite,
        playerPos: itemObj.playerPos
        type: itemObj.itemType
      }

      if (itemObj.playerPos > 0 or itemObj.isFavorite = true)
        bookmarkList.Push(bookmarkObj)
      end if

      if bookmarkData <> invalid
        index = 0

        while index < bookmarkData.count()
          if bookmarkData[index].id <> itemObj.itemID and (bookmarkData[index].playerPos > 0 or bookmarkData[index].isFavorite = true)
            bookmarkList.Push(bookmarkData[index])
          end if
          index = index + 1
        end while
      end if

      return bookmarkList
    end function,

    '=============== GET MARK ITEM ===============
    getBookmarkItem: function(itemID as object, bookmarkData as object) as object

      itemObj = invalid

      if bookmarkData <> invalid
        index = 0

        while index < bookmarkData.count()
          if bookmarkData[index].id = itemID
            itemObj = bookmarkData[index]
            exit while
          end if
          index = index + 1
        end while

      end if

      return itemObj
    end function,

    '================== CLEAR BOOKMARK ======================
    clearBookmark: function(itemID as object, bookmarkData as object) as object

      bookmarkList = []

      if bookmarkData <> invalid
        index = 0
        while index < bookmarkData.Count()
          if bookmarkData[index].id <> itemID
            bookmarkList.Push (bookmarkData[index])
          end if
          index = index + 1
        end while
      end if

      return bookmarkList
    end function

  }

  return instance
end function




