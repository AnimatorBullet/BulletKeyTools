/*
* @Description: 关键帧小工具,逐渐丰富中
* @Author: Bullet.S
* @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-04-08 12:46:18
* @Email: animator.bullet@foxmail.com
*/

try(destroydialog rolBsKeyTools)catch()
try(destroydialog rolFnKeys)catch()
try(destroydialog rolAddMyScripts)catch()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnCheckUpdate.ms"))catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)

global curVerBsKeyTools = "0.9.6"
global verUrlBsKeyTools = "https://gitee.com/acebullet/BulletKeyTools/raw/master/_BsKeyTools/version.dat"
global dlUrlBsKeyTools = "https://gitee.com/acebullet/BulletKeyTools/raw/master/_BsKeyTools/_BsKeyTools%EF%BC%88%E8%A3%85%E5%AE%8C%E9%87%8D%E5%90%AFMAX,%E8%AF%AF%E6%9D%80%E8%AF%B7%E4%BF%A1%E4%BB%BB%EF%BC%89.exe"
global dlFileBsKeyTools = (getdir #temp) + "\\_BsKeyTools（装完重启MAX,误杀请信任）.exe"

struct myScript (id,msName,dir)

Global rolBsKeyTools
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global iniPos  	--位置保存记录
Global iniArrMyScripts   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global idBtn              = 1
global iniAutoCheckUpdate = true
Global switchToolPanel    = 0
global switchMSPanel      = 0
Global iniToolC1          = #(1,2,3,4,5,6,7,8,9,10,11,12)
Global iniToolC2          = #(1,2,3,4,5,6,7,8,9,10,11,12)
Global iniToolC3          = #(1,2,3,4,5,6,7,8,9,10,11,12)
Global iniToolC4          = #(1,2,3,4,5,6,7,8,9,10,11,12)
--------👆保存的设置参数------------------------------------------------------------
global myFgColor
global myClickColor
global myCheckedColor ----fnGetColorTheme.ms
Global posMouMoved       = [0,0]
Global switchMouseState  = false
Global switchSelKeyRange = 0
Global arrLastSelRange   = #()
Global switchAllKeyRange = 0
Global iniAddToolbars    = 0
Global arrLastAllRange   = #()
Global arrKeysTime       = #()  -----------biped和bone的首尾帧
Global arrLinkKeys       = #()  -----------存link帧
Global arrKeysSelected   = #()  -----------存选中的帧
global arrBlockingKeys   = #()  -----------选中或者所有物体的所有关键帧
global arrBoneEndAll     = #()  -----------末端骨骼临时层
Global arrToolC1         = #()
Global arrToolC2         = #()
Global arrToolC3         = #()
Global arrToolC4         = #()
Global keyFirst
Global keyEnd
Global keySelFirst
Global keySelEnd
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys
Global fnAddLinkTimesKeys
Global fnAddLinkParamsKeys
Global keyMovedOffset = 5
Global symbol ----选择的范围判断, 0左边,1右边,2全部
Global layerTraj --轨迹辅助层
Global arrTraj            = #()  ---轨迹存放数组, 方便删除
Global arrTempUnSelection = #()  ---隐藏未选中临时存放数组
Global menuSetFps
Global menuSetSpeed
Global SIOFile = dotNetClass "System.IO.File"
Global SIODir = dotNetClass "System.IO.Directory"
-- Global myTimer = dotnetobject "System.Timers.Timer" 500 autoreset:true
------------------全局变量-------------------------------------------------------------------

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if (nameAttr == "ArrMyScripts")then
	(
		attr = substituteString attr "dir:" "dir:@"
	)
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnLoadToolConfig =
(
	iniToolC1 = fnGetConfig iniToolC1 "BulletKeyToolsSet"  "iniToolC1" (iniToolC1 as string)
	iniToolC2 = fnGetConfig iniToolC2 "BulletKeyToolsSet"  "iniToolC2" (iniToolC2 as string)
	iniToolC3 = fnGetConfig iniToolC3 "BulletKeyToolsSet"  "iniToolC3" (iniToolC3 as string)
	iniToolC4 = fnGetConfig iniToolC4 "BulletKeyToolsSet"  "iniToolC4" (iniToolC4 as string)
)
fn fnLoadConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
	iniPos             = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" (mouse.screenpos as string)
	switchToolPanel    = fnGetConfig switchToolPanel "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
	switchMSPanel      = fnGetConfig switchMSPanel "BulletKeyToolsSet"  "MSPanel" (switchMSPanel as string)
	idBtn              = fnGetConfig idBtn "BulletKeyToolsSet"  "idBtn" (idBtn as string)
	iniArrMyScripts    = fnGetConfig iniArrMyScripts "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
	iniAutoCheckUpdate = fnGetConfig iniAutoCheckUpdate "BulletKeyToolsSet"  "AutoCheckUpdate" (iniAutoCheckUpdate as string)
	fnLoadToolConfig()
	if (iniArrMyScripts.count != 8) then
	(
		iniArrMyScripts = #((myScript id:1 msName:"<＋＋>" dir:""), \
		(myScript id:2 msName:"<＋＋>" dir:""), \
		(myScript id:3 msName:"<＋＋>" dir:""), \
		(myScript id:4 msName:"<＋＋>" dir:""), \
		(myScript id:5 msName:"<＋＋>" dir:""), \
		(myScript id:6 msName:"<＋＋>" dir:""), \
		(myScript id:7 msName:"<＋＋>" dir:""), \
		(myScript id:8 msName:"<＋＋>" dir:""))
	)
)
fnLoadConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "MSPanel" (switchMSPanel as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "idBtn" (idBtn as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "AutoCheckUpdate" (iniAutoCheckUpdate as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "iniToolC1" (iniToolC1 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "iniToolC2" (iniToolC2 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "iniToolC3" (iniToolC3 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "iniToolC4" (iniToolC4 as string)
)
---------------配合BulletTools工具的ini文件保存位置信息-----------------

-------------------右键面板空白处设置---------------------------------------------------------
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

------------------添加toolbar-----------------------------------------------
iniAddToolbars  = fnGetConfig iniAddToolbars "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
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

rcmenu menuConfig
(
	local myMs = (getDir #Scripts)+ "\\BulletScripts\\BulletKeyTools.ms"
	local startupPath = (getDir #StartupScripts)+ "\\BulletKeyTools.ms"
	menuItem mItemHelpDoc "【必看帮助文档】"
	menuItem mItemIsStartup "是否随Max自启"
	menuItem mItemAddToolBarBtn "添加工具栏按钮"
	subMenu "更新设置"
	(
		menuItem mItemCheckUpdate "检查更新"
		menuItem mItemForceUpdate "强制更新"
		menuItem mItemAutoCheckUpdate "自动检测"
		menuItem mItemUpdateLog "更新记录"
	)
	menuItem mItemScriptsPath "脚本目录"
	menuItem mItemConfigFilePath "配置文件"
	separator menuSepUninstall
	menuItem mItemCleanVirus "杀毒方案"
	menuItem mItemClose "关闭工具"
	menuItem mItemUninstall "说了再见"
	subMenu "关于我"
	(
		menuItem mItemBilibili "Bilibili"
		menuItem mItemTwitter "Twitter"
		menuItem mItemQgroup "QQgroup"
	)

	on menuConfig open do
	(
		if(SIOFile.Exists startupPath) then (mItemIsStartup.checked = true)
		else (mItemIsStartup.checked = false)
		if (iniAddToolbars == 1) then (mItemAddToolBarBtn.checked = true)
		else (mItemAddToolBarBtn.checked = false)
		mItemAutoCheckUpdate.checked = iniAutoCheckUpdate
	)

	on mItemHelpDoc picked do 
	(shellLaunch "https://www.notion.so/bullet4869/BsKeyTools-17b5ba7c37ae45f6a69ce90f45fa0657" "")

	on mItemBilibili picked do 
	(shellLaunch "https://space.bilibili.com/2031113" "")

	on mItemTwitter picked do 
	(shellLaunch "https://twitter.com/aniBulletCom" "")

	on mItemScriptsPath picked do 
	(shellLaunch (getdir #Scripts) "")

	on mItemQgroup picked do
	(
		if (queryBox "是否加入个人分享交流群？\r\n\r\n(游戏，动画爱好者休闲吹水正能量分享群)\r\n\r\n子弹工具人(993590655)，确认可直接跳转链接~          \r\n        " \
		title:"加入交流群" beep:false) then
		(
		shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")
	)

	on mItemCleanVirus picked do
	(
		if (queryBox "是否跳转网页查看Max和Maya病毒解决方案合集?    " \
		title:"是否跳转网页" beep:false) then
		(shellLaunch "https://www.anibullet.com/post/6569.html" "")
	)

	on mItemConfigFilePath picked do
	(
		if (queryBox "是否打开配置文件目录？（配置文件：BulletConfig.ini）    " \
		title:"是否打开" beep:false) then
		(shellLaunch (getFilenamePath BulletConfig) "")
	)

	on mItemIsStartup picked do 
	(
		if (mItemIsStartup.checked == true) then 
		(
			fnDelFileDir startupPath
			mItemIsStartup.checked = false
		)
		else 
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				SIOFile.Copy myMs startupPath
				print ("已打开自启: " + filenameFromPath startupPath)
				mItemIsStartup.checked = true
			)
		)
	)

	on mItemAddToolBarBtn picked do
	(
		if (mItemAddToolBarBtn.checked == false) then 
		(
			addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools" remove: true
			addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools"
			mItemAddToolBarBtn.checked = true
			iniAddToolbars = 1
		)
		else
		(
			addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools" remove: true
			mItemAddToolBarBtn.checked = false
			iniAddToolbars = 0
		)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
	)

	on mItemCheckUpdate picked do 
	(fnCheckUpdate curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools isForceUpdate:false)

	on mItemForceUpdate picked do 
	(fnCheckUpdate curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools isForceUpdate:true)

	on mItemAutoCheckUpdate picked do 
	(
		if (mItemAutoCheckUpdate.checked == true) then (mItemAutoCheckUpdate.checked = false)
		else (mItemAutoCheckUpdate.checked = true)
		iniAutoCheckUpdate = mItemAutoCheckUpdate.checked
	)

	on mItemClose picked do 
	(
		try(destroydialog rolBsKeyTools)catch()
		try(destroydialog rolFnKeys)catch()
		try(destroydialog rolAddMyScripts)catch()
	)

	on mItemUninstall picked do
	(
		if (queryBox "是否彻底清除 BsKeyTools？          \r\n( 配置文件默认保留 )" \
		title:"有缘再会" beep:false) then
		(
			if (iniAddToolbars == 1) then 
			(
				addToolBarButton "BulletKeyTools" "BulletTools" "BulletKeyTools" remove: true
				iniAddToolbars = 0
				SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
			)
			if (SIOFile.Exists startupPath) do (fnDelFileDir startupPath)
			arrDelPath = #(((getDir #Scripts)+ "\\BulletScripts"),((getDir #maxroot) + "\\UI_ln\\Icons\\cstoolIcons"))
			for d in arrDelPath do (fnDelDir d)
			try(destroydialog rolBsKeyTools)catch()
			try(destroydialog rolFnKeys)catch()
			try(destroydialog rolAddMyScripts)catch()
			(messagebox "已清理干净，保留配置文件备用...    \r\n" beep:false title:"卸载成功！")
		)
	)

	on mItemUpdateLog picked do (FileIn ((getDir #scripts) + "\\BulletScripts\\UpdateLog.ms"))
)

-------------------帧率,播放速度--------------------------------------------------------------
Global valueFps
Global valuePlaySpeed = ""
Global strCurrentFps = framerate as string + "FPS"

rollout rolCustomFps ""
(
	edittext edtFpsValue "FPS: "  pos:[10,10] width:60 usePercentageWidth:true \
	percentageWidth:44.0 labelOnTop:false text:"60" bold:true readOnly:false --帧率数值
	button btnSetFps "Set" pos:[80,8]
	label labTips strCurrentFps

	on rolCustomFps open do 
	(
		edtFpsValue.text = framerate as string
		labTips.text = "当前:" + framerate as string + "FPS"
		valueFps = framerate as integer
	)

	on edtFpsValue entered val do 
	(
		if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer >= 0)) then
		(
			valueFps = (val as integer)
		)
		else messagebox "---------------------------\r\n请输入正确帧率数值\r\n"
	)
	on btnSetFps pressed do 
	(
		framerate = valueFps
		labTips.text = "当前:" + framerate as string + "FPS"
		slidertime -= 1
		slidertime += 1
	)
)

fn fnSetFps numFps =
(
	framerate = numFps
	valueFps = numFps
	strCurrentFps = numFps as string + "FPS"
	rolBsKeyTools.btnSetFps.text = strCurrentFps 
	slidertime -= 1
	slidertime += 1
)

fn fnRefFps =
(
	local arrMenuSetFps = #(menuSetFps.menuSet60Fps,menuSetFps.menuSet30Fps, \
							menuSetFps.menuSet24Fps,menuSetFps.menuCustomFps)
	for i in arrMenuSetFps do i.checked = false
	case of
	(
		(framerate == 60):(menuSetFps.menuSet60Fps.checked = true)
		(framerate == 30):(menuSetFps.menuSet30Fps.checked = true)
		(framerate == 24):(menuSetFps.menuSet24Fps.checked = true)
		default:(menuSetFps.menuCustomFps.checked = true)
	)
)

fn fnRefPlaySpeedValue =
(
	local arrMenuSetSpeed = #(menuSetSpeed.menuSet14Speed,menuSetSpeed.menuSet12Speed, \
		menuSetSpeed.menuSet1Speed,menuSetSpeed.menuSet2Speed,menuSetSpeed.menuSet4Speed)
		for i in arrMenuSetSpeed do i.checked = false
	case of
	(
		(timeConfiguration.playbackSpeed == 1):(valuePlaySpeed = "-1/4x-";menuSetSpeed.menuSet14Speed.checked =true)
		(timeConfiguration.playbackSpeed == 2):(valuePlaySpeed = "-1/2x-";menuSetSpeed.menuSet12Speed.checked =true)
		(timeConfiguration.playbackSpeed == 3):(valuePlaySpeed = "- 1x -";menuSetSpeed.menuSet1Speed.checked =true)
		(timeConfiguration.playbackSpeed == 4):(valuePlaySpeed = "- 2x -";menuSetSpeed.menuSet2Speed.checked =true)
		(timeConfiguration.playbackSpeed == 5):(valuePlaySpeed = "- 4x -";menuSetSpeed.menuSet4Speed.checked =true)
	)
)

fn fnSetSpeed numSpeed =
(
	timeConfiguration.playbackSpeed = numSpeed
	fnRefPlaySpeedValue ()
	rolBsKeyTools.btnSetSpeed.text = valuePlaySpeed
)

rcmenu menuSetFps
(
	menuItem menuCurrentFps "" enabled:false
	menuItem menuSet60Fps "- 60Fps -"
	menuItem menuSet30Fps "- 30Fps -"
	menuItem menuSet24Fps "- 24Fps -"
	separator menuSepCustom
	menuItem menuCustomFps "自定义帧率"

	on menuSetFps open do 
	(
		strCurrentFps = framerate as string + "FPS"
		menuSetFps.menuCurrentFps.text = "当前: " + framerate as string + "FPS"
		fnRefFps ()
		rolBsKeyTools.btnSetFps.text = strCurrentFps
	)

	on menuSet60Fps picked do 
	(
		fnSetFps 60
	)
	on menuSet30Fps picked do
	(
		fnSetFps 30
	)
	on menuSet24Fps picked do 
	(
		fnSetFps 24
	)

	on menuCustomFps picked do
	(
		try (destroyDialog rolCustomFps) catch()
		createdialog rolCustomFps 120 55 fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y]
	)
)

rcmenu menuSetSpeed
(
	menuItem menuCurrentSpeed "" enabled:false
	menuItem menuSet14Speed "-1/4x-"
	menuItem menuSet12Speed "-1/2x-"
	separator menuSepSpeedLow
	menuItem menuSet1Speed "- 1x -"
	separator menuSepSpeedHigh
	menuItem menuSet2Speed "- 2x -"
	menuItem menuSet4Speed "- 4x -"

	on menuSetSpeed open do 
	(
		fnRefPlaySpeedValue ()
		menuSetSpeed.menuCurrentSpeed.text = "当前: " + valuePlaySpeed
		rolBsKeyTools.btnSetSpeed.text = valuePlaySpeed
	)

	on menuSet14Speed picked do 
	(
		fnSetSpeed 1
	)
	on menuSet12Speed picked do
	(
		fnSetSpeed 2
	)
	on menuSet1Speed picked do 
	(
		fnSetSpeed 3
	)
	on menuSet2Speed picked do 
	(
		fnSetSpeed 4
	)
	on menuSet4Speed picked do 
	(
		fnSetSpeed 5
	)
)
------------------帧率,播放速度------------------------------------------------------------

rollout rolAddMyScripts "我的脚本" width:205 height:220
(
	label lblRename "↓请输入命名↓" pos:[20,5]
	label lblReDir "指定路径" pos:[115,5]
	label lblClearOneMs "!清除!" pos:[170,5]
	edittext edtRenameMs1 "1"  pos:[5,25] width:105 height:20 text:""
	edittext edtRenameMs2 "2"  pos:[5,45] width:105 height:20 text:""
	edittext edtRenameMs3 "3"  pos:[5,65] width:105 height:20 text:""
	edittext edtRenameMs4 "4"  pos:[5,85] width:105 height:20 text:""
	edittext edtRenameMs5 "5"  pos:[5,105] width:105 height:20 text:""
	edittext edtRenameMs6 "6"  pos:[5,125] width:105 height:20 text:""
	edittext edtRenameMs7 "7"  pos:[5,145] width:105 height:20 text:""
	edittext edtRenameMs8 "8"  pos:[5,165] width:105 height:20 text:""
	button btnReAddMs1 "..."  pos:[115,25] width:50 height:20 border:true
	button btnReAddMs2 "..."  pos:[115,45] width:50 height:20 border:true
	button btnReAddMs3 "..."  pos:[115,65] width:50 height:20 border:true
	button btnReAddMs4 "..."  pos:[115,85] width:50 height:20 border:true
	button btnReAddMs5 "..."  pos:[115,105] width:50 height:20 border:true
	button btnReAddMs6 "..."  pos:[115,125] width:50 height:20 border:true
	button btnReAddMs7 "..."  pos:[115,145] width:50 height:20 border:true
	button btnReAddMs8 "..."  pos:[115,165] width:50 height:20 border:true
	button btnClearMs1 "X" pos:[170,25]  width:30 height:20 border:true
	button btnClearMs2 "X" pos:[170,45]  width:30 height:20 border:true
	button btnClearMs3 "X" pos:[170,65]  width:30 height:20 border:true
	button btnClearMs4 "X" pos:[170,85]  width:30 height:20 border:true
	button btnClearMs5 "X" pos:[170,105]  width:30 height:20 border:true
	button btnClearMs6 "X" pos:[170,125]  width:30 height:20 border:true
	button btnClearMs7 "X" pos:[170,145]  width:30 height:20 border:true
	button btnClearMs8 "X" pos:[170,165]  width:30 height:20 border:true
	button btnDoit "!注意确认!" pos:[125,190] width:75 height:25 border:true
	button btnClearMyScripts "! 清除所有脚本引用 !" pos:[5,190] width:120 height:25 border:true

	fn fnRefreshBtnReAddMs btnMsName btnMsDir edtRenameMs id =
	(
		dirScript = getOpenFileName caption:"请选择添加的Max脚本:" historyCategory:"myScripts" \
		types:"ms(*.ms)|*.ms|mse(*.mse)|*.mse|All(*.*)|*.*" filename:(getDir #scripts + @"\") 
		if (dirScript != undefined) then
		(
			nameMyScript = getFilenameFile dirScript
			btnMsName.text = nameMyScript
			btnMsDir.text = "已修改"
			if iniArrMyScripts[id] != undefined then iniArrMyScripts[id].dir = dirScript
			else
			(
				append iniArrMyScripts (myScript id edtRenameMs.text dirScript)
			)
		)
		-- print dirScript
	)

	fn fnAddMsName id edtRenameMs =
	(
		if (iniArrMyScripts[id] != undefined) then
		(
			if edtRenameMs.text != "" then iniArrMyScripts[id].msName = edtRenameMs.text
			else iniArrMyScripts[id].msName = "<未定脚本>"
		)
	)

	fn fnRefreshMyScriptsUI =
	(
		local tempArrBtn = #(rolAddMyScripts.edtRenameMs1, \
		rolAddMyScripts.edtRenameMs2, \
		rolAddMyScripts.edtRenameMs3, \
		rolAddMyScripts.edtRenameMs4, \
		rolAddMyScripts.edtRenameMs5, \
		rolAddMyScripts.edtRenameMs6, \
		rolAddMyScripts.edtRenameMs7, \
		rolAddMyScripts.edtRenameMs8)

		for b = 1 to tempArrBtn.count do
		(
			if iniArrMyScripts[b] != undefined then
			(
				if iniArrMyScripts[b].msName != undefined then 
				(
					tempArrBtn[b].text = iniArrMyScripts[b].msName 
				)
				else tempArrBtn[b].text = ""
			)
		)
	)

	fn fnClearOneMs id =
	(
		iniArrMyScripts[id].msName = "<＋＋>"
		iniArrMyScripts[id].dir = ""
		execute ("rolAddMyScripts.edtRenameMs" + (id as string) + ".text = \"\"")
	)

	fn fnClearMyScripts = --清除脚本
	(
		--设置dotNet窗口元素
		local mb = dotNetClass "System.Windows.Forms.MessageBox"
		local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
		local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
		local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
		local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"

		local result = mb.show "确定清除所有引用的脚本按钮吗 ?" "自定脚本一键清除" buttons.YesNoCancel icons.Information defaultButton.Button3

		--选项按钮
		if ( result == dialogResult.Yes ) then
		(
			iniArrMyScripts = #((myScript id:1 msName:"<＋＋>" dir:""), \
			(myScript id:2 msName:"<＋＋>" dir:""), \
			(myScript id:3 msName:"<＋＋>" dir:""), \
			(myScript id:4 msName:"<＋＋>" dir:""), \
			(myScript id:5 msName:"<＋＋>" dir:""), \
			(myScript id:6 msName:"<＋＋>" dir:""), \
			(myScript id:7 msName:"<＋＋>" dir:""), \
			(myScript id:8 msName:"<＋＋>" dir:""))
			local arrMyScriptTemp = #(rolBsKeyTools.btnMyScripts1, \
			rolBsKeyTools.btnMyScripts2, \
			rolBsKeyTools.btnMyScripts3, \
			rolBsKeyTools.btnMyScripts4, \
			rolBsKeyTools.btnMyScripts5, \
			rolBsKeyTools.btnMyScripts6, \
			rolBsKeyTools.btnMyScripts7, \
			rolBsKeyTools.btnMyScripts8)
			local arrBtnTemp = #(rolAddMyScripts.edtRenameMs1, \
			rolAddMyScripts.edtRenameMs2, \
			rolAddMyScripts.edtRenameMs3, \
			rolAddMyScripts.edtRenameMs4, \
			rolAddMyScripts.edtRenameMs5, \
			rolAddMyScripts.edtRenameMs6, \
			rolAddMyScripts.edtRenameMs7, \
			rolAddMyScripts.edtRenameMs8)
			for b = 1 to arrMyScriptTemp.count do 
			(
				arrMyScriptTemp[b].text = "<＋＋>"
			)
			for b = 1 to arrBtnTemp.count do 
			(
				arrBtnTemp[b].text = "<＋＋>"
			)
		)
		else if ( result == dialogResult.No ) then
		(
			format "NO\n"
		)
		else if ( result == dialogResult.Cancel ) then
		(
			format "CANCEL\n"
		)
	)

	on rolAddMyScripts open do 
	(
		fnRefreshMyScriptsUI ()
	)

	on btnReAddMs1 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs1 btnReAddMs1 edtRenameMs1 1
	)

	on btnReAddMs2 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs2 btnReAddMs2 edtRenameMs2 2
	)

	on btnReAddMs3 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs3 btnReAddMs3 edtRenameMs3 3
	)
	on btnReAddMs4 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs4 btnReAddMs4 edtRenameMs4 4
	)
	on btnReAddMs5 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs5 btnReAddMs5 edtRenameMs5 5
	)
	on btnReAddMs6 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs6 btnReAddMs6 edtRenameMs6 6
	)
	on btnReAddMs7 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs7 btnReAddMs7 edtRenameMs7 7
	)
	on btnReAddMs8 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs8 btnReAddMs8 edtRenameMs8 8
	)

	on edtRenameMs1 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs1.text = tempText
	)

	on edtRenameMs2 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs2.text = tempText
	)

	on edtRenameMs3 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs3.text = tempText
	)
	on edtRenameMs4 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs4.text = tempText
	)
	on edtRenameMs5 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs5.text = tempText
	)
	on edtRenameMs6 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs6.text = tempText
	)
	on edtRenameMs7 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs7.text = tempText
	)
	on edtRenameMs8 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs8.text = tempText
	)

	on btnClearMs1 pressed do (fnClearOneMs 1)
	on btnClearMs2 pressed do (fnClearOneMs 2)
	on btnClearMs3 pressed do (fnClearOneMs 3)
	on btnClearMs4 pressed do (fnClearOneMs 4)
	on btnClearMs6 pressed do (fnClearOneMs 5)
	on btnClearMs7 pressed do (fnClearOneMs 6)
	on btnClearMs8 pressed do (fnClearOneMs 7)
	on btnClearMs9 pressed do (fnClearOneMs 8)

	on btnDoit pressed do
	(
		fnAddMsName 1 edtRenameMs1
		fnAddMsName 2 edtRenameMs2
		fnAddMsName 3 edtRenameMs3
		fnAddMsName 4 edtRenameMs4
		fnAddMsName 5 edtRenameMs5
		fnAddMsName 6 edtRenameMs6
		fnAddMsName 7 edtRenameMs7
		fnAddMsName 8 edtRenameMs8

		arrMyScriptTemp = #(rolBsKeyTools.btnMyScripts1, \
		rolBsKeyTools.btnMyScripts2, \
		rolBsKeyTools.btnMyScripts3, \
		rolBsKeyTools.btnMyScripts4, \
		rolBsKeyTools.btnMyScripts5, \
		rolBsKeyTools.btnMyScripts6, \
		rolBsKeyTools.btnMyScripts7, \
		rolBsKeyTools.btnMyScripts8)
		for b = 1 to arrMyScriptTemp.count do 
		(
			if iniArrMyScripts[b] != undefined then
			(
				if (iniArrMyScripts[b].msName != undefined) then 
				(
					arrMyScriptTemp[b].text = iniArrMyScripts[b].msName
				)
			)
		)
		try(destroydialog rolAddMyScripts)catch()
	)

	on btnClearMyScripts pressed do 
	(
		fnClearMyScripts ()
	)
)
---------------------滑动帧切换rollout---------------------------------
rollout rolFnKeys "滑动帧切换 v1.1" width:280 height:120
(
	group ""
	(
		checkbox chkLHand "左手" pos:[24,20] width:50 height:20 color:Blue
		checkbox chkRHand "右手" pos:[96,20] width:50 height:20 color:Green
		checkbox chkLFoot "左脚" pos:[24,55] width:50 height:20 color:Blue checked:true
		checkbox chkRFoot "右脚" pos:[96,55] width:50 height:20 color:Green checked:true
		button btnPlanted "固定关键帧" pos:[184,20] width:80 height:25 toolTip:"Set Planted Key"
		button btnSliding "滑动关键帧" pos:[184,50] width:80 height:25 toolTip:"Set Sliding Key"
		button btnFree "自由关键帧" pos:[184,80] width:80 height:25 toolTip:"Set Free Key"
		label lblMe "[2019.05.28]  Bullet.S" pos:[24,92] width:120 height:16 color:Green
	)
	
	Fn fnSetKeyType keyType = 
	(
		sliderTime = animationRange.start
		for obj in selection where ((classof obj.baseObject == Biped_Object) \
		and (biped.getCurrentLayer obj.controller == 0)) do
		(
			bipCtrl = obj.controller
			if chkLHand.checked then 
			(
				sel_obj1 = (biped.getNode bipCtrl #larm)
				k = numKeys sel_obj1.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj1.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj1)
								(keyType == 2):(biped.SetSlidingKey sel_obj1)
								(keyType == 3):(biped.SetFreeKey sel_obj1)
							)
						)
					)
			)
			if chkRHand.checked then 
			(
				sel_obj2 = (biped.getNode bipCtrl #rarm)
				k = numKeys sel_obj2.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj2.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj2)
								(keyType == 2):(biped.SetSlidingKey sel_obj2)
								(keyType == 3):(biped.SetFreeKey sel_obj2)
							)
						)
					)
			)
			if chkLFoot.checked then 
			(
				sel_obj3 = (biped.getNode bipCtrl #lleg)
				k = numKeys sel_obj3.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj3.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj3)
								(keyType == 2):(biped.SetSlidingKey sel_obj3)
								(keyType == 3):(biped.SetFreeKey sel_obj3)
							)
						)
					)
			)
			if chkRFoot.checked then 
			(
				sel_obj4 = (biped.getNode bipCtrl #rleg)
				k = numKeys sel_obj4.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj4.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj4)
								(keyType == 2):(biped.SetSlidingKey sel_obj4)
								(keyType == 3):(biped.SetFreeKey sel_obj4)
							)
						)
					)
			)
		)
	)
	
	on btnPlanted pressed  do
	(
		fnSetKeyType 1
	)
	
	on btnSliding pressed  do
	(
		fnSetKeyType 2
	)
	
	on btnFree pressed  do
	(
		fnSetKeyType 3
	)
)
-----------------------------------------------------------------

