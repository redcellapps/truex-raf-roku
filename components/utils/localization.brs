sub initLocalization()

  '////////////
  '//ERRORS'
  '////////////

  apiGenericError = "An error has occurred while retrieving data from server."
  setGlobal("apiGenericError", apiGenericError)

  noItemsError = "There are no items to display in this category"
  setGlobal("noItemsError", noItemsError)

  noFavoriteItemsError = "There are no favorites items to display. Please add movie, live or radio."
  setGlobal("noFavoriteItemsError", noFavoriteItemsError)

  configGenericError = "An error has occurred while reading config file."
  setGlobal("configGenericError", configGenericError)

  menuLoadError = "An error has occured while initialize menu items."
  setGlobal("menuLoadError", menuLoadError)

  channelNotAvailableError = "This channel is not available."
  setGlobal("channelNotAvailableError", channelNotAvailableError)

  closeTitle = "Are you sure you want to close ?"
  setGlobal("closeTitle", closeTitle)

  playerError = "An error has occured while playing this stream."
  setGlobal("playerError", playerError)

  deepLinkError = "Unrecognized Deep Link Media Data"
  setGlobal("deepLinkError", deepLinkError)
end sub