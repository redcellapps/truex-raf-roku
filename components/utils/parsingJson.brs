
sub fetchCategories(categoriesData as object, responseData as object)

  list = []

  if responseData.type <> invalid

    categoryObj = {
      id: responseData.id,
      itemType: responseData.type
      name: responseData.name,
      items: []
    }
  end if

  for each item in responseData.items

    if item.type <> "category"
      itemObj = getItemObject(item)
      list.push(itemObj)
    else

      categoryObj = getCategoryObject(item)
      categoriesData.push(categoryObj)
    end if
  end for

  if list.count() > 0
    categoryObj.items = list
    categoriesData.push(categoryObj)
  end if

end sub



'============== FETCH FAVORITES =================='
sub fetchFavorites(categoriesData as object, responseData as object)

  categoryObj = {
    name: "All Favorites"
    items: []
  }

  for each item in responseData
    if item.isFavorite
      itemObj = getItemObject(item)
      categoryObj.items.push(itemObj)
    end if
  end for

  categoriesData.push(categoryObj)
end sub



'=========== GET ITEMS ========'
function getItems(items as object) as object

  list = []

  if items <> invalid
    for each item in items
      itemObj = getItemObject(item)
      list.push(itemObj)
    end for
  end if

  return list
end function



'============== GET ITEM OBJECT ============'
function getCategoryObject(category as object) as object

  items = getItems(category.items)
  categoryObj = {
    id: category.id,
    itemType: category.type
    name: category.name,
    items: items
  }

  return categoryObj
end function

'============== GET ITEM OBJECT ============'
function getItemObject(item as object) as object

  portraitImg = getDefaultPortraitImg()
  landscapeImgLow = getDefaultLandscapeImg()
  landscapeImgHigh = getDefaultLandscapeImg()

  if item.img_portrait <> invalid and item.img_portrait <> ""
    portraitImg = item.img_portrait
  end if

  
  if item.img_landscape <> invalid  and type(item.img_landscape) = "roAssociativeArray"
    if item.img_landscape.low <> invalid
      landscapeImgLow = item.img_landscape.low
    end if

    if item.img_landscape.high <> invalid
      landscapeImgHigh = item.img_landscape.high
    end if
  end if

  isFavorite = false
  playerPos = 0

  if item.playerPos <> invalid
    playerPos = item.playerPos
  end if

  if item.isFavorite <> invalid
    isFavorite = item.isFavorite
  end if

  itemObj = {
    id: item.id,
    name: item.name,
    description: item.long_description,
    itemType: item.type,
    portraitImg: portraitImg,
    landscapeImgLow: landscapeImgLow,
    landscapeImgHigh: landscapeImgHigh,
    playerPos: playerPos,
    isFavorite: isFavorite
  }

  return itemObj
end function

'==========================='
sub getDefaultPortraitImg() as object
  defaultImg = "pkg:/images/movieScreen/defaultPortrait.png"

  return defaultImg
end sub


'==========================='
sub getDefaultLandscapeImg() as object
  defaultImg = "pkg:/images/movieScreen/defaultLandscape.png"

  return defaultImg
end sub