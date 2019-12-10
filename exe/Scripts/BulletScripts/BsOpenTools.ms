/*
* @Description: 快速打开max文件，并保存常用目录
* @Author: Bullet.S
* @Date: 2019-11-23 01:41:13
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-12-10 12:26:02
* @Email: animator.bullet@foxmail.com
*/


try(destroydialog rolBsOpenTools)catch()
try(destroydialog rolAddItem)catch()

struct itemsFolder (name,dir)

Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global iniPosOpenTools
Global iniWidthOpenTools  = 300
Global iniDesktop         = (itemsFolder name:"Desktop" dir:"")
Global posMouScreen       = mouse.screenpos
Global posMouMove         = [0,0]
Global switchMouState     = false
Global iniSelectedID      = 1
Global arrFolders         = #()
Global arrFoldersName     = #()
Global arrFiles           = #()
Global arrFilesName       = #()
Global dirLiked           = ""
Global dirOpened          = ""
Global arrDirItems        = #()
Global arrPreItems        = #()
Global iniLikedFolder     = #()
Global iniFilterPrefix    = #()
Global arrRecentFiles     = #()
Global arrRecentFilesName = #()
Global arrFileType        = #(".max",".fbx",".bip",".ms*")
Global rolBsOpenTools
Global fnRefreshList
Global tempLastFolder

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if ((nameAttr == "LikedFolder") or (nameAttr == "Desktop"))then
	(
		attr = substituteString attr "dir:" "dir:@"
	)
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnSaveConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
	iniPosOpenTools   = fnGetConfig iniPosOpenTools "BsOpenToolsSet" "PosOpenTools" (posMouScreen as string)
	iniSelectedID     = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
	iniLikedFolder    = fnGetConfig iniLikedFolder "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
	iniFilterPrefix   = fnGetConfig iniFilterPrefix "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
	iniWidthOpenTools = fnGetConfig iniWidthOpenTools "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
	iniDesktop        = fnGetConfig iniDesktop "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BsOpenToolsSet"  "PosOpenTools" (iniPosOpenTools as string)
	SetINISetting BulletConfig "BsOpenToolsSet"  "SelectedID" (iniSelectedID as string)
	SetINISetting BulletConfig "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
	SetINISetting BulletConfig "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
	SetINISetting BulletConfig "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
	SetINISetting BulletConfig "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
)
---------------配合BulletTools工具的ini文件保存位置信息----------------------------------

rollout rolAddItem "添加" width:320 height:130
(
	groupbox gbxAddDir "添加常用目录 ---- Tips：右击选中条目删除" width:310 height:70 pos:[5,5]
	
	edittext edtAddDir "命名" pos:[10,25] fieldWidth:200 height:20 labelOnTop:false text:""
	button btnOpenDir "选择目录"  pos:[240,25] width:70 height:20 tooltip:"选择添加目录，默认打开当前文件目录"
	edittext edtDirStr "" pos:[5,50] fieldWidth:302 readOnly:true
	
	groupbox gbxAddPre "添加过滤前缀  ---------- Tips：右击框内条目删除 "  width:310 height:70 pos:[5,5]
	edittext edtPrefix ""  text:"" fieldWidth:302 height:25 pos:[5,35]

	groupbox gbxAddBtn ""  width:310 height:50 pos:[5,75]
	button btnAddItems "> > > > > > > >     ✚  添加  ✚     < < < < < < < <" width:300 height:35 pos:[10,85]

	on btnOpenDir pressed do 
	(
		local dir = getSavePath caption:"请选择目录:" initialDir:(maxFilePath)
		if (dir != undefined) then
		(
			edtDirStr.text = dir
		)
	)

	on edtAddDir changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtAddDir.text = tempText
		-- print edtAddDir.text
	)

	on edtPrefix changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtPrefix.text = tempText
		-- print edtPrefix.text
	)

	on btnAddItems pressed do 
	(
		if ((edtDirStr.text != "") and (edtAddDir.text != "") and (edtDirStr.visible == true)) then
		(
			local fnExist = 0
			for i = 1 to iniLikedFolder.count do 
			(
				if matchPattern iniLikedFolder[i].dir pattern:edtDirStr.text then 
				(
					fnExist = 1
				)
			)
			if fnExist == 0 then
			(
				append iniLikedFolder (itemsFolder edtAddDir.text edtDirStr.text)
				arrDirItems = #()
				for i = iniLikedFolder.count to 1 by -1 do
				(
					append arrDirItems iniLikedFolder[i].name
				)
				rolBsOpenTools.ddlLikedFolder.items = arrDirItems
				rolBsOpenTools.ddlLikedFolder.selection = 1
				rolBsOpenTools.ddlLikedFolder.tooltip = iniLikedFolder[iniLikedFolder.count].dir
				-- fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[rolBsOpenTools.rdoFileType.state]
			)
			else (messagebox "----------------------------------------\r\n可能常用目录中已存在此目录~")
		)
		if ((edtPrefix.text != "") and (edtPrefix.visible == true)) then
		(
			if (findItem iniFilterPrefix edtPrefix.text) != 0 then 
			(
				messagebox "-------------------------------------\r\n可能过滤词缀中已存在~"
			)
			else
			(
				append iniFilterPrefix edtPrefix.text
				arrPreItems = #()
				for i = iniFilterPrefix.count to 1 by -1 do
				(
					append arrPreItems iniFilterPrefix[i]
				)
				rolBsOpenTools.ltbFilterPrefix.items = arrPreItems
				rolBsOpenTools.ltbFilterPrefix.selection = 1
				-- fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[rolBsOpenTools.rdoFileType.state]
			)
		)
	)
)

