/*
 * @Description: 安装UI修改自网上分享的 Rush hour Package.mzp
 * @Author: Bullet.S
 * @Date: 2020-12-20 00:51:15
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-20 22:02:23
 * @Email: animator.bullet@foxmail.com
 */

try(destroyDialog rolBsInstall)catch()

Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global iniAddToolbars
global myfgColor
global myClickColor
Global posMouMoved = [0,0]
Global switchMouState = false
Global SIOFile = dotNetClass "System.IO.File"			---文件操作
Global SIODir = dotNetClass "System.IO.Directory"		---文件夹操作

global nameBsScript = "BulletKeyTools"
Global msBullet = "BulletKeyTools.ms"
Global tempScriptDir = ((getdir #temp) + "\\" + nameBsScript)

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
			myfgColor    = (color 255 255 0)
			myClickColor = (color 0 255 127)
		)
	)
	else
	(
		myfgColor    = (color 255 255 0)
		myClickColor = (color 0 255 127)
	)
)
fnGetColorTheme() ----获取当前主题是深色还是浅色,来更改文字颜色

fn fnDelFilePath targetDel =  --删除文件
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

fn fnCopyDirectory sourceDir targetDir = 
(
	local SearchOption = dotNetClass "System.IO.SearchOption"
	local allFiles     = SIODir.GetFiles sourceDir \
										"*.*" \
										SearchOption.AllDirectories

	for sourceFile in allFiles do
	(
		local targetFile    = targetDir + (substring sourceFile (sourceDir.count + 1) -1)
		local targetFileDir = getFilenamePath targetFile
		if (not (SIODir.Exists targetFileDir)) do (SIODir.CreateDirectory targetFileDir)
		fnDelFilePath targetFile
		SIOFile.Copy sourceFile targetFile
	)
)
----------------------------------------------------------------------------------------------------------------------------------------

