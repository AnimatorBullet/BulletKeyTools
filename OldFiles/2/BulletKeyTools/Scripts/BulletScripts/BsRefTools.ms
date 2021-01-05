/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-01-02 14:20:44
 * @Email: animator.bullet@foxmail.com
 */


try(destroydialog rolReferenceTools)catch()

global BulletKbdConfig = execute ("@\"" + (getDir #maxData) + "\\BulletKbdConfig.ini\"")

global dotDrawingImage = dotNetclass "System.Drawing.Image"
global dotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"
Global SIOFile         = dotNetClass "System.IO.File"

global numCurrentPic = 1
global tempSavePath  = (getdir #temp) + "\\tempReferencePic\\"

struct itemsFolder (name,dir)
global dateTime = (dotNetClass "System.DateTime").Now
global dayWeek  = #( "一", "二", "三", "四", "五", "六", "日")
Global iniPosRefTools
global iniRefFolder     = #()
global iniFilterRefName = #()
Global posMouMove       = [0,0]
Global arrRefType       = #("静帧","动图","视频","剪切板")

global myfgColor
global myClickColor

fn fnGetColorTheme =
(
	local curColorThemeFile = colorMan.getFileName()
	if (curColorThemeFile != undefined) then
	(
		if (matchpattern curColorThemeFile pattern:"*light*") then
		(
			myfgColor    = (color 65 105 225)
			myClickColor = (color 0 139 139)
		)
		else
		(
			myfgColor    = (color 219 209 72)
			myClickColor = (color 0 255 127)
		)
	)
	else
	(
		myfgColor    = (color 219 209 72)
		myClickColor = (color 0 255 127)
	)
)
fnGetColorTheme() ----获取当前主题是深色还是浅色,来更改文字颜色

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnSaveConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
    iniPosRefTools   = fnGetConfig iniPosRefTools "BsRefToolsSet" "PosRefTools" (mouse.screenpos as string)
    iniRefFolder     = fnGetConfig iniRefFolder "BsRefToolsSet"  "RefFolder" (iniRefFolder as string)
    iniFilterRefName = fnGetConfig iniFilterRefName "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BsRefToolsSet"  "PosRefTools" (iniPosRefTools as string)
	SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder" (iniRefFolder as string)
	SetINISetting BulletConfig "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
)
---------------配合BulletTools工具的ini文件保存位置信息--------------------
fn fnDelFileDir targetDel =  --删除文件
(
	if (SIOFile.Exists targetDel == true) then ---判断是否存在文件
	(
		if getFileAttribute targetDel #readOnly == true or \
		getFileAttribute targetDel #hidden == true do --修改只读或者隐藏属性
		(
			setFileAttribute targetDel #readOnly false ; \
			setFileAttribute targetDel #hidden false
		)
		try (SIOFile.Delete(targetDel);(print ("已删除: "+ filenameFromPath targetDel)))
		catch (print ("删除失败: "+ filenameFromPath targetDel + ". 请尝试手动删除.");print "删除失败")
	)
)

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

fn fnGetClipboardPic =
(
    
    if dotNetClipboard.ContainsFileDropList() do ---获取剪切板的本地图片, 可多个
    (
        arrRefPic = #()
        fileList = dotNetClipboard.GetFileDropList()
        -- for i = 0 to (fileList.count - 1) do (fnCreateRefPlane (fileList.item i))
        for i = 0 to (fileList.count - 1) do (append arrRefPic (fileList.item i))
    )
)

rcmenu RCmenuRefConfig
(
	local myMs = (getDir #Scripts)+ "\\BulletScripts\\" + "BsReferenceTools.ms"
    local startupPath = (getDir #StartupScripts)+ "\\" + "BsReferenceTools.ms"

    subMenu "初见"
    (menuItem menuTips1 "    双击文件创建参考" enabled:false
    menuItem menuTips2 "    右击文件打开菜单" enabled:false)

    subMenu "工具栏按钮"
    (menuItem submConfigAddToolBar "添加"
    menuItem submConfigDelToolBar "去除")

    subMenu "自启"
    (menuItem submConfigAutoLoad "是否自启")
    
    menuItem menuJoinGroup "🐧交流小群"
    menuItem menuBilibili "📺Bullet.S"

    on RCmenuRefConfig open do
	(
		if(SIOFile.Exists startupPath) then (submConfigAutoLoad.checked = true)
		else (submConfigAutoLoad.checked = false)
	)
	on submConfigAutoLoad picked do 
	(
		if (submConfigAutoLoad.checked == true) then 
		(
			fnDelFileDir startupPath
			submConfigAutoLoad.checked = false
		)
		else 
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				SIOFile.Copy myMs startupPath
				(messagebox ("已打开自启: " + filenameFromPath startupPath \
				+ "        \r\n") beep:false title:"开启自启")
				submConfigAutoLoad.checked = true
			)
		)
	)

	on menuJoinGroup picked do 
	(
		if (queryBox "是否加入个人分享交流群？          \r\n(游戏，动画爱好者休闲吹水正能量分享群)\r\n        " \
		title:"加入交流群" beep:false) then
		(
		shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")
	)

	on menuBilibili picked do 
	(shellLaunch "https://space.bilibili.com/2031113" "")
)

rollout rolPreviewRef ""
(
	dotNetControl dn_flp "flowlayoutpanel" pos:[0,30]
    dotNetControl btn_LengthDistance "System.Windows.Forms.button" pos:[0,30]
    
    button btnPrePic "←" width:30 height:20 pos:[5,5]
    button btnNextPic "→" width:30 height:20 pos:[40,5]

    slider sldRefFrame "" orient:#horizontal  ticks:0 range:[1,1,1] pos:[80,5] width:100

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
        rolPreviewRef.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.height = rolPreviewRef.btn_LengthDistance.image.height
        rolPreviewRef.btn_LengthDistance.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.btn_LengthDistance.height = rolPreviewRef.btn_LengthDistance.image.height
        rolPreviewRef.dn_flp.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.dn_flp.height = rolPreviewRef.btn_LengthDistance.image.height
    )

	on rolPreviewRef open do
	(
        fnSaveClipBoardPic ()

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

rollout rolReferenceTools "BsRefTools_v0.1" width:340 height:337
(
	groupbox grpMain "" \
	width:330 height:332 pos:[5,0]
	editText edtBrowseFolder "" text:"" labelOnTop:true align:#right \
	height:20 fieldWidth:230 pos:[70,12] readOnly:true 
	button btnOpenAddress "..." align:#right tooltip:"选择打开目录" \
	height:20 width:30 pos:[37,12] 
	button btnOpenCurrentDir "打开" tooltip:"打开当前文件夹" \
	height:20 width:30 pos:[300,12] border:false
	button btnRefreshFolder "R" align:#left \
	height:20 width:25 pos:[10,12] tooltip:"左：刷新当前文件目录\r\n右：重置场景"
	button btnLikedFolder "↓添加常用↓" border:false \
	height:23 width:70 pos:[10,35] tooltip:"新增常用目录，右击选中条目删除"
	dropdownlist ddlLikedFolder "" align:#left selection:1 \
	height:15 width:70 pos:[10,62]
	listBox ltbFilesList "" align:#right selection:0 \
	height:18 width:245 pos:[85,62]
	button btnFilterPrefix "✚过滤词缀✚" border:false \
	height:23 width:70 pos:[10,87] tooltip:"左：添加过滤\r\n右：取消过滤\r\n选中过滤列表\r\n右击删除条目"
	listBox ltbFilterPrefix "" align:#left selection:0 \
	height:6 width:70 pos:[10,112]
	radioButtons rdoFileType "" columns:arrRefType.count \
	pos:[85,40] labels:arrRefType

	button btnRecentFileDir "最近打开" border:false \
	height:25 width:70 pos:[10,200] tooltip:"最近打开文件"
	button btnDesktopDir "桌面自定" border:false \
	height:25 width:70 pos:[10,226] tooltip:"自定文件夹，默认桌面，右键可设"
	button btnScriptsDir "脚本目录" border:false \
	height:25 width:70 pos:[10,252] tooltip:"脚本文件夹\r\n左：根目录\r\n右：自启目录"
	button btnAutobackDir "自动保存" border:false \
	height:25 width:70 pos:[10,278] tooltip:"自动保存目录"
	groupBox grpDate "" width:330 height:30 pos:[5,302]
	label lblCountTips "" height:15 width:80 pos:[15,312]
	label lblDateTime "" height:15 width:130 pos:[120,312] 
	HyperLink lnkLink "miHoYo_Bullet.S" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	pos:[245,312] address:"https://space.bilibili.com/2031113"

	fn getFilesequenceFile f &base &digits = 
	(
		f = getFilenameFile f
		base = trimRight f "0123456789"
		digits = subString f (base.count + 1) -1
	)

	fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
	(
		a = a as string
		b = b as string
		getFilesequenceFile a &aBase &aDigits
		-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
		-- things will fail if there's more digits.. 6 'seems' safe.
		aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
		getFilesequenceFile b &bBase &bDigits
		bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
		a = aBase + aDigits
		b = bBase + bDigits
	
		case of (
		(a == b): 0
		(a < b): -1
		(a > b): 1
		)
	)
-------------------------------------↑ 文件排序方法 -------------------------------
    fn fnRefreshAddress =
	(
        if rolReferenceTools.ddlLikedFolder.selection != 0 then 
        (
            local tempSelectionID = rolReferenceTools.ddlLikedFolder.selection
            edtBrowseFolder.text = iniRefFolder[iniRefFolder.count + 1 - tempSelectionID].dir
        )
        else (edtBrowseFolder.text = "（打开目录）")
    )
    
    fn fnRefreshFilterItems =
	(
		local arrRefTempItems = #()
        if iniFilterRefName.count != 0 then
		(
            for i = iniFilterRefName.count to 1 by -1 do
            (
                append arrRefTempItems iniFilterRefName[i]
            )
        )
        rolReferenceTools.ltbFilterPrefix.items = arrRefTempItems
    )
    
    on rolReferenceTools open do 
    (
        btnRefreshFolder.images   = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,3,3,true,false)
        btnOpenCurrentDir.images   = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,5,5,5,5,true,false)
        fnSaveConfig ()  ---------------脚本位置等赋值
        fnSetConfig ()  ----------------保存位置信息到ini文件
        ltbFilterPrefix.selection = 0
        lblCountTips.text = "文件：" + arrFiles.count as string
        lblDateTime.text = dateTime.Year as string + "/" + dateTime.Month as string + "/" \
		+ dateTime.Day as string + "  星期" + dayWeek[mod (getUniversalTime())[3] 7] as string
    )

    on rolReferenceTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosRefTools   = (GetDialogPos rolReferenceTools)
		fnSetConfig ()
	)

	on rolReferenceTools mbuttondown pos do 
	(
		try (destroydialog rolReferenceTools) catch ()
	)

	on rolReferenceTools lbuttondown posMou do
	(
		posMouMove = posMou + [0,20]
		switchMouState = on
	)

	on rolReferenceTools lbuttonup posMou do
	(
		switchMouState = off
	)

	on rolReferenceTools mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolReferenceTools (mouse.screenpos - posMouMove)			
		)
	)
	------------------------------------------------------------------------
)

createDialog rolReferenceTools menu:RCmenuRefConfig pos:iniPosRefTools \
fgcolor:myfgColor