/*
 * @Description: dotNet窗口修改自网上分享的 Rush hour Package.mzp, 其他基本重写
 * @Author: Bullet.S
 * @Date: 2019-11-10 12:37:34
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-10 17:58:58
 * @Email: animator.bullet@foxmail.com
 */

try(destroyDialog mzpDialog)catch()

Global arrLog = #()
Global mzpDialog
Global numVer = 7
Global posMouMoved = [0,0]
Global fnMouseState = false
Global fnAddUpdateLog
Global SIOFile = dotNetClass "System.IO.File"			---文件操作
Global SIODir = dotNetClass "System.IO.Directory"		---文件夹操作
-----------------------------------------------------------------------------------------------------------------INSTALL FILES
--these are the locations the mzp package extracted the files to
Global dirScripts = (getdir #scripts) + "\\BulletScripts\\"
Global file1 = "BulletKeyTools.ms"							----脚本主要文件
Global theMacroFile = "_[BulletTools]-BulletKeyTools.mcr"	----工具栏文件
Global arrScriptFiles = #(file1) 							----脚本数组
Global arrScriptDirs = #("BulletScripts") 	----脚本文件夹数组
Global arrIconsDirs = #("cstoolIcons")
Global numBgPic = 2
-----------------------------------------------------------------------------------------------------------------INSTALL FILES

fn fnAddUpdateLog arrLog =
(
-------------------------------------------------------↓ 添加更新记录描述 -----------------------------------------------------------------
	for i = numVer to 1 by -1 do
	(
		local str = "rollout rolLogV" + i as string + " \" v" + (i/10) as string + "." + ((mod i 10)as integer) as string + " \"\r\n(\r\n	label labelV" + i as string + " \"\" pos:[10,10] width:270 height:205 style_sunkenedge:true \r\n)"
		strRol = "rolLogV" + i as string
		strAdd = "append arrLog rolLogV" + i as string
		logRolTemp = (execute strRol) 
		logRolTemp = execute str
		execute strAdd
	)
	fn fnAddLogCap numLog caption =
	(
		local str = "rolLogV" + numLog as string + ".labelV" + numLog as string + ".caption = \"" + caption + "\""
		execute str
	)
	addSubRollout mzpDialog.srolUpdateLog  arrLog[1]  rolledUp:false
	if numVer > 1 then
	(
		for i = 2 to arrLog.count do
		(
			addSubRollout mzpDialog.srolUpdateLog arrLog[i] rolledUp:true
		)
	)
	fnAddLogCap 7 "2019..  v0.7\r\n\r\n1. 大优化大改版,整合更多功能"
)
----------------------------------------------------------------------------------------------------------------------------------------
fn fnDelFile fileDel =
(
	if (SIOFile.Exists fileDel) == true do
	(
		if getFileAttribute fileDel #readOnly == true or getFileAttribute fileDel #hidden == true do
		(
			setFileAttribute fileDel #readOnly false ; setFileAttribute fileDel #hidden false
		)
		try (SIOFile.Delete(fileDel);(print ("已删除: "+ filenameFromPath fileDel)))
		catch (print ("删除失败: "+ filenameFromPath fileDel + ". 请尝试手动删除.");print "删除失败")
	)
)

fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try (SIODir.Delete(dirDel) true;(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹")))
		catch (print ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.");print "删除失败")
	)
)

fn fnCopyFilesFromTo sDir tDir =
(
	local tempFilesArr = SIODir.GetFiles(sDir)
	for sFile in tempFilesArr do 
	( 
		local tFile = tDir + (substring sFile (sDir.count + 1) -1)
		SIOFile.Copy sFile tFile 
	)
)

rollout mzpDialog " BulletTools 安装工具 " width:500 height:385
(
	local textUpdateLink = (" BulletTools 安装 --- [ 当前版本 v"+ (numVer/10) as string + "." + ((mod numVer 10)as integer) as string + " ]")

	dotNetControl tbxResult "textBox" readonly:true Multiline:true height:100 width:195 pos:[10,25]

	button btnRemove "解除工具自启" pos:[22,160] width:170 enabled:false tooltip:"解除工具随MAX启动"
	button btnInstall "安装更新并自启" pos:[22,185] width:170 enabled:true tooltip:"安装工具并随MAX启动"
	button btnOpenFolder "打开脚本目录" pos:[22,210] width:170 enabled:true tooltip:"打开脚本目录"
	-- button btnUpdateLog "版本更新记录" pos:[22,235] width:170 enabled:true tooltip:"版本更新记录清单"
	button btnUpdateLink "查看更新和下载" pos:[22,235] width:170 enabled:true tooltip:"查看更新下载"
	HyperLink lnkLink "| 2019.9  miHoYo_Bullet.S |"
	color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
	pos:[40,260] address:"https://space.bilibili.com/2031113"
	label labmiHoYo "--- TECH OTAKUS SAVE THE WORLD --" pos:[15,280]
	GroupBox grbTips "" pos:[5,5] width:205 height:130
	GroupBox grbInstall " 安装 " pos:[5,140] width:205 height:160
	GroupBox grbUpdateLog " 更新记录 ------------中键此处关闭安装窗口" pos:[220,5] width:275 height:295
	subrollout srolUpdateLog "" pos:[225,23] width:265 height:270
	bitmap the_bmp pos:[5,303] width:490 height:80
	
	fn fnRefreshBG numBgPic =
	(
		the_bmp.fileName = (getdir #temp) + "\\BulletBgPic\\Background" + (random 1 numBgPic) as string + ".png"
	)
	--check if there are scriptfiles present in the userscripts-folder with the same names as the files we want to install
	fn fn_checkScriptFilePresence =
	(
		local dotNetStringArray = #()
		--test if the files are already present
		for strFile in arrScriptFiles do
		(
			if doesFileExist ((getDir #startupScripts)+"\\"+strFile) do
			(
				append dotNetStringArray (dotNetObject "system.string" strFile)
			)
		)
		dotNetStringArray
	)
	
	fn fn_updateInterface  logBox logMessage oldFileArray button1=
	(
		if oldFileArray.count > 0 do button1.enabled = true --if there are old files present, enable the button to remove them
		--populate the listboxes
		--display a message
		logBox.text = logMessage
	)
	
	on mzpDialog open do
	(
		local theArray = fn_checkScriptFilePresence()
		local logTips
		
		mzpDialog.grbTips.caption = textUpdateLink as string
		logTips = "K帧工具,集成各种K帧相关功能!\r\n\r\n活到老, 学到老, K到老!\r\n-... ..- .-.. .-.. . - .-.-.- ...\r\n\r\n作者: Bullet.S     插件诞生: 2019.10\r\n@Email: animator.bullet@foxmail.com"
		fn_updateInterface tbxResult logTips theArray btnRemove
		arrLog = #()
		-- if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog
		fnAddUpdateLog arrLog
		fnRefreshBG numBgPic
	)
	
	on mzpDialog close do
	(
		arrCleanFiles = getFiles (getDir #temp + "\\*.*")
		for f in arrCleanFiles do
		(
			fnDelFile f --delete any file with the same name on this location
		)
		arrCleanDirs = getDirectories (getDir #temp + "\\*")
		for d in arrCleanDirs do
		(
			dir = substring d 1 (d.count - 1)
			fnDelDir dir --delete any file with the same name on this location
		)
	)
	
		-----------------------------------------------------------------------------------------
	on mzpDialog mbuttondown pos do 
	(
		try (destroydialog mzpDialog) catch ()
	)
	
	on mzpDialog lbuttondown posMou do
	(
		posMouMoved = posMou
		fnMouseState = on
		fnRefreshBG numBgPic
	)
	
	on mzpDialog lbuttonup posMou do
	(
		fnMouseState = off
	)
	
	on mzpDialog mouseMove pos do
	(
		if fnMouseState == on then
		(
			SetDialogPos mzpDialog (mouse.screenpos - posMouMoved)			
		)
	)
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	
	on btnInstall pressed do
	(
		for strFile in arrScriptFiles do
		(
			fnDelFile ((getDir #startupScripts)+ "\\" + strFile)
			fnDelFile (dirScripts + strFile) --delete any file with the same name on this location
			copyFile ((getDir #temp)+ "\\" + strFile) ((getDir #startupScripts)+ "\\" + strFile) --move the file to the userscripts
			copyFile ((getDir #temp)+ "\\" + strFile) (dirScripts + strFile) --move the file to the userscripts
		)
		--process the macro
		for i in arrIconsDirs do
		(
			local strIconDir = (getdir #UI_ln) + "\\Icons\\" + i
			fnDelDir strIconDir
			fnCopyFilesFromTo ((getDir #temp)+ "\\" + i) ((getdir #UI_ln) + "\\Icons\\")
		)
		for i in arrScriptDirs do
		(
			SIODir.move(((getDir #temp)+ "\\" + i),(getdir #Scripts))
		)
		fnDelFile ((getDir #userMacros)+ "\\" + theMacroFile) --delete the macro
		copyFile ((getDir #temp) + "\\" + theMacroFile) ((getDir #userMacros)+ "\\" + theMacroFile) --move the macro to the usermacros
		--execute the macro. this puts the script in a button
		fileIn ((getDir #userMacros) + "\\" +theMacroFile)
		--update the interface
		local theArray = fn_checkScriptFilePresence()
		local myMessage = "工具安装成功. 你可以在\r\n \"Customize\" -- \"Customize user interface...\" -- \"Toolbars\" -- \"_[BulletTools]\" Category (最上) \r\n中找到,并拖到工具栏~"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		FileIn ((getDir #startupScripts) + "\\" + file1)
		fnRefreshBG numBgPic
	)

	on btnRemove pressed do
	(
		for strFile in arrScriptFiles do
		(
			fnDelFile ((getDir #startupScripts)+"\\"+strFile) --delete any file with the same name on this location
			--delete any file with the same name on this location
		)

		local theArray = fn_checkScriptFilePresence()
		local myMessage = "已解除该脚本自启\r\n( 并不是卸载~ )\r\n( 重新安装可打开自启 )"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		btnRemove.enabled = false
		fnRefreshBG numBgPic
	)
	
	on btnOpenFolder pressed do
	(
		ShellLaunch "explorer" dirScripts
		fnRefreshBG numBgPic
	)

	on btnUpdateLink pressed do  --左键点击跳转链接
	(
		shellLaunch "https://space.bilibili.com/2031113" ""
		fnRefreshBG numBgPic
	)
)
-- try(destroyDialog mzpInstall)catch()
createDialog mzpDialog fgcolor:(color 255 20 100) style:#()