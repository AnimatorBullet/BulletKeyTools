/*
 * @Description: 快速打开max文件，并保存常用目录
 * @Author: Bullet.S
 * @Date: 2019-11-23 01:41:13
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-25 03:25:58
 * @Email: animator.bullet@foxmail.com
 */


try(destroydialog rolBsOpenTools)catch()
try(destroydialog rolAddItem)catch()

Global iniPosOpenTools
Global posMouScreen        = mouse.screenpos
Global posMouMove          = [0,0]
Global switchMouState      = false
Global iniSelectedID       = 1
Global arrFolders          = #()
Global arrFoldersName      = #()
Global arrFiles            = #()
Global arrFilesName        = #()
Global dirLiked            = ""
Global dirOpened           = ""
-- Global strAddDir           = ""
-- Global strAddName          = ""
-- Global strAddPre           = ""
Global arrDirItems         = #()
Global arrPreItems         = #()
Global itemsLikedFolder    = #()
Global itemLastLikedFolder = #()
Global itemsFilterPrefix   = #()
Global arrRecentFiles      = #()
Global arrRecentFilesName  = #()
Global arrFileType         = #(".max",".fbx",".bip",".xaf",".ms")
Global rolBsOpenTools

rollout rolAddItem "添加" width:320 height:150
(
	groupbox gbxAddDir "添加常用目录" width:260 height:70 pos:[50,5]
	
	edittext edtAddDir "命名" pos:[60,24] width:160 labelOnTop:false text:""
	button btnOpenDir "选择目录"  pos:[230,20] width:70 tooltip:"左：选择目录\r\n右:添加当前文件目录"
	edittext edtDirStr "" pos:[55,50] width:245 readOnly:true
	
	groupbox gbxAddPre "添加过滤前缀"  width:260 height:55 pos:[50,85]
	edittext edtPrefix ""  text:"" width:245 pos:[55,110]

	groupbox gbxAddBtn ""  width:40 height:135 pos:[5,5]
	button btnAddItems "✚" width:30 height:120 pos:[10,15]

	on btnOpenDir pressed do 
	(
		local dir = getSavePath caption:"请选择目录:" initialDir:(maxFilePath)
		if (dir != undefined) then
		(
			edtDirStr.text = dir + @"\"
		)
	)

	on btnAddItems pressed do 
	(
		if (edtDirStr.text != "") then
		(
			append itemsLikedFolder #(edtAddDir.text,edtDirStr.text)
			arrDirItems = #()
			for i = itemsLikedFolder.count to 1 by -1 do
			(
				append arrDirItems itemsLikedFolder[i][1]
			)
			rolBsOpenTools.ddlLikedFolder.items = arrDirItems
		)
		if (edtPrefix.text != "") then
		(
			append itemsFilterPrefix edtPrefix
			arrPreItems = #()
			for i = itemsFilterPrefix.count to 1 by -1 do
			(
				append arrPreItems itemsFilterPrefix[i]
			)
			rolBsOpenTools.ltbFilterPrefix.items = arrPreItems
		)
	)
)

