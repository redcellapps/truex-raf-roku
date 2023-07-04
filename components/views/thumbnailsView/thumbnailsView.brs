'#  Copyright (c) 2021 FreebieTV. All rights reserved.
'#  Created on 13/08/2021 by Igor Malasevschi


sub init()

  m.seek1 = m.top.FindNode("seek1")
  m.seek2 = m.top.FindNode("seek2")
  m.seek3 = m.top.FindNode("seek3")
  m.seek4 = m.top.FindNode("seek4")
  m.seek5 = m.top.FindNode("seek4")
  m.whiteView = m.top.FindNode("whiteView")

  m.seeks = []
  seeksCount = 5

  for i = 0 to seeksCount - 1 step 1
      file = "seek" + (i + 1).toStr()
      node = m.top.FindNode(file)
      m.seeks.push(node)
  end for

end sub


sub clearSeekThumbs()
 seeksCount = 5
 for i = 0 to seeksCount - 1 step 1
        m.seeks[i].uri = ""
 end for
end sub



sub fillSeeks(seeksOffset as integer, seekData as object) 
    seeksCount = 5

    for i = 0 to seeksCount - 1 step 1
        seekDataIndex = i + seeksOffset

        if seekDataIndex >= 0 and seekDataIndex < seeksCount
                m.seeks[seekDataIndex].uri = "tmp:/" + seekData[i]
        end if 
    end for
end sub