rollout rolBsInstall " BulletScripts 通用安装工具 " width:380 height:185
(
	local textUpdateLink = (" BulletScripts 通用安装工具 ")

	dotNetControl tbxResult "System.Windows.Forms.Textbox" readonly:true Multiline:true height:105 width:155 pos:[10,25]
	ProgressBar pbInstall "" pos:[355,10] width:20 height:125 orient:#vertical color:(color 240 248 255)
	timer tmrInstall active: false interval:10
	button btnInstall "" pos:[180,25] width:165 height:25 enabled:true tooltip:"安装工具并随MAX启动"
	button btnUpdateLink "查看更新和介绍" pos:[180,55] width:165 height:25 enabled:true tooltip:"查看更新下载和介绍，跳转B站"
	button btnJoinGroup "交流分享群" pos:[180,85] width:80 height:25 tooltip:"点击加入个人业内交流群,谢绝广告"
	button btnExit "退出安装" pos:[265,85] width:80 height:25 tooltip:"点击退出安装"
	HyperLink lnkLink "--- | 2019.9  miHoYo_Bullet.S | ---"
	color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	pos:[180,115] address:"https://space.bilibili.com/2031113"
	GroupBox grbTips "" pos:[5,5] width:165 height:130
	GroupBox grbInstall " 中键此处关闭安装窗口 " pos:[175,5] width:175 height:130
	button btnBmp pos:[5,140] width:370 height:40 border:false enabled:false
	
	fn fn_updateInterface  logBox logMessage=
	(
		logBox.text = logMessage
	)
	
	fn fnInstall =
	(
		fnCopyDirectory tempScriptDir (getdir #maxroot)
	)

	fn addToolBarButton macro cat txt remove: false =
	(
		fn insertContent f data: "" find: "" rewrite: false =
		(						
			file = MemStreamMgr.openFile f
			size = file.size()
			MemStreamMgr.close file
					
			stream = openFile f mode:"r+"

			seek stream 0 
				
			mt = "\"Main Toolbar\""			
			skipToString stream mt
					
			exist = (skipToString stream find) == undefined
			
			previousContent = ""
			
			findPos = filePos stream
			
			if(not exist) do
			(							
				if(rewrite) do 
				(
					pos = findPos - find.count
					seek stream	0
					previousContent += readChars stream (pos)					
				)
				
				pos = findPos - (if(rewrite) then 0 else find.count)
			
				seek stream pos
				
				previousContent += readChars stream (size - pos)
										
				if(rewrite) do pos = 0
				
				seek stream pos
					
							
				format data to: stream
				format previousContent to: stream
			)
			
			close stream
			
			return not exist
		)
		
		try
		(
			f = cui.getConfigFile() 
			
			cui.loadConfig f
			cui.saveConfigAs f
			cui.loadConfig f
			
			l = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"0\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
			delBtnLine = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"77\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
			if(remove) then
			(			
				insertContent f find: delBtnLine rewrite: true
			)
			else
			(		
				insertContent f find: "</Items>" data: ("\t\t" + l + "\n")			
			)
			cui.loadConfig f
			--cui.setConfigFile f
			cui.saveConfigAs f
			--cui.loadConfig f
				
		) catch(messageBox "请手动处理Toolbar!             \r\n" title: "错误!")
	)

	on rolBsInstall open do
	(
		the_bmp = ((getdir #temp) + "\\logoBulletS.png")
		btnBmp.images = #(the_bmp, undefined, 1,1,1,1,1)
		tbxResult.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 240 248 255
		btnInstall.text = (nameBsScript + " 安装")
		rolBsInstall.grbTips.caption = textUpdateLink as string
		local logTips = "动画师定制脚本工具\r\n仅供学习交流, 禁止售卖\r\n活到老, K到老, 坚持热爱\r\n\r\n-... ..- .-.. .-.. . - .-.-.- ...\r\n作者: Bullet.S          2019.08\r\nanimator.bullet@foxmail.com"
		fn_updateInterface tbxResult logTips
	)
	
	on rolBsInstall close do
	(
		if (queryBox "是否立即清理安装缓存？      \r\n( 会清理max的temp目录 )\r\n        " \
		title:"清理安装缓存" beep:false) then
		(
			arrCleanFiles = getFiles (getDir #temp + "\\*.*")
			arrCleanDirs = getDirectories (getDir #temp + "\\*")
			for f in arrCleanFiles do
			(
				fnDelFilePath f
			)
			for d in arrCleanDirs do
			(
				dir = substring d 1 (d.count - 1)
				fnDelDir dir
			)
			print " BulletScripts 安装临时文件已清理! "
		)
	)
	
	-----------------------------------------------------------------------------------------
	on rolBsInstall mbuttondown pos do 
	(
		try (destroydialog rolBsInstall) catch ()
	)
	
	on rolBsInstall lbuttondown posMou do
	(
		posMouMoved = posMou
		switchMouState = on
	)
	
	on rolBsInstall lbuttonup posMou do
	(
		switchMouState = off
	)
	
	on rolBsInstall mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolBsInstall (mouse.screenpos - posMouMoved)			
		)
	)
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	on tmrInstall tick do 
	(
		local tempStr
		btnInstall.enabled = false
		v = mod tmrInstall.ticks 500.0
		
		if(v == 70.0) do
		(
			fnInstall()
		)
		
		if(v <= 100.0) then
		(
			try(pbInstall.value = v)catch()
			tempStr = ("安装进度：" + (v as integer) as string + "%")
			fn_updateInterface tbxResult \
		(tempStr + "\r\n\r\n" + tempStr + "\r\n\r\n" + tempStr + "\r\n\r\n" + tempStr)
		)
		else
		(		
			FileIn ((getDir #startupScripts) + "\\" + msBullet)			
			fn_updateInterface tbxResult ("安装进度：" + ((v - 1) as integer) as string + "%\r\n\r\n工具安装成功！\r\n\r\n-... ..- .-.. .-.. . - .-.-.- ...\r\n作者: Bullet.S          2019.08\r\nanimator.bullet@foxmail.com")
			tmrInstall.active = false
			btnInstall.enabled = true
			-- colorman.reInitIcons()
			if (queryBox "是否添加工具栏按钮？              \r\n(可能要等待约二十秒时间)\r\n        " \
			title:"添加工具栏按钮" beep:false) then
			(
				fn_updateInterface tbxResult ("工具栏按钮添加成功...\r\n\r\n安装已完成可退出。\r\n\r\n-... ..- .-.. .-.. . - .-.-.- ...\r\n作者: Bullet.S          2019.08\r\nanimator.bullet@foxmail.com")
				addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools" remove: true
				addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools"
				iniAddToolbars = 1
				SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
			)
		)
	)
	on btnInstall pressed do
	(
		btnInstall.enabled = false
		pbInstall.value = 0
		tmrInstall.active = true
		tmrInstall.ticks = 0
	)

	on btnExit pressed do (try(destroyDialog rolBsInstall)catch())

	on btnJoinGroup pressed do (shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")

	on btnUpdateLink pressed do (shellLaunch "https://space.bilibili.com/2031113" "")
)
createDialog rolBsInstall fgcolor:myfgColor style:#()