-------------主UI-----------------------------------------------------------------
rollout rolBsKeyTools "" width:200 height:228
(
	local strMainRol = ("BsKeyTools_v" + curVerBsKeyTools + "（中键关闭）")
	---------------------------------UI--------------------------------------
	groupbox gbxMainUI strMainRol pos:[5,5] width:190 height:192
	
		-- label lblRangeStartText "起始帧" pos:[15,21] width:80 height:20
		-- label lblRangeEndText "结束帧" pos:[65,21] width:80 height:20
		spinner spiStartTime "" pos:[10,21] width:60 height:20 type:#integer \
		range:[-999999999,999999999,animationrange.start] scale:1
		spinner spiEndTime "" pos:[70,21] width:60 height:20 type:#integer \
		range:[-999999999,999999999,animationrange.end] scale:1
		button btnCutFrameDisplay "选定帧" pos:[10,40] width:45 height:20 \
		tooltip:"预览选择帧\r\n再点回到上次帧范围"
		button btnAllFrameDisplay "首尾帧" pos:[55,40] width:45 height:20 \
		tooltip:"预览全部帧\r\n再点回到上次帧范围"
		button btnZeroFrameDisplay "零" pos:[100,40] width:30 height:20 \
		tooltip:"显示0帧"
		button btnMagicBtn "" pos:[135,22] width:55 height:35   \
		tooltip:"点我点我点我~良心小工具" border:false
		-- edittext edtMoveKey "移动" width:70 usePercentageWidth:true percentageWidth:44.0 \ 
		-- pos:[10,70] labelOnTop:false text:"5f" bold:true readOnly:false 
		-- button btnSet5 "5f" width:35 pos:[90,67]
		-- button btnSetAdd "+5f" width:35 pos:[125,67]
		-- button btnSetOpposite "负" width:30 pos:[160,67]
		checkbutton btnJudgeLinkKey "Link?" highlightcolor:myCheckedColor \
		pos:[10,60] tooltip:"是否存在Link帧?" width:35 height:30 checked:false  
		button btnSelBeforeKeys "" \
		pos:[45,60] width:35 height:30 toolTip:"选择滑条前面关键帧"  
		button btnSelAllKeys "" \
		pos:[80,60] width:35 height:30 toolTip:"选择所有关键帧"  
		button btnSelAfterKeys "" \
		pos:[115,60] width:35 height:30 toolTip:"选择滑条后面关键帧"
		checkbutton ckbShadowCut "剪影" highlightcolor:myCheckedColor \
		pos:[150,60] width:40 height:30 toolTip:"切换剪影显示"
		-- button btnMoveKeys " " width:30 height:30 \
		-- pos:[160,93] toolTip:"移动关键帧,先左边选帧\r\n左：帧栏范围保持不变~\r\n右：帧栏范围同步增减~"  
		checkbutton ckbFnBoxDisplay "BOX显"  highlightcolor:myCheckedColor \
		width:45 height:25 toolTip:"骨骼切换Box显示" pos:[10,92]
		checkbutton ckbFreezeMesh "冻模型" highlightcolor:myCheckedColor \
		toolTip:"冻结解冻模型" width:45 height:25 pos:[55,92]
		checkbutton ckbHideBones "隐Bone" highlightcolor:myCheckedColor \
		width:45 height:25 toolTip:"显示隐藏 bone\r\n所在层若隐藏则不会显示" pos:[100,92]
		checkbutton ckbHideBiped "隐Bip" width:45 height:25 highlightcolor:myCheckedColor \
		toolTip:"显示隐藏 Bip\r\n所在层若隐藏则不会显示" pos:[145,92]
		button btnHotAnimBtn "命令集" pos:[10,117] width:45 height:25 \
		tooltip:"动画相关3dsMax自带功能集合"
		button btnTrajedit "轨迹线" pos:[55,117] width:45 height:25 \
		tooltip:"动画轨迹工具个人优化版"
		button btnHideUnSel "隐未选" pos:[100,117]width:45 height:25 \
		toolTip:"隐藏当前显示的未选中物体，右键可重新显示"
		button btnFileOpen "时光机" pos:[145,117] width:45 height:25 \
		tooltip:"快速打开max文件\r\n可收藏常用目录" 
		checkButton ckbPlayBlocking "跳帧播" pos:[10,142] width:45 height:25 
		highlightcolor:myCheckedColor tooltip:"点击预览关键帧 Blocking 动画\r\n若有 Link 帧需要按下上面按钮" checked:false
		timer clock "PlayClock" interval:1 active:false
		button btnSpringMagic "飘带解" pos:[55,142] width:45 height:25 \
		tooltip:"左点新版,右点旧版" 
		button btnCSTools "CS选择" pos:[100,142] width:45 height:25 \
		toolTip:"快速选择CS骨骼和调Biped等" 
		button btnAnimCopyPaste "暴力贴"  pos:[145,142] width:45 height:25 \
		toolTip:"动画暴力粘贴(待优化)" 
		button btnLayerManager "层" pos:[10,167] width:22.5 height:25 \
		toolTip:"模拟旧版层管理器" 
		button btnPoseTool "库" pos:[32.5,167] width:22.5 height:25 \
		toolTip:"参考库工具,待完善"
		button btnQuickSave "快备份" pos:[55,167] width:45 height:25 \
		toolTip:"快速备份" 
		button btnSetFps "" pos:[100,167] width:45 height:25 \
		toolTip:"设置帧率" 
		button btnSetSpeed "" pos:[145,167] width:45 height:25 \
		toolTip:"设置播放速度" 
	
	groupbox gbxMinTools "" pos:[200,5] width:130 height:220
	
		checkbutton ckbC1 "坚" width:30 height:25 highlightcolor:myCheckedColor \
		pos:[205,15] toolTip:"" border:false
		checkbutton ckbC2 "持" width:30 height:25 highlightcolor:myCheckedColor \
		pos:[235,15] toolTip:"" border:false
		checkbutton ckbC3 "热" width:30 height:25 highlightcolor:myCheckedColor \
		pos:[265,15] toolTip:"" border:false
		checkbutton ckbC4 "爱" width:30 height:25 highlightcolor:myCheckedColor \
		pos:[295,15] toolTip:"" border:false

		local btnHeight = 30
		local btnWidth = 60
		local btnPos = [999999,999999]
		button btnTemp "待添加" width:btnWidth height:btnHeight visible:false \
		tooltip:"待添加" pos:btnPos
		button btnTemp2 "待添加" width:btnWidth height:btnHeight visible:false \
		tooltip:"待添加" pos:btnPos
		button btnColorTools "颜色渐变" width:btnWidth height:btnHeight visible:false \
		tooltip:"做 Demo 素模或特效方便~" pos:btnPos
		checkbutton ckbIsoMesh "模型独显" width:btnWidth height:btnHeight visible:false \
		toolTip:"单独显示模型预览" pos:btnPos highlightcolor:myCheckedColor 
		button btnBipedTraj "Biped轨迹" width:btnWidth height:btnHeight visible:false \
		toolTip:"左：切换显示单个Biped轨迹,\r\n右：清除添加的所有Biped轨迹~" pos:btnPos
		button btnFnFrame "整小数帧" width:btnWidth height:btnHeight visible:false \
		tooltip:"整数小数帧切换,\r\n平滑拖帧看卡顿" pos:btnPos
		button btnSelByColor "同色选择" width:btnWidth height:btnHeight visible:false \
		tooltip:"选择同颜色物体" pos:btnPos
		button btnFnTCB "TCB/欧拉" width:btnWidth height:btnHeight visible:false \
		tooltip:"欧拉和TCB互转" pos:btnPos
		button btnEulerFilter "欧拉过滤" width:btnWidth height:btnHeight visible:false \
		tooltip:"Bone骨骼过滤欧拉旋转" pos:btnPos
		button btnImageComp "构图辅助" width:btnWidth height:btnHeight visible:false \
		tooltip:"各种经典分割视图以辅助构图" pos:btnPos
		button btnDelOutKeys "清所有帧" width:btnWidth height:btnHeight visible:false \
		toolTip:"清除所有帧\r\nLink帧请手动删" pos:btnPos
		button btnCleanOutKeys "清无限帧" width:btnWidth height:btnHeight visible:false \
		toolTip:"清范围外帧(无限帧)" pos:btnPos
		button btnSelBiped "选择Biped" width:btnWidth height:btnHeight visible:false \
		toolTip:"选择所有biped" pos:btnPos
		button btnSelBone "选择Bone" width:btnWidth height:btnHeight  visible:false \
		toolTip:"选择所有bone" pos:btnPos
		button btnEndBone "增删末端" width:btnWidth height:btnHeight visible:false \
		toolTip:"添加选择的Bone末端，可回退\r\n右键清除（注意 \"tempBoneEndAll\" 层）" pos:btnPos
		button btnQuickPrev "快速拍屏" width:btnWidth height:btnHeight visible:false \
		toolTip:"左：快速拍屏预览\r\n右：打开预览文件夹" pos:btnPos
		button btnFastAlign "快速对齐" width:btnWidth height:btnHeight visible:false \
		toolTip:"功能待添加" pos:btnPos
		button btnFnKeyType "改滑动帧" width:btnWidth height:btnHeight visible:false \
		toolTip:"批量转换滑动关键帧等,\r\n后续可能按需优化更多设置" pos:btnPos
		button btnRenameTools "改名工具" width:btnWidth height:btnHeight visible:false \
		toolTip:"超级重命名工具" pos:btnPos
		button btnMeshTools "模型整理" width:btnWidth height:btnHeight visible:false \
		toolTip:"功能待添加" pos:btnPos
		button btnAnimMirror "动画镜像" width:btnWidth height:btnHeight visible:false \
		toolTip:"目前引用4698to大佬的插件\r\n后面随缘新写或优化" pos:btnPos
		checkbutton ckbFnMtlDisplay "素模切换" width:btnWidth height:btnHeight visible:false \
		toolTip:"左:切换显示隐藏贴图,方便白模预览\r\n右:Clay显示开关(红色模型显示)\r\n暂不支持子材质和Vray材质..."
		pos:btnPos highlightcolor:myCheckedColor 
		button btnCutSequence "动画分段" width:btnWidth height:btnHeight visible:false \
		toolTip:"为长动画分段动作区间" pos:btnPos
		button btnMopherSlider "表情滑条" width:btnWidth height:btnHeight visible:false \
		toolTip:"选择带morpher的mesh，\r\n打开快速调节滑条方便K表情~" pos:btnPos
		button btnBipedScale "CS缩放" width:btnWidth height:btnHeight visible:false \
		toolTip:"效果展示可用，导入引擎别用\r\n再次点击可解除" pos:btnPos
		button btnBatchExport "批量导出" width:btnWidth height:btnHeight visible:false \
		toolTip:"批量导出" pos:btnPos
		button btnCameraFromView "视角相机" width:btnWidth height:btnHeight visible:false \
		toolTip:"根据自由视角创建相机" pos:btnPos
		button btnMeshToBone "碎块加骨" width:btnWidth height:btnHeight visible:false \
		toolTip:"破碎碎块快速加骨骼" pos:btnPos
		button btnLightTable "运动重影" width:btnWidth height:btnHeight visible:false \
		toolTip:"显示运动重影" pos:btnPos

		local btnMsWidth = 72.5
		checkbutton ckbSwitchMyScripts "切换" pos:[5,230] width:35 height:20
		tooltip:"切换自定义脚本按钮" border:true highlightcolor:myCheckedColor 
		button btnMyScripts1 "<＋＋>" pos:[40,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[1].dir border:true visible:false
		button btnMyScripts2 "<＋＋>" pos:[112.5,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[2].dir border:true visible:false
		button btnMyScripts3 "<＋＋>" pos:[185,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[3].dir border:true visible:false
		button btnMyScripts4 "<＋＋>" pos:[257.5,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[4].dir border:true visible:false
		button btnMyScripts5 "<＋＋>" pos:[40,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[5].dir border:true visible:false
		button btnMyScripts6 "<＋＋>" pos:[112.5,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[6].dir border:true visible:false
		button btnMyScripts7 "<＋＋>" pos:[185,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[7].dir border:true visible:false
		button btnMyScripts8 "<＋＋>" pos:[257.5,230] width:btnMsWidth height:20
		tooltip:iniArrMyScripts[8].dir border:true visible:false

	groupbox gbxTips "" pos:[5,195] width:155 height:30
	
		label lblLink "2019.9[miHoYo_Bullet.S]" pos:[15,205] width:140 height:15
		button btnConfig "设置" pos:[165,202] width:30 height:22 border:true

	local m_PBKeyTimeArray
	local m_PBKeyMiliSecArray
	local m_PBStartTime
	local m_PBPointer
----------------------------------UI及作者ID------------------------------------------------
	fn fnRefreshMsPanel =
	(
		if switchMSPanel == 0 then 
		(
			btnMyScripts1.visible = true
			btnMyScripts2.visible = true
			btnMyScripts3.visible = true
			btnMyScripts4.visible = true
			btnMyScripts5.visible = false
			btnMyScripts6.visible = false
			btnMyScripts7.visible = false
			btnMyScripts8.visible = false
		)
		else 
		(
			btnMyScripts1.visible = false
			btnMyScripts2.visible = false
			btnMyScripts3.visible = false
			btnMyScripts4.visible = false
			btnMyScripts5.visible = true
			btnMyScripts6.visible = true
			btnMyScripts7.visible = true
			btnMyScripts8.visible = true
		)
	)

	fn fnRefreshMagicBtn =
	(
		if switchToolPanel == 0 then
		(
			rolBsKeyTools.width               = 200
			rolBsKeyTools.height              = 228
			btnMagicBtn.text                          = "✧(≖ ◡ ≖)"
			ckbSwitchMyScripts.visible                = false
			btnMyScripts1.visible                     = false
			btnMyScripts2.visible                     = false
			btnMyScripts3.visible                     = false
			btnMyScripts4.visible                     = false
			btnMyScripts5.visible                     = false
			btnMyScripts6.visible                     = false
			btnMyScripts7.visible                     = false
			btnMyScripts8.visible                     = false
		)
		else
		(
			rolBsKeyTools.width               = 335
			rolBsKeyTools.height              = 253
			btnMagicBtn.text                          = "( = `▽`)"
			ckbSwitchMyScripts.visible                = true
			fnRefreshMsPanel ()
		)
	)

	fn fnSwitchMagicBtn =
	(
		fnRefreshMsPanel()
		if switchToolPanel == 1 then
		(
			rolBsKeyTools.width               = 200
			rolBsKeyTools.height              = 228
			btnMagicBtn.text                          = "✧(≖ ◡ ≖)"
			switchToolPanel                           = 0
			ckbSwitchMyScripts.visible                = false
			btnMyScripts1.visible                     = false
			btnMyScripts2.visible                     = false
			btnMyScripts3.visible                     = false
			btnMyScripts4.visible                     = false
			btnMyScripts5.visible                     = false
			btnMyScripts6.visible                     = false
			btnMyScripts7.visible                     = false
			btnMyScripts8.visible                     = false
		)
		else
		(
			rolBsKeyTools.width               = 335
			rolBsKeyTools.height              = 253
			btnMagicBtn.text                          = "( = `▽`)"
			switchToolPanel                           = 1
			ckbSwitchMyScripts.visible                = true
		)
	)

	fn fnSortById arrSource arrSortID =
	(
		local arrTarget = #()
		for i in arrSortID do 
		(
			append arrTarget arrSource[i]
		)
		return arrTarget
	)

	fn fnReloadToolsBtn =
	(
		arrSourToolC1 = #(rolBsKeyTools.btnColorTools,rolBsKeyTools.btnFastAlign,
						rolBsKeyTools.btnImageComp,rolBsKeyTools.btnAnimMirror,
						rolBsKeyTools.btnFnKeyType,rolBsKeyTools.btnBatchExport,
						rolBsKeyTools.ckbIsoMesh,rolBsKeyTools.btnBipedTraj,
						rolBsKeyTools.btnMeshTools,rolBsKeyTools.btnQuickPrev,
						rolBsKeyTools.btnFnFrame,rolBsKeyTools.ckbFnMtlDisplay)
		arrSourToolC2 = #(rolBsKeyTools.btnCutSequence,rolBsKeyTools.btnMopherSlider,
						rolBsKeyTools.btnSelBiped,rolBsKeyTools.btnSelBone,
						rolBsKeyTools.btnFnTCB,rolBsKeyTools.btnEulerFilter,
						rolBsKeyTools.btnDelOutKeys,rolBsKeyTools.btnCleanOutKeys,
						rolBsKeyTools.btnEndBone,rolBsKeyTools.btnRenameTools,
						rolBsKeyTools.btnBipedScale,rolBsKeyTools.btnSelByColor)
		arrSourToolC3 = #(rolBsKeyTools.btnCameraFromView,rolBsKeyTools.btnMeshToBone,
						rolBsKeyTools.btnLightTable,rolBsKeyTools.btnTemp,
						rolBsKeyTools.btnTemp,rolBsKeyTools.btnTemp,
						rolBsKeyTools.btnTemp,rolBsKeyTools.btnTemp,
						rolBsKeyTools.btnTemp,rolBsKeyTools.btnTemp,
						rolBsKeyTools.btnTemp,rolBsKeyTools.btnTemp)
		arrSourToolC4 = #(rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2,
						rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2,
						rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2,
						rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2,
						rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2,
						rolBsKeyTools.btnTemp2,rolBsKeyTools.btnTemp2)
		
		fnLoadToolConfig()
		arrToolC1 = fnSortById arrSourToolC1 iniToolC1
		arrToolC2 = fnSortById arrSourToolC2 iniToolC2
		arrToolC3 = fnSortById arrSourToolC3 iniToolC4
		arrToolC4 = fnSortById arrSourToolC4 iniToolC4
	)

	fn fnSwitchToolsBtn idBtn =
	(
		local arrBtnAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4

		for b in arrBtnAll do (b.visible = false)

		str  = "for b = 1 to arrToolC" + idBtn as string + ".count do" + "\r\n"
		str += "(" + "\r\n"
		str += "	arrToolC" + idBtn as string + "[b].visible = true" + "\r\n"
		str += "	if (mod b 2 == 1) then \r\n"
		str += "	("
		str += "		arrToolC" + idBtn as string + "[b].pos = " + [205,40] as string + " + [0,(b - 1) * 15]" + "\r\n"
		str += "	)"
		str += "	else if (mod b 2 == 0) then"
		str += "	("
		str += "		arrToolC" + idBtn as string + "[b].pos = " + [265,40] as string + " + [0,(b - 2) * 15]" + "\r\n"
		str += "	)"
		str += ")"
		
		execute str
	)

	fn fnSwitchToolBtnChecked Btn =
	(
		arrBtnTemp = #(ckbC1,ckbC2,ckbC3,ckbC4)
		for i = 1 to arrBtnTemp.count do
		(
			if i != Btn then 
			(
				arrBtnTemp[i].checked = false
			)
			else 
			(
				idBtn = Btn
				arrBtnTemp[idBtn].checked = true
			)
		)
	)

	fn fnIsBipRoot obj = 
	(
		if ((classof obj.baseobject) == Biped_Object) do 
		(
			if (obj.controller.rootNode == obj) do (return true)
		)
		return false
	)

	fn fnBipedScale =
	(
		if (selection.count != 0) then 
		(
			for i in selection as Array do
			(
				if ((fnIsBipRoot i) == false) then 
				(
					subAnimSelected = getSubAnimName (i.transform.controller[1][1]) 1
					undo "addDelBipedScale" on
					(
						if (subAnimSelected == #ScaleXYZ) then 
						try (i.transform.controller[1][1].delete 1)catch()
						else if (subAnimSelected == #available) then 
						(
							try
							(
								rootnodeSelected = i.transform.controller.rootnode
								rootnodeSelected.transform.controller.enableSubAnims = true
								i.transform.controller[1][1][1].controller = ScaleXYZ ()
							)catch()
						)
					)
				)
			)
		)
	else (messagebox "请选择一根或多根 Biped 骨骼!    \r\n" beep:false title:"选择有误！")
	)

	Fn fnCleanOutRangeKeys inputObject =  ---清理无限帧,以前收集的,找不到来源了,大概是遍历子动画
	(
		startTime = AnimationRange.Start
		endTime = AnimationRange.End
		for i = 1 to inputObject.numSubs do
		(
			tempSubAnim = GetSubAnim inputObject i
			tempController = tempSubAnim.Controller
			
			if tempController != undefined do
			(
				tempKeyList = tempController.Keys
				
				outEndKeysIndex = for i = 1 to tempKeyList.Count where tempKeyList[i].Time > endTime collect i
				if outEndKeysIndex.Count > 0 do for i = 1 to outEndKeysIndex.Count do DeleteKey tempKeyList tempKeyList.count
				
				outStartKeysIndex = for i = 1 to tempKeyList.Count where  tempKeyList[i].Time < startTime collect i
				for i = 1 to outStartKeysIndex.Count do DeleteKey tempKeyList 1
			)
			if tempSubAnim.numSubs > 0 do fnCleanOutRangeKeys tempSubAnim
		)
	)

	fn fnDelSelKeys =
	(
		for o in selection where (o.ishidden == false) do 
		(
			if (classof o == Biped_Object) then
			(
				if classof o.controller == Vertical_Horizontal_Turn then  --清理质心帧
				(
					biped.deleteKeys o.controller.vertical #selection
					biped.deleteKeys o.controller.horizontal #selection
					if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
						(biped.deleteKeys o.controller.flip #selection)
						else(biped.deleteKeys o.controller.turning #selection)
				)
				else if classof o.controller == BipSlave_Control then  --清理biped正常帧
				(
					biped.deleteKeys o.controller #selection
					subanimBipedScale = GetSubAnim o.controller[1] 1
					if ((subanimBipedScale != undefined) and \
					(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  --清理biped的缩放针
					(
						deleteKeys subanimBipedScale.controller #selection
					)
				)
			)
			else deleteKeys o #selection   ---清理非biped帧
		)
	)

	-- fn fnAddLinkKeys tempObj =
	-- (
		fn fnAddLinkTimesKeys tempObj i=     --添加linkTimes关键帧
		(
			-- for i = 1 to tempObj.controller.numsubs do 
			-- (
				if ((GetSubAnimName tempObj.controller i) == #Link_Times) then
				(
					if tempObj.controller[i].keys[1] != undefined then
					(
						for i in tempObj.controller[i].keys do 
						(
							appendIfUnique arrLinkKeys i  ---------添加link帧到数组
							appendIfUnique arrKeysTime i.time
							appendIfUnique arrBlockingKeys i.time
							if i.selected == true then (appendIfUnique arrKeysSelected i.time)
						)
					)
				)
			-- )
		)
		fn fnAddLinkParamsKeys tempObj i=   ----添加LinkParams下面的Transform帧
		(
			local tempLinkController
			local keyTimeStartTemp
			local keyTimeEndTemp
			
			-- for i = 1 to tempObj.controller.numsubs do 
			-- (
				if ((GetSubAnimName tempObj.controller i) == #Link_Params) then
				(
					tempLinkController = tempObj.controller[i]
					if tempLinkController[1] != undefined then
					(
						for i = 1 to tempLinkController.numsubs do -----link属性的bone下面的prs帧------
						(
							if (((tempLinkController[i]).name == "Position") or \
							((tempLinkController[i]).name == "Rotation") or \
							((tempLinkController[i]).name == "Scale")) then
							(
								if tempLinkController[i].keys[1] != undefined then
								(
									keyTimeStartTemp = tempLinkController[i].keys[1].time
									keyTimeEndTemp = tempLinkController[i].keys[tempLinkController[i].keys.count].time
									appendIfUnique arrKeysTime keyTimeStartTemp
									appendIfUnique arrKeysTime keyTimeEndTemp
									for i in tempLinkController[i].keys do 
									(
										appendIfUnique arrBlockingKeys i.time
										if i.selected == true then (
											appendIfUnique arrKeysSelected i.time
										)
									)
								)
							)
						)
					)
				)
			-- )
		)
		-- fnAddLinkTimesKeys tempObj
		-- fnAddLinkParamsKeys tempObj
	-- )

	fn fnAddPrsKeys tempObj i=  ---------添加正常非biped的prs帧(没加link),i是子动画ID,后面用到,提前传入减少遍历
	(
		local keyTimeStartTemp
		local keyTimeEndTemp
		
		-- for i = 1 to tempObj.controller.numsubs do 
		-- (
			if (((tempObj.controller[i]).name == "Position") or \
			((tempObj.controller[i]).name == "Rotation") or \
			((tempObj.controller[i]).name == "Scale")) then
			(
				if tempObj.controller[i].keys[1] != undefined then
				(
					keyTimeStartTemp = tempObj.controller[i].keys[1].time
					keyTimeEndTemp = tempObj.controller[i].keys[tempObj.controller[i].keys.count].time
					appendIfUnique arrKeysTime keyTimeStartTemp
					appendIfUnique arrKeysTime keyTimeEndTemp
					for i in tempObj.controller[i].keys do 
					(
						appendIfUnique arrBlockingKeys i.time
						if i.selected == true then (
							appendIfUnique arrKeysSelected i.time
						)
					)
				)
			)
		-- )
	)

	fn fnAddBipedKeys tempObj =------收集Biped帧
	(
		local keyTimeStartTemp
		local keyTimeEndTemp
		local subanimBipedScale

		if classof tempObj.controller != Footsteps then
		(
			if classof tempObj.controller != Vertical_Horizontal_Turn then --筛选出非质心的biped帧
			(
				if (tempObj.controller.keys[1] != undefined) then
				(
					for i in tempObj.controller.keys do 
					(
						appendIfUnique arrKeysTime i.time   ---添加到数组
						appendIfUnique arrBlockingKeys i.time
						if i.selected == true then (
							appendIfUnique arrKeysSelected i.time
						)
					)
				)
				subanimBipedScale = GetSubAnim tempObj.controller[1] 1
				if ((subanimBipedScale != undefined) and \
				(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  ----筛选出biped的缩放帧
				(
					if subanimBipedScale[1].keys[1] != undefined then
					(
						keyTimeStartTemp = subanimBipedScale[1].keys[1].time
						keyTimeEndTemp = subanimBipedScale[1].keys[subanimBipedScale[1].keys.count].time
						appendIfUnique arrKeysTime keyTimeStartTemp
						appendIfUnique arrKeysTime keyTimeEndTemp
						for i in subanimBipedScale[1].keys do 
						(
							appendIfUnique arrBlockingKeys i.time
							if i.selected == true then (
								appendIfUnique arrKeysSelected i.time
							)
						)
					)
				)
			)
			else
			(-------------------下面是收集质心的关键帧,坑在于中英文turning名字还不一样...
				if classof tempObj.controller == Vertical_Horizontal_Turn then
				(
					bipCtrl = tempObj.controller
					vertCtrl = bipCtrl.vertical.controller
					horzCtrl = bipCtrl.horizontal.controller
					if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
						(turnCtrl = bipCtrl.flip.controller)
						else(turnCtrl = bipCtrl.turning.controller)
					bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
					for c in bipCtrlTemp do
					(
						if c.keys[1] != undefined then
						(
							keyTimeStartTemp = c.keys[1].time
							keyTimeEndTemp = c.keys[c.keys.count].time
							appendIfUnique arrKeysTime keyTimeStartTemp
							appendIfUnique arrKeysTime keyTimeEndTemp
							for i in c.keys do 
							(
								appendIfUnique arrBlockingKeys i.time
								if i.selected == true then (
									appendIfUnique arrKeysSelected i.time
								)
							)
						)
					)
				)
			)
		)
	)

	fn fnAddKyes tempObj fnLink =   ---添加帧(主要是首尾帧),加个判断是否勾选link
	(	
		if fnLink == 1 then ------1代表勾选了link
		(
			if (classof tempObj != Biped_Object) then
			(
				if tempObj.controller != undefined then
				(
					if (classof tempObj.controller) == prs then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddPrsKeys tempObj i        ---非biped物体的位移旋转缩放帧
						)
					)
					if (classof tempObj.controller) == Link_Constraint then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddLinkTimesKeys tempObj i         ---------link属性的物体link帧和非link帧
							fnAddLinkParamsKeys tempObj i
						)
					)
				)
			)
			else
			(
				fnAddBipedKeys tempObj   ---------biped帧
			)
		)
		if fnLink == 0 then  --------跟上面一样,区别在于没有(link属性物体的link帧)
		(
			if (classof tempObj != Biped_Object) then
			(
				if tempObj.controller != undefined then
				(
					if (classof tempObj.controller) == prs then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddPrsKeys tempObj i
						)
					)
					if (classof tempObj.controller) == Link_Constraint then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddLinkParamsKeys tempObj i
						)
					)
				)
			)
			else
			(
				fnAddBipedKeys tempObj   ---------biped帧
			)
		)----------------收集各种帧
		-- arrKeysTime = makeUniqueArray arrKeysTime  ---去除重复帧数
		sort arrKeysTime  ----帧数排序
		sort arrKeysSelected
		if (arrKeysTime.count != 0) then
		(
			case of 
			(
				(arrKeysTime.count > 1):
				(
					keyFirst = arrKeysTime[1]            ------找到首帧
					keyEnd = arrKeysTime[arrKeysTime.count]   -----------找到尾帧
				)
				(arrKeysTime.count == 1):   --防止首尾同帧的保险
				(
					keyFirst = arrKeysTime[1]
					keyEnd = keyFirst + 1
				)
			)
		)
		if (arrKeysSelected.count != 0) then
		(
			case of 
			(
				(arrKeysSelected.count > 1):
				(
					keySelFirst = arrKeysSelected[1]            ------找到首帧
					keySelEnd = arrKeysSelected[arrKeysSelected.count]   -----------找到尾帧
				)
				(arrKeysSelected.count == 1):   --防止首尾同帧的保险
				(
					keySelFirst = arrKeysSelected[1]
					keySelEnd = keySelFirst + 1
				)
			)
		)
	)

	fn fnCollectKeys = ---------收集关键帧
	(
		arrKeysTime     = #()
		arrKeysSelected = #() ----------------先清空数组
		arrLinkKeys     = #()
		arrBlockingKeys = #()
		case of  -----------处理选中,未选中则处理全部
		(
			(selection.count == 0):
			(
				for i in (objects as array) where (i.ishidden == false) do 
				(
					if rolBsKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
			default:
			(
				for i in (selection as array) where (i.ishidden == false) do 
				(
					if rolBsKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
		)
	)
	
	fn fnChangetRangeTime =   ------------关键帧数字随滑条改变
	(
		rolBsKeyTools.spiStartTime.value = animationrange.start
		rolBsKeyTools.spiEndTime.value = animationrange.end
	)

	fn fnSelLinkKeys keyFirst KeyEnd symbol =  ---------------选择link帧方法
	(
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do   -------link帧选中
			(
				i.selected = false ---先取消之前link帧选中状态
				case of  -------------判断link帧位置,数字是随便取的方便判断情况
				(
					(symbol == 0):(if i.time <= KeyEnd then i.selected = true)
					(symbol == 1):(if i.time >= keyFirst then i.selected = true)
					(symbol == 2):(i.selected = true)
				)
			)
		)
	)

	fn fnSelKeys keyFirst KeyEnd symbol =  ---------------选择帧的方法
	(
		fn fnSelectKeys keyFirst KeyEnd symbol =  -------因为有选中和没选择状态, 所以加一个方法精简下
		(
			for i in objects where (i.ishidden == false) do deselectKeys i          --清除之前选中的关键帧
			if arrKeysTime.count != 0 then
			(
				selectkeys $ keyFirst KeyEnd  -------------选中正常帧
				if rolBsKeyTools.btnJudgeLinkKey.checked == true then
				(
					fnSelLinkKeys keyFirst KeyEnd symbol --------------选中link帧
				)
			)
			else
			(
				if rolBsKeyTools.btnJudgeLinkKey.checked == true then
				(
					fnSelLinkKeys keyFirst KeyEnd symbol
				)
			)
		)
		case of 
		(
			(selection.count == 0):  ----------判断是否有选中物体
			(
				actionMan.executeAction 0 "40021"    ---没有选择物体则选择所有物体
				fnSelectKeys keyFirst KeyEnd symbol
			)
			default:  ----------------
			(
				fnSelectKeys keyFirst KeyEnd symbol
			)
		)
	)
	
	-- mapped fn fnMoveKeysAndLinkKeys obj offset =  ----https://forums.cgsociety.org/t/moving-keys-from-link-constraint-keys-access/1575053
	-- (
	-- 	local arrTargetID  = #()
	-- 	moveKeys obj offset #selection  ---先移动非link帧
	-- 	if rolBsKeyTools.btnJudgeLinkKey.checked == true then 
	-- 	(
	-- 		if classof obj.controller == Link_Constraint do
	-- 		(
	-- 			nTargets = obj.controller.getNumTargets()  ---得到link的帧数量
	
	-- 			if nTargets > 0 do
	-- 			(
	-- 				for i = nTargets to 1 by -1 do  ------如果大于0则从最后link帧开始移
	-- 				(
	-- 					fNumber = obj.controller.getFrameNo i
	-- 					if ((fNumber >= keySelFirst) and (fNumber <= keySelEnd)) then
	-- 					(
	-- 						appendIfUnique arrTargetID i
	-- 					)
	-- 				)
	-- 				if offset > 0 then  --------判断向前还是向后移动帧
	-- 				(
	-- 					for i = arrTargetID.count to 1 by -1 do  ------如果大于0则从最后link帧开始移
	-- 					(
	-- 						fNumber = obj.controller.getFrameNo arrTargetID[i]
	-- 						obj.controller.setFrameNo i (fNumber + offset)
	-- 					)
	-- 				)
	-- 				else
	-- 				(
	-- 					for i = 1 to arrTargetID.count do  ---如果移动帧小于0,从第一个link帧开始移
	-- 					(
	-- 						fNumber = obj.controller.getFrameNo arrTargetID[i]
	-- 						obj.controller.setFrameNo i (fNumber + offset)
	-- 					)
	-- 				)
	-- 			)
	-- 		)
	-- 	)
	-- )

	-- -- fn fnSplitSelBiped = --分开选择四肢和身体,例如同一条手臂只选择最父级的(方便移动帧)
	-- -- (
	-- -- 	arrSelBiped = for i in selection where classof i.controller == BipSlave_Control collect i 

	-- -- )

	-- fn fnMoveBipedKeys offsetFrame =  -------移动Biped帧
	-- (
	-- 	bipedRoot = #()   -------判断选择了几个biped骨架
	-- 	for i in selection where ((classof i == Biped_Object) and (i.ishidden == false)) do  
	-- 	(
	-- 		appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
	-- 	)
	-- 	for c in bipedRoot do  ---按每个骨架处理
	-- 	(
	-- 		ctrlBiped = c.controller
	-- 		bipedAll = #(biped.getNode ctrlBiped #pelvis, -----四肢同帧处理,只处理他首节biped
	-- 					biped.getNode ctrlBiped #spine,
	-- 					biped.getNode ctrlBiped #neck,
	-- 					biped.getNode ctrlBiped #larm,
	-- 					biped.getNode ctrlBiped #rarm,
	-- 					biped.getNode ctrlBiped #lleg,
	-- 					biped.getNode ctrlBiped #rleg,
	-- 					biped.getNode ctrlBiped #prop1,
	-- 					biped.getNode ctrlBiped #prop2,
	-- 					biped.getNode ctrlBiped #prop3,
	-- 					biped.getNode ctrlBiped #tail)

	-- 		vertCtrl = ctrlBiped.vertical.controller  -----质心ctrl关键帧
	-- 		horzCtrl = ctrlBiped.horizontal.controller
	-- 		if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
	-- 		(turnCtrl = ctrlBiped.flip.controller)
	-- 		else(turnCtrl = ctrlBiped.turning.controller)
	-- 		bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
	-- 		for c in bipCtrlTemp do
	-- 		(
	-- 			biped.moveKeys c offsetFrame #selection  -----移动选定的质心帧
	-- 		)
	-- 		for nodeBiped in bipedAll where nodeBiped != undefined do  -----移动其他biped的选定帧
	-- 		(
	-- 			biped.moveKeys nodeBiped.controller offsetFrame #selection
	-- 		)
	-- 	)
	-- )		

	-- mapped fn fnMoveBipedScaleKeys tempObj offsetFrame =  -------移动biped的缩放帧
	-- (
	-- 	ctrlBiped = tempObj.controller
	-- 	if classof ctrlBiped == BipSlave_Control then  --------下面判定子动画是否为scaleXYZ
	-- 	(
	-- 		if ((ctrlBiped[1][1] != undefined) and ((getSubAnimName ctrlBiped[1][1] 1) == #ScaleXYZ)) then
	-- 		(
	-- 			movekeys ctrlBiped[1][1][1] offsetFrame #selection
	-- 		)
	-- 	)
	-- )

	-- fn fnMoveAllKeys keyMovedOffset fnRange:off =
	-- (
	-- 	local rangEnd = animationrange.end
	-- 	local rangeStart = animationrange.start
	-- 	local n = 0  --n来判定是否有选中biped

	-- 	if keyMovedOffset != undefined then
	-- 	(
	-- 		if selection.count != 0 then
	-- 		(
	-- 			for i in selection where (i.ishidden == false) do
	-- 			(
	-- 				if classof i != Biped_Object then
	-- 				(
	-- 					fnMoveKeysAndLinkKeys i keyMovedOffset
	-- 				)
	-- 				else 
	-- 				(
	-- 					fnMoveBipedScaleKeys i keyMovedOffset
	-- 					n += 1
	-- 				)
	-- 			)
	-- 			if n != 0 then  ----------分开解决biped多移动的问题,傻瓜式方法
	-- 			(
	-- 				fnMoveBipedKeys keyMovedOffset
	-- 			)
	-- 		)
	-- 		else  ---跟上面一样,只是对所有物体
	-- 		(
	-- 			for i in objects where (i.ishidden == false) do
	-- 			(
	-- 				if classof i != Biped_Object then
	-- 				(
	-- 					fnMoveKeysAndLinkKeys i keyMovedOffset
	-- 				)
	-- 				else fnMoveBipedScaleKeys i keyMovedOffset
	-- 			)
	-- 			fnMoveBipedKeys keyMovedOffset
	-- 		)
	-- 		if fnRange == on then
	-- 		(
	-- 			if keyMovedOffset > 0 then 
	-- 			(
	-- 				rangEnd = animationrange.end + keyMovedOffset
	-- 				animationrange = interval animationrange.start rangEnd
	-- 			)
	-- 			else if keyMovedOffset < 0 then 
	-- 			(
	-- 				rangeStart = animationrange.start + keyMovedOffset
	-- 				animationrange = interval rangeStart animationrange.end
	-- 			)
	-- 		)
	-- 		keySelFirst += keyMovedOffset
	-- 		keySelEnd  += keyMovedOffset
	-- 	)
	-- )

	fn fnAddTrajLayer strlayerName templayerTarget =
	(
		if (LayerManager.getLayerFromName strlayerName) != undefined then
		(
			templayerTarget = LayerManager.getLayerFromName strlayerName
		)
		else templayerTarget = LayerManager.newLayerFromName strlayerName
		templayerTarget.lock = on
		templayerTarget
	)

	fn fnAddBipedTraj tempBiped =
	(
		pointTraj = point name:("Traj_" + tempBiped.name) size:0 cross:true 
		appendIfUnique arrTraj pointTraj
		freeze pointTraj
		arrBipedSonTemp = tempBiped.children
		bipedTarget = arrBipedSonTemp[(arrBipedSonTemp.count + 1)/2]
		pointTraj.transform = bipedTarget.transform
		pointTraj.parent = tempBiped
		layerTraj.addNode pointTraj
		deleteKeys pointTraj #allKeys
		pointTraj.showTrajectory = true
		-- ResetXForm pointTraj
	)

	fn fnDeleteTraj tempBiped =
	(
		local deleteTraj
		local deleteTrajName = ("Traj_" + tempBiped.name)
		local deleteTraArrID = findItem arrTraj deleteTrajName
		if deleteTraArrID != 0 then
		(
			deleteTraj = arrTraj[deleteTraArrID]
			deleteItem arrTraj deleteTraArrID
		)
		if (getNodeByName deleteTrajName) != undefined then (delete (getNodeByName deleteTrajName))
	)

	fn fnQuickSave =
	(
		local nameCurrentFile = getFilenameFile maxFileName
		local strNameSplit = "_Backup"
		local suffixFile = 1
		local fileSave = ""
		local arrFiles = #()
		local arrFilesNum = #()
		
		fn fnGetVerNum nameCurrentFile = 
		(
			numTempName = findstring nameCurrentFile "_Backup"
			numTempVer = substring nameCurrentFile (numTempName + 7) nameCurrentFile.count
			return numTempVer
		)

		if (matchPattern nameCurrentFile pattern:"*_Backup*" ignorCase:false) then
		(
			fnGetVerNum nameCurrentFile
			numTempName = findstring nameCurrentFile "_Backup"
			nameCurrentFile = substring nameCurrentFile 1 (numTempName - 1)
		)
		arrFiles = getfiles (maxFilePath + nameCurrentFile + "_Backup*.max")
		if arrFiles.count > 0 then
		(
			for i in arrFiles where (i != undefined) do
			(
				tempNum = ((fnGetVerNum (getFilenameFile i)) as integer)
				if tempNum != undefined then append arrFilesNum tempNum
				sort arrFilesNum
			)
			suffixFile = arrFilesNum[arrFilesNum.count] + 1
		)
		else suffixFile = 1
		fileSave = maxFilePath + nameCurrentFile + strNameSplit + (suffixFile as string) + ".max"
		saveMaxFile fileSave
		messagebox ("已快速备份至：" + fileSave) 
	)

	fn fnCutDisplayKeyRange keyFirst keyEnd =  ---显示首尾帧范围
	(
		if ((keyFirst != undefined) and (keyEnd != undefined)) then
		(
			if (arrKeysTime.count != 0) then
			(
				if (arrLinkKeys.count != 0) then
				(
					case of  ------万恶的link帧导致更多判定
					(
						((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
						(animationrange = (interval keyFirst keyEnd))
						((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
						(animationrange = (interval arrLinkKeys[1].time keyEnd))
						((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time >= keyEnd)):
						(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
						((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
						(animationrange = (interval keyFirst arrLinkKeys[arrLinkKeys.count].time))
						((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
						(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
					)
				)
				else
				(
					animationrange = interval keyFirst keyEnd
				)
			)
			else 
			(
				if ((arrLinkKeys.count != 0) and (arrLinkKeys.count > 1)) then 
				(
					animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time)
				)
				else 
				(
					if (arrLinkKeys.count == 1) then
					(
						animationrange = (interval arrLinkKeys[1].time (arrLinkKeys[1].time + 1))
					)
				)
			)
		)
	)

	fn fnGetPlaySpeedValue =
	(
		case of
		(
			(timeConfiguration.playbackSpeed == 1):(return 0.25)
			(timeConfiguration.playbackSpeed == 2):(return 0.5)
			(timeConfiguration.playbackSpeed == 3):(return 1)
			(timeConfiguration.playbackSpeed == 4):(return 2)
			(timeConfiguration.playbackSpeed == 5):(return 4)
		)
	)

	-- https://cafe.naver.com/pinksox/6131
	-- 优化支持 bone

	fn FramToMilisecond frame = 
	(
		return ((((frame - animationRange.start) as integer) * (10.0 / 48.0) * fnGetPlaySpeedValue()) as integer)
    )

	fn AppendKeyTimeArray m_PBKeyMiliSecArray keys = 
	(
        if keys.count == 0 do return()
        for i = 1 to keys.count do (
            if (keys[i] >= animationRange.start) AND (keys[i] <= animationRange.end) do (
                appendifUnique m_PBKeyMiliSecArray (FramToMilisecond keys[i])
                appendifUnique m_PBKeyTimeArray keys[i]
            )
        )
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.start)
        appendifUnique m_PBKeyTimeArray animationRange.start
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.end)
        appendifUnique m_PBKeyTimeArray animationRange.end
	)

	fn StopBlocking = 
	(
        clock.active = false
        ckbPlayBlocking.state = false
        ckbPlayBlocking.text = "跳帧播"
	)

	fn PlayBlocking = 
	(
		fnCollectKeys ()
		m_PBKeyTimeArray = #()
		m_PBKeyMiliSecArray = #()
		local nowTime = timeStamp()
		AppendKeyTimeArray m_PBKeyMiliSecArray arrBlockingKeys
		if m_PBKeyMiliSecArray.count == 0 do (
			StopBlocking()
			return()
		)
		
		if (isAnimPlaying()) do (
			stopAnimation()
		)		
		
		sort m_PBKeyTimeArray
		sort m_PBKeyMiliSecArray
		m_PBPointer = 1
		while (m_PBKeyTimeArray[m_PBPointer] < sliderTime) do (m_PBPointer += 1)

		m_PBStartTime = timeStamp() - (FramToMilisecond sliderTime)
		sliderTime = m_PBKeyTimeArray[m_PBPointer]
		clock.active = true
		ckbPlayBlocking.text = "停止!"
	)

	fn ReplayBlocking = 
	(
		m_PBPointer = 1
		m_PBStartTime = timeStamp()
		sliderTime = m_PBKeyTimeArray[m_PBPointer]
	)

	fn fnAddMyScript btnMyScript idMyScript =
	(
		dirScript = getOpenFileName caption:"请选择添加的Max脚本:" historyCategory:"myScripts" \
		types:"maxscript(*.ms,*.mse)|*.ms*|All(*.*)|*.*" filename:(getDir #scripts + @"\") 
		if (dirScript != undefined) then
		(
			nameMyScript = getFilenameFile dirScript
			btnMyScript.text = nameMyScript
			iniArrMyScripts[idMyScript].msName = nameMyScript
			iniArrMyScripts[idMyScript].dir = dirScript
		)
		messagebox "右键可重新设置脚本快捷键!        "
	)

	fn fnRefreshMyScripts =
	(
		arrMyScriptTemp = #(rolBsKeyTools.btnMyScripts1, \
		rolBsKeyTools.btnMyScripts2, \
		rolBsKeyTools.btnMyScripts3, \
		rolBsKeyTools.btnMyScripts4, \
		rolBsKeyTools.btnMyScripts5, \
		rolBsKeyTools.btnMyScripts6, \
		rolBsKeyTools.btnMyScripts7, \
		rolBsKeyTools.btnMyScripts8)
		for b = 1 to arrMyScriptTemp.count do 
		(
			if iniArrMyScripts[b] != undefined then
			(
				if (iniArrMyScripts[b].msName != undefined) then 
				(
					arrMyScriptTemp[b].text = iniArrMyScripts[b].msName
				)
				else arrMyScriptTemp[b].text = "<未定脚本>"
			)
		)
	)

	on rolBsKeyTools open do  ----打开脚本时操作
	(
		------刷新图标, 图标是max自带的,主要是懒得做
		btnSelBeforeKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,3,3,3,3,true,true) 
		btnSelAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
		btnSelAllKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,26,26,26,26,true,true)
		-- btnMoveKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,21,21,21,21,true,true)
-- 		btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		-- dotnet.AddEventHandler myTimer #elapsed fnRefreshHelpText
		-- myTimer.Start()
		-- timeDIsTemp      = timeDisplayMode  ----小数帧还是整数帧
		-- iniPos = (GetDialogPos rolBsKeyTools) 
		fnLoadConfig ()  ---------------脚本位置赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		fnReloadToolsBtn()
		registerTimeCallback rolBsKeyTools.fnChangetRangeTime  -------------帧范围改变添加回调
		if(switchMSPanel == 0) then (ckbSwitchMyScripts.checked = false)
		else (ckbSwitchMyScripts.checked = true)
		fnRefPlaySpeedValue ()  -----判断播放速度
		rolBsKeyTools.btnSetFps.text   = strCurrentFps
		rolBsKeyTools.btnSetSpeed.text = valuePlaySpeed
		fnRefreshMagicBtn ()
		-- if (switchToolPanel == 1) then
		-- (
			fnSwitchToolsBtn idBtn
			fnSwitchToolBtnChecked idBtn
			fnRefreshMyScripts ()
		-- )
		ckbPlayBlocking.state = false
		clock.active = false
		if (iniAutoCheckUpdate == true) then 
		(fnAutoCheckVersion curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools)
	)
	
	on rolBsKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolBsKeyTools)
		fnSetConfig ()
	)
	-----------------------------------------------------------------------------------------
	on rolBsKeyTools rbuttondown pos do 
	(
		popupMenu menuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y]
	)

	on btnConfig pressed do (popupMenu menuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y])

	on rolBsKeyTools mbuttondown pos do 
	(
		try (destroydialog rolBsKeyTools) catch ()
	)
	
	on rolBsKeyTools lbuttondown posMou do
	(
		posMouMoved = posMou
		switchMouseState = on
	)
	
	on rolBsKeyTools lbuttonup posMou do
	(
		switchMouseState = off
	)
	
	on rolBsKeyTools mouseMove pos do
	(
		-- myTimer.Start()
		if switchMouseState == on then
		(
			SetDialogPos rolBsKeyTools (mouse.screenpos - posMouMoved)			
		)
	)
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	on btnSelBiped pressed do ----选择biped
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == Biped_Object then selectmore o
			-- if (matchpattern o.name pattern:"*Bip*") then selectmore o
		)
	)

	on btnSelBone pressed do ----选择bone
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == BoneGeometry then selectmore o
		)
	)

	on spiStartTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangeStart = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \
		(valTime != "") and (rangeStart < animationrange.end)) then
		(
			animationrange = (interval rangeStart animationrange.end)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on spiEndTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangEnd = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \ 
		(valTime != "") and (rangEnd > animationrange.start)) then
		(
			animationrange = (interval animationrange.start rangEnd)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)
	
	on btnFnFrame pressed do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
		)
		else 
		(
			timeDisplayMode = #frames
		)
		slidertime -= 1
		slidertime += 1  ----------默认改了要划一下滑条才生效,脚本直接操作了~~没找到refresh的
	)
	
	on btnMagicBtn pressed do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		fnSwitchMagicBtn ()
	)

	on ckbPlayBlocking changed state do (
        -- if (selection.count == 0) do (
        --     StopBlocking()
        --     return()
        -- )
		if state then (
            PlayBlocking()
        )
        else (
            StopBlocking()
        )
    )
    
    -- Play Blocking용 틱 이벤트 처리
    on clock tick do (
        if (m_PBPointer > m_PBKeyMiliSecArray.count) do return()
		local now = timeStamp()
		local pointer
		if (m_PBKeyMiliSecArray.count == m_PBPointer) then (
			ReplayBlocking()
			pointer = 1
		)
		else (
			pointer = m_PBStartTime + m_PBKeyMiliSecArray[m_PBPointer + 1]
		)
        
        if ( now > pointer ) do (
            m_PBPointer += 1
            sliderTime = m_PBKeyTimeArray[m_PBPointer]
        )
        
        if (m_PBPointer >= m_PBKeyMiliSecArray.count) do (
            ReplayBlocking()
        )

        if keyboard.escPressed do (
            StopBlocking()
		)
		
		if (sliderTime != m_PBKeyTimeArray[m_PBPointer]) do (
			StopBlocking()
		)
    )

	on btnCSTools pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\cstools.ms")
	)
	on btnSpringMagic pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\SpringMagic_New.mse")
	)
	on btnSpringMagic rightclick do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\SpringMagic_Old.mse")
	)

	on btnFileOpen pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts" + "\\BsOpenTools.ms")
	)

	on ckbIsoMesh changed state do
	(
		if state then
		(
			hideByCategory.geometry = false
			hideByCategory.shapes = true
			hideByCategory.lights = true
			hideByCategory.cameras = true
			hideByCategory.helpers = true
			hideByCategory.spacewarps = true
			hideByCategory.particles = true
			hideByCategory.bones = true
		)
		else 
		(
			hideByCategory.shapes = false
			hideByCategory.lights = false
			hideByCategory.cameras = false
			hideByCategory.helpers = false
			hideByCategory.spacewarps = false
			hideByCategory.particles = false
			hideByCategory.bones = false
		)
	)
	on btnBipedTraj pressed do 
	(
		layerTraj = (fnAddTrajLayer "Biped_Trajectories" layerTraj) ----是否创建轨迹层
		if (selection.count > 1) then
		(
			for i in (selection as array) do
			(
				if classof i == Biped_Object then
				(
					if (getNodeByName ("Traj_" + i.name)) != undefined then 
					(
						fnDeleteTraj i
					)
				)
			)
		)
		else if selection.count == 1 then
		(
			if classof $ == Biped_Object then
				(
					if (getNodeByName ("Traj_" + $.name)) != undefined then 
					(
						fnDeleteTraj $
					)
					else fnAddBipedTraj $
				)
		)
	)

	on btnBipedTraj rightclick do
	(
		delLayerObj = #()

		delLayer    = LayerManager.getLayerFromName "Biped_Trajectories"
		
		if delLayer != undefined then
		(
			layerRT = delLayer.layerAsRefTarg
			delLayerObj = refs.dependents layerRT
			delLayer.lock = off
			for i in delLayerObj where ((delLayerObj.count != 0) and (classof i == point)) do delete i
			LayerManager.deleteLayerByName "Biped_Trajectories"
			delLayerObj = #()
		)
	)

	-- on btnBipedTraj rightclick do
	-- (
	-- 	-- bipedRoot = #()   -------判断选择了几个biped骨架
	-- 	if (selection.count > 0) then
	-- 	(
	-- 		-- for i in (selection as array) where classof i == Biped_Object do  
	-- 		-- (
	-- 		-- 	appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
	-- 		-- )
	-- 		for i in (selection as array) do 
	-- 		(
	-- 			if (classof i == Biped_Object) then
	-- 			(
	-- 				nodeTemp = i.controller.rootNode
	-- 				trajDisFn = nodeTemp.controller.displayTrajectories
	-- 				if trajDisFn == true then nodeTemp.controller.displayTrajectories = false
	-- 				else nodeTemp.controller.displayTrajectories = true
	-- 				exit
	-- 			)
	-- 		)
	-- 	)
	-- )

	on edtMoveKey entered val do   -----移动帧数自定义,输入即可
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(------"."他也认为是数字...
			keyMovedOffset = val as integer
			rolBsKeyTools.edtMoveKey.text = keyMovedOffset as string + "f"
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on btnSet5 pressed do 
	(
		edtMoveKey.text = "5f"
		keyMovedOffset = 5
	)
	on btnSetAdd pressed do 
	(
		edtMoveKey.text = "+5f"
		keyMovedOffset += 5
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	on btnSetOpposite pressed do
	(
		keyMovedOffset = - keyMovedOffset
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	on btnMoveKeys pressed do with undo on   ------移动选定帧
	(
		fnMoveAllKeys keyMovedOffset fnRange:off
	)
	on btnMoveKeys rightclick do with undo on
	(
		fnMoveAllKeys keyMovedOffset fnRange:on
	)
	on btnSelBeforeKeys pressed do  ------------选择滑条之前帧
	(
		symbol = 0
		fnCollectKeys ()
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do i.selected = false
		)
		if arrKeysTime.count != 0 then
		(
			if keyFirst <= sliderTime then 
			(
				fnSelKeys keyFirst sliderTime symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time <= sliderTime then 
				(
					fnSelLinkKeys arrLinkKeys[1].time sliderTime symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAfterKeys pressed do  -------------选择滑条之后帧
	(
		symbol = 1
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
			if keyEnd >= sliderTime then 
			(
				fnSelKeys sliderTime keyEnd symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time >= sliderTime then 
				(
					fnSelLinkKeys sliderTime arrLinkKeys[1].time symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAllKeys pressed do     ------------------选择所有帧
	(
		symbol = 2
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			fnSelKeys keyFirst keyEnd symbol
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time symbol
			)
		)
	)
	
	on btnSetFps pressed do popupMenu menuSetFps
		
	on btnSetSpeed pressed do popupMenu menuSetSpeed

	on btnJudgeLinkKey changed state do   --切换是否勾选link
	(
		if btnJudgeLinkKey.state == false then
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
		else fnCollectKeys ()
	)

	on btnCleanOutKeys pressed do with undo on-----------清理范围外帧(无限帧)
	(
		if (queryBox "是否清除范围外关键帧？\r\n( Link 帧请手动删除 )    " \
		title:"是否清除范围外关键帧？" beep:false) then
		(
			if (selection as array).count == 0 then 
			(
				for tempObject in (objects as Array) do fnCleanOutRangeKeys tempObject
			)
			else
			(
				for tempObject in (selection as Array) do fnCleanOutRangeKeys tempObject
			)
			messagebox "清理成功！    " beep:false
		)
	)

	on btnDelOutKeys pressed do with undo on-----------清理选择帧
	(
		if (queryBox "是否清除所有帧？\r\n( Link 帧请手动删除 )    " \
		title:"是否清除所有帧" beep:false) then
		(
			actionMan.executeAction 0 "40021"  -- Selection: Select All
			fnCollectKeys ()
			fnSelKeys keyFirst keyEnd 2
			fnDelSelKeys ()
			if arrLinkKeys.count != 0 then (
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time 2
			)
		)
	)

	on ckbHideBones changed state do
	(
		if state == false then
		(
			for o in geometry as array where (classof o == BoneGeometry and o.layer.ishidden != true) do o.isHidden = false
			rolBsKeyTools.ckbHideBones.text = "隐Bone"
		)
		else
		(
			arrHiddenBones = #()
			for o in geometry as array where (classof o == BoneGeometry) do o.isHidden = true
			rolBsKeyTools.ckbHideBones.text = "显Bone"
		)
	)
	
	on ckbHideBiped changed state do
	(
		if state == false then
		(
			for o in geometry as array where (classof o == Biped_Object and o.layer.ishidden != true) do o.isHidden = false
			rolBsKeyTools.ckbHideBiped.text = "隐Bip"
		)
		else
		(
			arrHiddenBones = #()
			for o in geometry as array where (classof o == Biped_Object) do o.isHidden = true
			rolBsKeyTools.ckbHideBiped.text = "显Bip"
		)
	)

	on ckbFreezeMesh changed state do 
	(
		if state == on then
		(
			rolBsKeyTools.ckbFreezeMesh.text = "解模型"
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject)) \
			and (o.isHidden == false)) do
			(
				freeze o
				o.showFrozenInGray = off
			)
		)
		else
		(
			rolBsKeyTools.ckbFreezeMesh.text = "冻模型"
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject)) \
			and (o.isHidden == false)) do
			(
				unfreeze o
				o.showFrozenInGray = off
			)
		)
	)

	on btnQuickSave pressed do 
	(
		if maxFilePath == "" then 
		(
			messagebox "------------------------------------\r\n当前场景未保存过,\r\n请先保存初始版本~"
			max file saveas
		)
		else fnQuickSave ()
	)

	on btnQuickSave rightclick do (max file saveas)

	on btnCutFrameDisplay pressed do with undo on  ---------------帧栏显示选定帧范围
	(
		if switchSelKeyRange == 0 then
		(
			fnCollectKeys ()
			arrLastSelRange = #(animationrange.start,animationrange.end)
			fnCutDisplayKeyRange keySelFirst keySelEnd
			switchSelKeyRange = 1
		)
		else 
		(
			animationrange = interval arrLastSelRange[1] arrLastSelRange[2]
			switchSelKeyRange = 0
			arrLastSelRange = #()
		)
	)
	on btnAllFrameDisplay pressed do with undo on  ---------------帧栏显示首尾帧范围
	(
		if switchAllKeyRange == 0 then
		(
			fnCollectKeys ()
			arrLastAllRange = #(animationrange.start,animationrange.end)
			fnCutDisplayKeyRange keyFirst keyEnd
			switchAllKeyRange = 1
		)
		else 
		(
			animationrange = interval arrLastAllRange[1] arrLastAllRange[2]
			switchAllKeyRange = 0
			arrLastAllRange = #()
		)
	)

	on btnZeroFrameDisplay pressed do with undo on  ---------------帧栏显示0帧
	(
		animationrange = interval 0f animationrange.end
	)

	------------切换工具栏分类--------------------------------------------
	on ckbC1 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 1
			fnSwitchToolsBtn 1
		)
		else ckbC1.checked = true
	)
	on ckbC2 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 2
			fnSwitchToolsBtn 2
		)
		else ckbC2.checked = true
	)
	on ckbC3 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 3
			fnSwitchToolsBtn 3
		)
		else ckbC3.checked = true
	)
	on ckbC4 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 4
			fnSwitchToolsBtn 4
		)
		else ckbC4.checked = true
	)
	on ckbSwitchMyScripts changed state do 
	(
		if state then switchMSPanel = 1 else switchMSPanel = 0
		fnRefreshMsPanel()
	)
	--------------------------------------------------------------------

	on btnFnTCB pressed do 
	(
		for i in selection where classof i == BoneGeometry do
		(
			if classof i.rotation.controller == tcb_rotation then
				(i.rotation.controller = Euler_XYZ ())
				else (i.rotation.controller = tcb_rotation ())
		)
	)

	on btnImageComp pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\ImageCompHelper.ms"))
	
	on btnFnKeyType pressed do 
	(
		try(destroydialog rolFnKeys)catch()
		Createdialog rolFnKeys  fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y]
	)

	on btnEulerFilter pressed do 
	(
		for i in selection where classof i == BoneGeometry do
		(
			if classof i.rotation.controller == Euler_XYZ then
			(
				i.rotation.controller = tcb_rotation ()
				i.rotation.controller = Euler_XYZ ()
			)
		)
	)

	on ckbFnBoxDisplay changed state do 
	(
		if state == on then ckbFnBoxDisplay.text = "实体"
				else ckbFnBoxDisplay.text = "BOX显"
		for o in Geometry where (o.isHidden == false) do 
		(
			if ((classof o == BoneGeometry) or (classof o == Biped_Object)) then
			(
				if state == on then o.boxmode = on 
				else o.boxmode = off
			)
		)
	)
	
	on ckbFnMtlDisplay changed state do 
	(
		if state == off then
		(
			-- for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat on
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat on
		)
		else
		(
			-- for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat off
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat off
		)
	)

	on ckbFnMtlDisplay rightclick do 
	(
		local disp = NitrousGraphicsManager.GetActiveViewportSetting() 
		if disp.VisualStyleMode == #clay then disp.VisualStyleMode = #Realistic
		else disp.VisualStyleMode =  #clay
	)

	on btnMopherSlider pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\MorphSliders_11.ms")
		macros.run "Tools" "MorphSliders"
	)

	on btnLayerManager pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\LayerManagerAlternative.ms")
	)

	on btnAnimMirror pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\动画镜像工具.mse")
	)

	on btnMyScripts1 pressed do 
	(
		if ((iniArrMyScripts[1] != undefined) and (doesfileexist iniArrMyScripts[1].dir)) then 
		(
			fileIn iniArrMyScripts[1].dir
		)
		else fnAddMyScript btnMyScripts1 1
	)
	on btnMyScripts2 pressed do 
	(
		if ((iniArrMyScripts[2] != undefined) and (doesfileexist iniArrMyScripts[2].dir)) then 
		(
			fileIn iniArrMyScripts[2].dir
		)
		else fnAddMyScript btnMyScripts2 2
	)
	on btnMyScripts3 pressed do 
	(
		if ((iniArrMyScripts[3] != undefined) and (doesfileexist iniArrMyScripts[3].dir)) then 
		(
			fileIn iniArrMyScripts[3].dir
		)
		else fnAddMyScript btnMyScripts3 3
	)
	on btnMyScripts4 pressed do 
	(
		if ((iniArrMyScripts[4] != undefined) and (doesfileexist iniArrMyScripts[4].dir)) then 
		(
			fileIn iniArrMyScripts[4].dir
		)
		else fnAddMyScript btnMyScripts4 4
	)
	on btnMyScripts5 pressed do 
	(
		if ((iniArrMyScripts[5] != undefined) and (doesfileexist iniArrMyScripts[5].dir)) then 
		(
			fileIn iniArrMyScripts[5].dir
		)
		else fnAddMyScript btnMyScripts5 5
	)
	on btnMyScripts6 pressed do 
	(
		if ((iniArrMyScripts[6] != undefined) and (doesfileexist iniArrMyScripts[6].dir)) then 
		(
			fileIn iniArrMyScripts[6].dir
		)
		else fnAddMyScript btnMyScripts6 6
	)
	on btnMyScripts7 pressed do 
	(
		if ((iniArrMyScripts[7] != undefined) and (doesfileexist iniArrMyScripts[7].dir)) then 
		(
			fileIn iniArrMyScripts[7].dir
		)
		else fnAddMyScript btnMyScripts7 7
	)
	on btnMyScripts8 pressed do 
	(
		if ((iniArrMyScripts[8] != undefined) and (doesfileexist iniArrMyScripts[8].dir)) then 
		(
			fileIn iniArrMyScripts[8].dir
		)
		else fnAddMyScript btnMyScripts8 8
	)

	on btnMyScripts1 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts2 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts3 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts4 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts5 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts6 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts7 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	on btnMyScripts8 rightclick do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor\
		pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)

	on btnHideUnSel pressed do 
	(
		local arrTempSelObj = #()
		local arrTemp = objects as array
		local arrTempAllObj = for o in arrTemp where o.isHidden == false collect o
		local numTempCurrentSel = selection.count
		if arrTempAllObj.count > numTempCurrentSel then
		(
			if numTempCurrentSel != 0 then 
			(
				arrTempSelObj = selection as array
			)
			for i in arrTempSelObj where (arrTempSelObj.count != 0) do
			(
				num = finditem arrTempAllObj i
				if num != 0 then deleteItem arrTempAllObj num
			)
			arrTempUnSelection = arrTempAllObj
			actionMan.executeAction 0 "281"
		)
	)

	on btnHideUnSel rightclick do
	(
		if arrTempUnSelection.count != 0 then
		(
			for i in arrTempUnSelection do i.isHidden = false
		)
	)

	on btnQuickPrev pressed do 
	(
		createPreview percentSize:100 \
		dspGeometry:true dspShapes:false dspLights:false \
		dspCameras:false dspHelpers:false dspParticles:true dspBones:false \
		dspGrid:true dspSafeFrame:false dspFrameNums:false dspBkg:true \
		rndLevel:#smoothhighlights
	)

	on btnQuickPrev rightclick do (shellLaunch (getdir #preview) "")

	on btnSelByColor pressed do
	(
		for i in selection as array where (i.ishidden == false) do
		(
			for o in objects as array where (i.ishidden == false) do
			(
				if o.wirecolor == i.wirecolor then selectmore o
			)
		)
	)

	on btnBipedScale pressed do (fnBipedScale ())

	on btnBatchExport pressed do 
	(
		messageBox "待添加...         \r\n" beep:false
	)

	on btnColorTools pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\ProColor.ms"))

	on btnAnimCopyPaste pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\CPTools.ms"))

	on btnPoseTool pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\BsRefTools.ms"))

	on btnTrajedit pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\DTrajEdit.ms"))

	on btnHotAnimBtn pressed do 
	(
		FileIn ((getDir #scripts) + "\\BulletScripts\\BsAnimButton.ms")
	)

	on ckbShadowCut changed state do
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Silhouette.ms"))

	on btnRenameTools pressed do
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\P_ObjectRenamer.ms"))

	on btnCameraFromView pressed do
	(
		If (viewport.Gettype() == #view_persp_user) and (not theHold.Holding()) then 
		(CreateCameraFromView(FreeCamera))
		else (messagebox "请按“P”在自由视角创建，之后可能优化为任意视角~        \r\n" beep:false)
	)

	on btnMeshToBone pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\AnimMeshToBonesAnim.ms"))

	on btnLightTable pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\LightTable.ms"))

	on btnCutSequence pressed do 
	(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\AnimaRange.ms"))

	on btnEndBone pressed do 
	(
		local tempLayerBoneEnd
		if (LayerManager.getLayerFromName "tempBoneEndAll") != undefined then
		(tempLayerBoneEnd = LayerManager.getLayerFromName "tempBoneEndAll")
		else (tempLayerBoneEnd = LayerManager.newLayerFromName "tempBoneEndAll")
		if selection.count != 0 then with undo on 
		(
			arrSel = selection as array
			for i in 1 to arrSel.count do
			(
				tempChild = execute ("$'" + arrSel[i].name + "'/...*")
				if (tempChild[tempChild.count] != undefined) then 
				(
					parentBone = tempChild[tempChild.count]
				)
				else (parentBone  = arrSel[i])
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
				tempLayerBoneEnd.addNode newBone
			)
			messageBox "注意：\r\n\r\n点确定完成添加，\r\n\r\n会创建新层存放末端，\r\n\r\n重启软件后无法回退，\r\n\r\n可点击右键或手动清除之前添加的末端，\r\n\r\n（在 tempBoneEndAll 层中）                                     "
		)
		else (messagebox "请选择要添加末端的 Bone 骨骼~          " beep:false)
	)

	on btnEndBone rightclick do with undo on
	(
		if (LayerManager.getLayerFromName "tempBoneEndAll") != undefined then
		(
			tempLayerBoneEnd = LayerManager.getLayerFromName "tempBoneEndAll"
			tempLayerBoneEnd.nodes &arrLayerNodeTemp
			for i in arrLayerNodeTemp do delete i
			(LayerManager.getLayer 0).current = true
			LayerManager.deleteLayerByName "tempBoneEndAll"
			arrBoneEndAll = #()
			messagebox "点确定清理添加的骨骼末端 (在 tempBoneEndAll 层中的骨骼) ~          "
		)
	)
)
Createdialog rolBsKeyTools fgcolor:myFgColor pos:iniPos style:#()
clearListener()  ---------清除侦听器

(
	macroScript BulletKeyTools
	category:"_[BulletTools]"
	buttonText:"BsKeyTools"
	toolTip:"BulletKeyTools"
	(
		on execute do
		(
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
			catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)
)