/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-31 18:28:39
 * @Email: animator.bullet@foxmail.com
 */

-- 首先复制几个序列帧图片,然后运行该脚本, 仅做功能测试,想鸽, 望有缘人或者有兴趣同学自行完善


try(destroydialog rolPreviewRef)catch()

global dotDrawingImage = dotNetclass "System.Drawing.Image"
global dotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"

global numCurrentPic = 1

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
        -- fnCreateRefPlane tempSaveImage
    )
)

fn fnCreateRefPlane filePath =  --获取剪切板的图片, 貌似只支持单个, 支持网络图片直接复制, 会在temp里面另存
(
    tempRefImage = dotDrawingImage.fromfile filePath 
    planeRef = plane width:tempRefImage.width length:tempRefImage.height lengthsegs:1 widthsegs:1 
    planeRef.rotation.x_rotation = 90
    bitmapRef = Bitmaptexture fileName:filePath
    planeRef.material = standard diffuseMap:(bitmapRef) showInViewport:true
    planeRef.material.name = "matReferencePic"
)

fnSaveClipBoardPic ()

if dotNetClipboard.ContainsFileDropList() do ---获取剪切板的本地图片, 可多个
(
    fileList = dotNetClipboard.GetFileDropList()
    -- for i = 0 to (fileList.count - 1) do (fnCreateRefPlane (fileList.item i))
    for i = 0 to (fileList.count - 1) do (append arrRefPic (fileList.item i))
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

fn fnOpenPic filePicPath =
(
	rolPreviewRef.btn_LengthDistance.image = \
	(dotNetclass "System.Drawing.Image").fromfile filePicPath

	rolPreviewRef.title = getfilenamefile  filePicPath
	-- rolPreviewRef.width = rolPreviewRef.btn_LengthDistance.image.width
	-- rolPreviewRef.height = rolPreviewRef.btn_LengthDistance.image.height + 30
	rolPreviewRef.btn_LengthDistance.width = rolPreviewRef.btn_LengthDistance.image.width
	rolPreviewRef.btn_LengthDistance.height = rolPreviewRef.btn_LengthDistance.image.height
	rolPreviewRef.dn_flp.width = rolPreviewRef.btn_LengthDistance.image.width
    rolPreviewRef.dn_flp.height = rolPreviewRef.btn_LengthDistance.image.height
)

rollout rolPreviewRef ""
(
	dotNetControl dn_flp "flowlayoutpanel" pos:[0,30]
    dotNetControl btn_LengthDistance "System.Windows.Forms.button" pos:[0,30]
    
    button btnPrePic "←" width:30 height:20 pos:[5,5]
    button btnNextPic "→" width:30 height:20 pos:[40,5]

    slider sldRefFrame "" orient:#horizontal  ticks:0 range:[1,1,1] pos:[80,5] width:100


	on rolPreviewRef open do
	(
		btn_LengthDistance.margin =  dotnetobject "padding" 0
		btn_LengthDistance.FlatAppearance.BorderSize = 1
		btn_LengthDistance.flatstyle = (dotNetclass "FlatStyle").flat

		dn_flp.Controls.Clear()
		dn_flp.SuspendLayout()
		dn_flp.controls.addrange #(btn_LengthDistance)
        dn_flp.resumelayout()
        
        sldRefFrame.range = [1,arrRefPic.count,1]

        rolPreviewRef.btn_LengthDistance.width = 0
        rolPreviewRef.btn_LengthDistance.height = 0
        rolPreviewRef.dn_flp.width = 0
        rolPreviewRef.dn_flp.height = 0
    )

    on btnPrePic pressed do 
    (
        print numCurrentPic
        if ((arrRefPic.count != 0) and (arrRefPic[1] != undefined)) then 
        (
            case of
            (
                (numCurrentPic == 1):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic = arrRefPic.count)
                (numCurrentPic <= arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic -= 1)
                (numCurrentPic > arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic-1];numCurrentPic -= 1)
            )            
        )
        
    )

    on btnNextPic pressed do 
    (
        print numCurrentPic
        case of
        (
            (numCurrentPic == 1):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic += 1)
            (numCurrentPic < arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic += 1)
            (numCurrentPic == arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic = 1)
            (numCurrentPic > arrRefPic.count):(fnOpenPic arrRefPic[1];numCurrentPic = 1)
        )  
        
    )

    on sldRefFrame changed val do
    (
        fnOpenPic arrRefPic[val]
    )

)

createdialog rolPreviewRef width:300 height:200