rollout rolBsOpenTools "" width:320 height:365
(
	groupbox grpMain "快速打开_v0.1 ------------ 空白拖动,中键关闭 " width:310 height:360 pos:[5,0]
	
	editText edtBrowseFolder "" text:" ( 打开目录 )" labelOnTop:true align:#right \
	height:20 width:190 pos:[85,20] readOnly:true
	button btnOpenAddress "..." align:#right \
	height:20 width:30 pos:[280,20] 
	button btnRemoveFolder "━" align:#left border:false \
	height:20 width:20 pos:[10,20] tooltip:"左：删除选中目录\r\n右：清空目录列表（可撤销）"
	button btnAddFolder "✚" align:#left border:false \
	height:20 width:20 pos:[35,20] tooltip:"左：新增常用目录\r\n右：恢复上次删除目录列表"
	button btnRefreshFolder "R" align:#left border:false \
	height:20 width:20 pos:[60,20] tooltip:"刷新当前目录"
	button btnLikedFolder "↓ 常用目录 ↓" border:false \
	height:23 width:70 pos:[10,43]
	dropdownlist ddlLikedFolder "" align:#left selection:1 \
	height:15 width:70 pos:[10,70]
	listBox ltbFilesList "" align:#right selection:0 \
	height:20 width:225 pos:[85,70]
	button btnFilterPrefix "✚过滤前缀✚" border:false \
	height:20 width:70 pos:[10,95] tooltip:"左：添加过滤\r\n右：取消过滤\r\n选中过滤列表\r\n右击删除条目"
	listBox ltbFilterPrefix "" align:#left selection:0 \
	height:6 width:70 pos:[10,117]
	radioButtons rdoFileType "" columns:5 \
	pos:[85,48] labels:#(".max",".fbx",".bip",".xaf",".ms")
	button btnCountTips "" border:false enabled:false \
	height:20 width:70 pos:[10,335]

	button btnRecentFileDir "~回忆长河~" border:false \
	height:25 width:70 pos:[10,205] tooltip:"最近打开文件"
	button btnDesktopDir "• 希望之地 •" border:false \
	height:25 width:70 pos:[10,230] tooltip:"桌面文件夹"
	button btnAutobackDir "×崩坏神域×" border:false \
	height:25 width:70 pos:[10,255] tooltip:"自动保存目录"
	button btnScriptsDir "★逆商科技★" border:false \
	height:25 width:70 pos:[10,280] tooltip:"脚本文件夹\r\n左：根目录\r\n右：自启目录"
	button btnPreviewDir "<轮回梦境>" border:false \
	height:25 width:70 pos:[10,305] tooltip:"左：预览视频默认文件夹\r\n右：快速拍屏渲染预览动画"
	label labmiHoYo "- TECH OTAKUS SAVE THE WORLD -- Bullet.S -" \
	pos:[85,340]
	------------------------------------------------- ↑ UI -------------------------------------
	fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
	(
		attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
		if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
	)
	fn fnSaveConfig =  --引用上面方法提出需要的参数
	(----提出脚本位置
		iniPosOpenTools     = fnGetConfig iniPosOpenTools "BsOpenToolsSet" "PosOpenTools" (posMouScreen as string)
		iniSelectedID       = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		itemsLikedFolder    = fnGetConfig itemsLikedFolder "BsOpenToolsSet"  "LikedFolder" (itemsLikedFolder as string)
		itemsFilterPrefix   = fnGetConfig itemsFilterPrefix "BsOpenToolsSet"  "FilterPrefix" (itemsFilterPrefix as string)
		itemLastLikedFolder = fnGetConfig itemLastLikedFolder "BsOpenToolsSet"  "LastLikedFolder" (itemLastLikedFolder as string)
		itemLastLikedFolder = fnGetConfig itemLastLikedFolder "BsOpenToolsSet"  "LastLikedFolder" (itemLastLikedFolder as string)
	)
-- 	fnSaveConfig () --初始执行一遍
	fn fnSetConfig =  --保存参数,脚本位置
	(
		SetINISetting BulletConfig "BsOpenToolsSet"  "PosOpenTools" (iniPosOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "SelectedID" (iniSelectedID as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "LikedFolder" (itemsLikedFolder as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "FilterPrefix" (itemsFilterPrefix as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "LastLikedFolder" (itemLastLikedFolder as string)
	)
	---------------配合BulletTools工具的ini文件保存位置信息----------------------------------
	
	-- global charClass = dotNetClass "System.Char" --dotnet charclass used for isDigit comparisment
	-- dotNetClass:System.Char

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
-------------------------------------↑ 文件排序方法 --------------------------------------------------
	Fn fnLoadRecentFileList = -------获取最近打开文件列表
	(
		local recentfiles = (getdir #maxData) + "RecentDocuments.xml"
		if doesfileexist recentfiles then
		(
			arrRecentFiles     = #()
			arrRecentFilesName = #()
			xDoc = dotnetobject "system.xml.xmldocument"	
			xDoc.Load recentfiles
			Rootelement = xDoc.documentelement

			arrRecentFiles = for i = 0 to rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.count-1 collect 
			(
				rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.itemof[i].childnodes.itemof[3].innertext	
			)
			Return arrRecentFiles
			LRXML = Undefined
			XDoc = Undefined
			XDoc = nothing	
		)
		if arrRecentFiles[1] != undefined then
		(
			for c in arrRecentFiles do  --获取文件夹名字,后面切换脚本类别和列表会用到
			(
				append arrRecentFilesName ("○ " + (getFilenameFile (substring c 1 (c.count-1))))
			)
		)
	)

	fn fnRefreshList strFilesDir type:".max" =
    (
		arrFolders = #()
		arrFiles = #()
		arrFoldersName = #()
		arrFilesName = #()
		if strFilesDir != "" then
		(
			arrFolders = GetDirectories (strFilesDir + "/*");qsort arrFolders fnPseudoNaturalSort
			arrFiles = getFiles (strFilesDir + "\\*" + type);qsort arrFiles fnPseudoNaturalSort
			
			if arrFolders[1] != undefined then
			(
				for c in arrFolders do  --获取文件夹名字,后面切换脚本类别和列表会用到
				(
					append arrFoldersName ("○ " + (getFilenameFile (substring c 1 (c.count-1))))
				)
			)
			if arrFiles[1] != undefined then
			(
				for c in arrFiles do  --获取文件名字,后面切换脚本类别和列表会用到
				(
					append arrFilesName ("● " + (getFilenameFile c) + type)
				)
			)
			rolBsOpenTools.ltbFilesList.items = arrFoldersName + arrFilesName
			edtBrowseFolder.text = strFilesDir
		)
    )
	
	fn fnRefreshAddress =
	(
		if maxFilePath != "" then 
		(
			edtBrowseFolder.text = maxFilePath
		)
		else edtBrowseFolder.text = " ( 打开目录 )"
	)

	fn fnRefreshItems =
	(
		arrDirItems = #()
		if itemsLikedFolder.count != 0 then
		(
			for i = itemsLikedFolder.count to 1 by -1 do
			(
				append arrDirItems itemsLikedFolder[i][1]
			)
		)
		else 
		(
			ddlLikedFolder.tooltip = "请添加常用目录"
		)
		rolBsOpenTools.ddlLikedFolder.items = arrDirItems
	)
	----------------------------------------------------------------------------------------------------
	
	on rolBsOpenTools open do 
	(
		fnRefreshList maxFilePath
		fnRefreshAddress ()
		btnCountTips.text = "文件：" + arrFiles.count as string
		fnSaveConfig ()  ---------------脚本位置等赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		fnRefreshItems ()
		rolBsOpenTools.ddlLikedFolder.selection = iniSelectedID
		if iniSelectedID != 0 then
		(
			rolBsOpenTools.ddlLikedFolder.tooltip = itemsLikedFolder[iniSelectedID][2]
		)
		btnRefreshFolder.images = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,3,3,true,false)
	)

	on rolBsOpenTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosOpenTools = (GetDialogPos rolBsOpenTools)
		iniSelectedID   = rolBsOpenTools.ddlLikedFolder.selection
		fnSetConfig ()
	)
	------------------------------------------------------------------------------
	on rolBsOpenTools mbuttondown pos do 
	(
		try (destroydialog rolBsOpenTools) catch ()
		try(destroydialog rolAddItem)catch()
	)

	on rolBsOpenTools lbuttondown posMou do
	(
		posMouMove = posMou
		switchMouState = on
	)

	on rolBsOpenTools lbuttonup posMou do
	(
		switchMouState = off
	)

	on rolBsOpenTools mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolBsOpenTools (mouse.screenpos - posMouMove)			
		)
	)
	------------------------------------------------------------------------------

	on btnRefreshFolder pressed do 
	(
		if doesDirectoryExist rolBsOpenTools.edtBrowseFolder.text then
		(
			fnRefreshList rolBsOpenTools.edtBrowseFolder.text
		)
	)

	on edtBrowseFolder changed text do
	(
		if doesDirectoryExist rolBsOpenTools.edtBrowseFolder.text then
		(
			fnRefreshList rolBsOpenTools.edtBrowseFolder.text
		)
	)

	on rdoFileType changed state do
	(
		if doesDirectoryExist rolBsOpenTools.edtBrowseFolder.text then
		(
			fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[state]
		)
	)

	on btnOpenAddress pressed do 
    (
        dirOpened = getSavePath caption:"请选择Max文件路径:" initialDir:(maxFilePath)
        if (dirOpened != undefined) then
        (
            edtBrowseFolder.text = dirOpened
            fnRefreshList dirOpened
        )
	)
	
	on btnAddFolder pressed do 
	(
		createdialog rolAddItem fgcolor:(color 255 20 100)
		rolAddItem.edtPrefix.enabled = false
	)

	on btnFilterPrefix pressed do 
	(
		createdialog rolAddItem fgcolor:(color 255 20 100)
		rolAddItem.edtAddDir.enabled = false
		rolAddItem.btnOpenDir.enabled = false
		rolAddItem.edtDirStr.enabled = false
	)
	on ddlLikedFolder selected id do
	(
		if itemsLikedFolder[id] != undefined then
		(
			ddlLikedFolder.tooltip = itemsLikedFolder[itemsLikedFolder.count + 1 - id][2]
		)
		else ddlLikedFolder.tooltip = "请添加常用目录"
		iniSelectedID = id
	)

	on ltbFilesList doubleClicked id do
	(
		if edtBrowseFolder.text == "( 最近打开 Max 文件列表 )" then
		(
			loadMaxFile (arrRecentFiles[id])
		)
		else 
		(
			loadMaxFile (arrFiles[id])
		)
	)

	on btnDesktopDir pressed do 
	(
		rdoFileType.state  = 1
		fnRefreshList @"C:\Users\Administrator\Desktop\"
	)

	on btnAutobackDir pressed do 
	(
		rdoFileType.state  = 1
		fnRefreshList (getdir #autoback)
	)

	on btnScriptsDir pressed do
	(
		rdoFileType.state  = 5
		fnRefreshList (getdir #scripts) type:".ms*"
	)

	on btnScriptsDir rightclick do
	(
		rdoFileType.state  = 5
		fnRefreshList (getdir #startupScripts) type:".ms*"
	)

	on btnPreviewDir pressed do 
	(
		shellLaunch "explorer.exe" (getdir #preview)
	)

	on btnPreviewDir rightclick do 
	(
		createPreview percentSize:100 \
		dspGeometry:true dspShapes:false dspLights:false \
		dspCameras:false dspHelpers:false dspParticles:true dspBones:false \
		dspGrid:true dspSafeFrame:false dspFrameNums:false dspBkg:true \
		rndLevel:#smoothhighlights
	)

	on btnRecentFileDir pressed do 
	(
		fnLoadRecentFileList ()
		for i in arrRecentFiles do 
		(
			if doesFileExist i then
			(
				append arrRecentFilesName ("● " + (getFilenameFile i) + ".max")
			)
			else append arrRecentFilesName ("● " + (getFilenameFile i) + ".max  (疑似丢失)")
		)
		rdoFileType.state  = 1
		ltbFilesList.items = arrRecentFilesName
		edtBrowseFolder.text = "( 最近打开 Max 文件列表 )"
	)

)
CreateDialog rolBsOpenTools pos:iniPosOpenTools fgcolor:(color 255 20 100) style:#()