rollout rolBsOpenTools "" width:300 height:370
(
	groupbox grpMain " 时光机_v0.1 --- 此处拖动,中键关闭,右击上层目录 " \
	width:290 height:365 pos:[5,0]
	editText edtBrowseFolder "" text:"" labelOnTop:true align:#right \
	height:20 fieldWidth:220 pos:[70,20] readOnly:true 
	button btnOpenAddress "..." align:#right tooltip:"左：选择打开目录\r\n右：打开右侧目录文件夹" \
	height:20 width:30 pos:[37,20] 
	-- button btnRemoveFolder "━" align:#left \
	-- height:20 width:25 pos:[10,20] tooltip:"删除选中的收藏目录"
	-- button btnAddFolder "✚" align:#left border:false \
	-- height:20 width:20 pos:[35,20] tooltip:"新增常用目录"
	button btnRefreshFolder "R" align:#left \
	height:20 width:25 pos:[10,20] tooltip:"左：刷新当前文件目录\r\n右：重置场景"
	button btnLikedFolder "↓ 添加常用 ↓" border:false \
	height:23 width:70 pos:[10,43] tooltip:"新增常用目录，右击选中条目删除"
	dropdownlist ddlLikedFolder "" align:#left selection:1 \
	height:15 width:70 pos:[10,70]
	listBox ltbFilesList "" align:#right selection:0 \
	height:20 width:205 pos:[85,70]
	button btnFilterPrefix "✚过滤词缀✚" border:false \
	height:20 width:70 pos:[10,95] tooltip:"左：添加过滤\r\n右：取消过滤\r\n选中过滤列表\r\n右击删除条目"
	listBox ltbFilterPrefix "" align:#left selection:0 \
	height:6 width:70 pos:[10,117]
	radioButtons rdoFileType "" columns:4 offsets:#([7,0],[7,0],[7,0],[7,0]) \
	pos:[82,48] labels:#(".max",".fbx",".bip",".ms") 
	button btnCountTips "" border:false enabled:false \
	height:20 width:70 pos:[10,339]

	button btnRecentFileDir "~念念不忘~" border:false \
	height:25 width:70 pos:[10,206] tooltip:"最近打开文件"
	button btnDesktopDir "• 希望之地 •" border:false \
	height:25 width:70 pos:[10,232] tooltip:"自定文件夹，默认桌面，右键可设"
	button btnAutobackDir "×崩坏神域×" border:false \
	height:25 width:70 pos:[10,258] tooltip:"自动保存目录"
	button btnScriptsDir "★逆商科技★" border:false \
	height:25 width:70 pos:[10,284] tooltip:"脚本文件夹\r\n左：根目录\r\n右：自启目录"
	button btnPreviewDir "<轮回梦境>" border:false \
	height:25 width:70 pos:[10,310] tooltip:"左：预览视频默认文件夹\r\n右：快速拍屏渲染预览动画"
	HyperLink lnkLink ""
	color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
	pos:[390,343] address:"https://space.bilibili.com/2031113"
	checkbutton ckbLockWidth "" pos:[88,339] width:16 height:20 border:false \
	toolTip:"是否解锁宽度调节\r\n右：重置宽度" checked:false
	slider sldSetWidth pos:[111,337] range:[300,500,iniWidthOpenTools] ticks:0 \
	width:184 type:#integer toolTip:"调节面板宽度,以显示更多字" enabled:false
	-- label labLogo "-------------------------  TECH OTAKUS SAVE THE WORLD -" pos:[12,365]
	------------------------------------------------- ↑ UI -------------------------------------
	
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

	fn fnGetLastFolder strFolder =
	(
		if ((strFolder != "") and (doesDirectoryExist strFolder)) then
		(
			local arrFilterStr = filterstring strFolder @"\"
			local strLastFolder = ""
			for i = 1 to (arrFilterStr.count - 1) do 
			(
				strLastFolder = strLastFolder  + arrFilterStr[i] + "\\"
			)
		)
		return strLastFolder
	)
	\
	fn fnRefreshList strFilesDir type:".max" =
	(
		arrFolders = #()
		arrFiles = #()
		arrFoldersName = #()
		arrFilesName = #()
		if ((strFilesDir != "") and (doesDirectoryExist strFilesDir)) then
		(
			local tempDir = GetDirectories (strFilesDir + "/*")
			for i in tempDir do 
			(
				append arrFolders (substring i 1 (i.count-1))
			)
			qsort arrFolders fnPseudoNaturalSort
			arrFilesBeforeFilter = getFiles (strFilesDir + "\\*" + type)
			qsort arrFilesBeforeFilter fnPseudoNaturalSort
			if (rolBsOpenTools.ltbFilterPrefix.selected != undefined) then
			(
				for i in arrFilesBeforeFilter do 
				(
					if (matchpattern (getfilenamefile i) \
					pattern:("*" + rolBsOpenTools.ltbFilterPrefix.selected + "*")) then 
					(append arrFiles i)
				)
			)
			else arrFiles = arrFilesBeforeFilter
			
			if arrFolders[1] != undefined then
			(
				for c in arrFolders do  --获取文件夹名字,后面切换脚本类别和列表会用到
				(
					append arrFoldersName ("○ " + (getFilenameFile c))
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
			rolBsOpenTools.edtBrowseFolder.text = strFilesDir
			for i = 1 to iniLikedFolder.count do 
			(
				if matchPattern iniLikedFolder[i].dir pattern:strFilesDir then 
				(
					rolBsOpenTools.ddlLikedFolder.selection = iniLikedFolder.count + 1 - i
					rolBsOpenTools.ddlLikedFolder.tooltip = iniLikedFolder[i].dir
				)
			)
		)
		else 
		(
			if ((iniSelectedID != 0) and (iniLikedFolder.count > 0)) then
			(
				rolBsOpenTools.ddlLikedFolder.selection = iniSelectedID
				fnRefreshList iniLikedFolder[iniLikedFolder.count + 1 - iniSelectedID].dir
				rolBsOpenTools.ddlLikedFolder.tooltip = iniLikedFolder[iniLikedFolder.count + 1 - iniSelectedID].dir
			)
		)
		btnCountTips.text = "文件：" + arrFiles.count as string
	)
	
	fn fnRefreshAddress =
	(
		if (maxFilePath != "") then 
		(
			local tempMaxFilePath = (substring maxFilePath 1 (maxFilePath.count-1))
			fnRefreshList tempMaxFilePath type:arrFileType[rdoFileType.state]
		)
		else 
		(
			if rolBsOpenTools.ddlLikedFolder.selection != 0 then 
			(
				local tempSelectionID = rolBsOpenTools.ddlLikedFolder.selection
				edtBrowseFolder.text = iniLikedFolder[iniLikedFolder.count + 1 - tempSelectionID].dir
			)
			else 
			(
				edtBrowseFolder.text = " ( 打开目录 )"
			)
		)
	)

	fn fnRefLikedFolderItems =
	(
		arrDirItems = #()
		if iniLikedFolder.count != 0 then
		(
			for i = iniLikedFolder.count to 1 by -1 do
			(
				append arrDirItems iniLikedFolder[i].name
			)
		)
		else 
		(
			ddlLikedFolder.tooltip = "请添加常用目录"
		)
		rolBsOpenTools.ddlLikedFolder.items = arrDirItems
	)

	fn fnRefreshFilterItems =
	(
		local arrPreItems = #()
		for i = iniFilterPrefix.count to 1 by -1 do
		(
			append arrPreItems iniFilterPrefix[i]
		)
		rolBsOpenTools.ltbFilterPrefix.items = arrPreItems
	)

	fn fnLoadBip fBip =
	(
		-- biped.loadBipFile <biped_ctrl> <file_name> \
		-- [#matchFileStruct] [#zeroHgt] [#noRedraw] \
		-- [#loadMaxObjects][#promptForDuplicates] [#retargetHeight] \
		-- [#retargetLimbSizes] [#scaleIKObjectSize] [#loadSubAnimControllers] \
		-- [#loadSelectedMaxObjects nodename_array] \
		-- [#loadSelectedSubAnimControllers bipednodename_array int_array]

		local numSelbiped = #()   -------判断选择了几个biped骨架
		if selection.count != 0 then
		(
			for i in (selection as array) where ((classof i == Biped_Object) and (i.ishidden == false)) do  
			(
				appendIfUnique numSelbiped i.controller.rootNode  --添加到骨架数组
			)
			for b in numSelbiped do 
			(
				biped.loadBipFile b.controller fBip #noRedraw
			)
		)
	)

	----------------------------------------------------------------------------------------------------
	
	on rolBsOpenTools open do 
	(
		sldSetWidth.value         = iniWidthOpenTools
		rolBsOpenTools.width      = iniWidthOpenTools
		btnRefreshFolder.images   = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,3,3,true,false)
		ckbLockWidth.images       = #("LockButtonExt_i.bmp","LockButtonExt_i.bmp",2,1,1,2,2,true,false)
		fnRefreshAddress ()
		fnRefreshList maxFilePath type: arrFileType[rdoFileType.state]
		btnCountTips.text = "文件：" + arrFiles.count as string
		fnSaveConfig ()  ---------------脚本位置等赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		fnRefLikedFolderItems ()
		ltbFilterPrefix.selection = 0
		fnRefreshFilterItems ()
		ddlLikedFolder.selection = iniSelectedID
	)

	on rolBsOpenTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosOpenTools   = (GetDialogPos rolBsOpenTools)
		iniSelectedID     = rolBsOpenTools.ddlLikedFolder.selection
		iniWidthOpenTools = sldSetWidth.value
		fnSetConfig ()
	)

	on sldSetWidth changed ticks do
	(
		rolBsOpenTools.width = ticks
	)
	------------------------------------------------------------------------------

	on rolBsOpenTools resized pos do
	(
		grpMain.width         = rolBsOpenTools.width - 10
		edtBrowseFolder.width = rolBsOpenTools.width - 80
		ltbFilesList.width    = rolBsOpenTools.width - 95
		if ((rolBsOpenTools.width >= 490) and (rolBsOpenTools.width <= 500)) then \
		lnkLink.caption = "---  | 2019.11  miHoYo_Bullet.S |  ---"
		else lnkLink.caption = ""
	)

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

	on rolBsOpenTools rbuttondown pos do 
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder type:arrFileType[rdoFileType.state]
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
		fnRefreshAddress ()
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
	)

	on btnRefreshFolder rightclick do 
	(
		CheckForSave ()
		resetMaxFile #noPrompt
		max tool maximize
	)

	on btnOpenAddress rightclick do 
	(
		if (doesDirectoryExist edtBrowseFolder.text) then
		(
			shellLaunch "explorer.exe" edtBrowseFolder.text
		)
	)

	on edtBrowseFolder changed txt do
	(
		fnRefreshList txt type:arrFileType[rdoFileType.state]
	)

	on rdoFileType changed state do
	(
		fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[state]
	)

	on ckbLockWidth changed state do 
	(
		if state == on then sldSetWidth.enabled = true 
		else sldSetWidth.enabled = false
	)

	on ckbLockWidth rightclick do
	(
		rolBsOpenTools.width = 300
		sldSetWidth.value    = 300
	)

	on btnOpenAddress pressed do 
	(
		dirOpened = getSavePath caption:"请选择Max文件路径:" initialDir:(maxFilePath)
		if (dirOpened != undefined) then
		(
			edtBrowseFolder.text = dirOpened
			fnRefreshList dirOpened type:arrFileType[rdoFileType.state]
		)
	)
	
	on btnLikedFolder pressed do 
	(
		try(destroydialog rolAddItem)catch()
		createdialog rolAddItem fgcolor:(color 255 20 100) pos:mouse.screenpos
		rolAddItem.gbxAddDir.visible  = true
		rolAddItem.edtAddDir.visible  = true
		rolAddItem.btnOpenDir.visible = true
		rolAddItem.edtDirStr.visible  = true
		rolAddItem.gbxAddPre.visible  = false
		rolAddItem.edtPrefix.visible  = false
	)

	on btnFilterPrefix pressed do 
	(
		try(destroydialog rolAddItem)catch()
		createdialog rolAddItem fgcolor:(color 255 20 100) pos:mouse.screenpos
		rolAddItem.gbxAddPre.visible  = true
		rolAddItem.edtPrefix.visible  = true
		rolAddItem.gbxAddDir.visible  = false
		rolAddItem.edtAddDir.visible  = false
		rolAddItem.btnOpenDir.visible = false
		rolAddItem.edtDirStr.visible  = false
	)

	on btnFilterPrefix rightclick do 
	(
		ltbFilterPrefix.selection = 0
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
	)

	on ddlLikedFolder selected id do
	(
		if iniLikedFolder[id] != undefined then
		(
			ddlLikedFolder.tooltip = iniLikedFolder[iniLikedFolder.count + 1 - id].dir
			fnRefreshList ddlLikedFolder.tooltip type:arrFileType[rdoFileType.state]
		)
		else ddlLikedFolder.tooltip = "请添加常用目录"
		iniSelectedID = id
	)

	on ddlLikedFolder rightclick do
	(
		idDel = iniLikedFolder.count + 1 - ddlLikedFolder.selection
		deleteItem iniLikedFolder idDel
		fnRefLikedFolderItems ()
	)

	on ltbFilterPrefix selected id do
	(
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
	)
	
	on ltbFilterPrefix rightclick id do
	(
		idDel = iniFilterPrefix.count + 1 - id
		deleteItem iniFilterPrefix idDel
		fnRefreshFilterItems ()
	)

	on ltbFilesList rightclick id do
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder type:arrFileType[rdoFileType.state]
	)

	on ltbFilesList doubleClicked id do
	(
		if (doesDirectoryExist edtBrowseFolder.text) then
		(
			if edtBrowseFolder.text == (getdir #preview) then ramplayer arrFiles[id] ""
			else 
			(
				case of
				(
					(id <= arrFolders.count):
					(
						edtBrowseFolder.text = arrFolders[id]
						fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
					)
					(id > arrFolders.count):
					(
						local idFile = id - arrFolders.count
						case of 
						(
							(rdoFileType.state == 1):
							(
								CheckForSave ()
								loadMaxFile (arrFiles[idFile]) useFileUnits:true quiet:true
							)
							(rdoFileType.state == 2):(importFile arrFiles[idFile] #noPrompt using:FBXIMP)
							(rdoFileType.state == 3):(fnLoadBip arrFiles[idFile])
							(rdoFileType.state == 4):(fileIn arrFiles[idFile])
						)
					)
				)
			)
		)
		else 
		(
			if edtBrowseFolder.text == "( 最近打开 Max 文件列表 )" then
			(
				if doesFileExist arrRecentFiles[id] then 
				(
					loadMaxFile (arrRecentFiles[id])
					local tempDir = getfilenamepath arrRecentFiles[id]
					fnRefreshList tempDir type:arrFileType[rdoFileType.state]
				)
			)
		)
	)

	on btnDesktopDir pressed do 
	(
		if iniDesktop.dir == "" then 
		(
			iniDesktop.dir = (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\")
		)
		fnRefreshList iniDesktop.dir type:arrFileType[rdoFileType.state]
	)

	on btnDesktopDir rightclick do 
	(
		dirOpened = getSavePath caption:"请设置桌面路径:" initialDir:(maxFilePath)
		if (dirOpened != undefined) then
		(
			iniDesktop.dir = dirOpened
			fnRefreshList iniDesktop.dir type:arrFileType[rdoFileType.state]
		)
	)

	on btnAutobackDir pressed do 
	(
		rdoFileType.state  = 1
		fnRefreshList (getdir #autoback) type:".max"
	)

	on btnScriptsDir pressed do
	(
		rdoFileType.state  = 4
		fnRefreshList (getdir #scripts) type:".ms*"
	)

	on btnScriptsDir rightclick do
	(
		rdoFileType.state  = 4
		fnRefreshList (getdir #startupScripts) type:".ms*"
	)

	on btnPreviewDir pressed do 
	(
		fnRefreshList (getdir #preview) type:".avi"
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
			else append arrRecentFilesName ("● (疑丢失) " + (getFilenameFile i) + ".max")
		)
		rdoFileType.state  = 1
		ltbFilesList.items = arrRecentFilesName
		edtBrowseFolder.text = "( 最近打开 Max 文件列表 )"
		btnCountTips.text = "文件：" + arrRecentFiles.count as string
	)
)
CreateDialog rolBsOpenTools pos:iniPosOpenTools fgcolor:(color 255 20 100) \
style:#() lockHeight:true

------------------------toolbar----------------------------------------------------
macroScript BsOpenTools
category:"_[BulletTools]"
buttonText:"时光机"
toolTip:"时光机"
-- Icon:#("Systems",2)
(
	on execute do
	(
		fileIn ((getDir #Scripts)+ "\\BulletScripts\\" + "BsOpenTools.ms")
	)
)
-------------------------------------------------------------------------------------