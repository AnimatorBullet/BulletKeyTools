/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-31 03:03:10
 * @Email: animator.bullet@foxmail.com
 */

global dotDrawingImage = dotNetclass "System.Drawing.Image"
global dotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"

global tempSavePath = (getdir #temp) + "\\tempReferencePic\\"

fn fnSaveClipBoardPic =
(
    local arrTempFiles = #()
    local arrTempid = #(0)

    arrTempFiles = getFiles (tempSavePath + "*.*")
    for i in arrTempFiles where arrTempFiles.count != 0 do
    (
        if (MatchPattern (getfilenameFile i) pattern:"*tempReferencePic*") then
        (
            tempid = (filterString (getfilenameFile i) "tempReferencePic")
        appendIfUnique arrTempid (tempid[tempid.count] as number)
            sort arrTempid
        )
    )
    tempImage = dotNetClipboard.GetImage()
    tempSaveImage = (tempSavePath + "tempReferencePic" + \
    ((arrTempid[arrTempid.count] + 1) as string) +".png")
    if tempImage != undefined do 
    (
        tempImage.save tempSaveImage
        fnCreateRefPlane tempSaveImage
    )
)

fn fnCreateRefPlane filePath =
(
    tempRefImage = dotDrawingImage.fromfile filePath 
    planeRef = plane width:tempRefImage.width length:tempRefImage.height lengthsegs:1 widthsegs:1 
    planeRef.rotation.x_rotation = 90
    bitmapRef = Bitmaptexture fileName:filePath
    planeRef.material = standard diffuseMap:(bitmapRef) showInViewport:true
    planeRef.material.name = "matReferencePic"
)

fnSaveClipBoardPic ()

if dotNetClipboard.ContainsFileDropList() do 
(
    fileList = dotNetClipboard.GetFileDropList()
    for i = 0 to (fileList.count - 1) do (fnCreateRefPlane (fileList.item i))
)

-- if (queryBox "是否切换高分辨率贴图显示？      \r\n( 会改变显示贴图精度 )\r\n        " \
-- 		title:"切换高分辨率贴图显示" beep:false) then
-- (
    
-- )

-- if (queryBox "是否彻底清理参考图？      \r\n" \
-- 		title:"清理参考图" beep:false) then
-- (
--     shellLaunch tempSavePath ""
-- )