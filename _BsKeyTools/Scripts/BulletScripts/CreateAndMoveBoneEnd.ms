global arrBoneEndAll = #()

if (arrBoneEndAll.curvecontrol == 0) then
(
    if selection.count != 0 do with undo on 
    (
        arrSel = selection as array
        for i in 1 to arrSel.count do
        (
            parentBone  = arrSel[i]
            parentTrans = parentBone.transform
            parentPos   = parentTrans.translation
    
            newBone = BoneSys.createBone parentPos (parentPos+6) parentBone.dir
            newBone.transform = parentTrans
            newBone.taper     = 90
    
            if iskindof arrSel[i] BoneGeometry==true do 
            (
                in coordSys Local move newBone [parentBone.length,0,0]
                newBone.parent    = parentBone
                newBone.width     = parentBone.width
                newBone.height    = parentBone.height
                newBone.length    = (parentBone.width+parentBone.height)/2
                newBone.wirecolor = parentBone.wirecolor
            )
            append arrBoneEndAll newBone
        )
    )
    messageBox "添加完成，注意：重启软件后无法回退，\r\n
可点击右键或手动清除之前添加的末端（在 tempBoneEndAll 层中）          "
)
