/*
* @Description: 关键帧小工具,逐渐丰富中
* @Author: Bullet.S
* @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-12-08 16:39:57
* @Email: animator.bullet@foxmail.com
*/

try(destroydialog rolloutBulletKeyTools)catch()
try(destroydialog rolFnKeys)catch()

struct myScript (id,dir)

Global posMouX           = mouse.screenpos.x
Global posMouY           = mouse.screenpos.y  --获取鼠标位置
Global posMouMoved       = [0,0]
Global posToolBtn        = [205,45]
Global switchMouseState  = false
Global switchSelKeyRange = 0
Global switchHideBones   = 0
Global switchToolPanel   = 0
Global arrLastSelRange   = #()
Global switchAllKeyRange = 0
Global arrLastAllRange   = #()

Global arrKeysTime         = #()  ----------biped和bone的首尾帧
Global arrLinkKeys         = #()  -----------存link帧
Global arrKeysSelected     = #()  -----------存选中的帧
--     Global arrBipedKeys = #()
Global keyFirst
Global keyEnd
Global keySelFirst
Global keySelEnd
Global fnFindFirstEndKey
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys
Global fnAddLinkTimesKeys
Global fnAddLinkParamsKeys
Global BulletConfig = ((getDir #scripts) + "\\BulletConfig.ini")  --配置文件路径
Global iniPos  --位置保存记录
Global iniHelpBtn = off--记录是否打开帮助模式
Global keyMovedOffset = 5
Global symbol ----选择的范围判断, 0左边,1右边,2全部
Global layerTraj --轨迹辅助层
Global arrTraj         = #()  ---轨迹存放数组, 方便删除
Global arrTempBones    = #()  ---隐藏骨骼临时存放数组
Global arrToolC1       = #()  ----------工具按钮数组
Global arrToolC2       = #()  ----------工具按钮数组
Global arrToolC3       = #()  ----------工具按钮数组
Global arrToolC4       = #()  ----------工具按钮数组
Global arrToolC5       = #()  ----------工具按钮数组
Global iniArrMyScripts = #()
Global idBtn           = 1
Global uiClientOffsets = undefined
-- Global myTimer = dotnetobject "System.Timers.Timer" 500 autoreset:true
------------------全局变量-------------------------------------------------------------------

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnSaveConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
	iniPos          = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" ([posMouX,posMouY] as string)
	switchToolPanel = fnGetConfig switchToolPanel "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
	idBtn           = fnGetConfig idBtn "BulletKeyToolsSet"  "idBtn" (idBtn as string)
	iniArrMyScripts = fnGetConfig iniArrMyScripts "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
	iniHelpBtn      = fnGetConfig iniHelpBtn "BulletKeyToolsSet"  "HelpBtn" (iniHelpBtn as string)
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "idBtn" (idBtn as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "HelpBtn" (iniHelpBtn as string)
)
---------------配合BulletTools工具的ini文件保存位置信息-----------------

-------------------帧率,播放速度--------------------------------------------------------------
Global valueFps
Global valuePlaySpeed = ""
Global strCurrentFps = framerate as string + " FPS"

rollout rolCustomFps ""
(
	edittext edtFpsValue "FPS: "  pos:[10,10] width:60 usePercentageWidth:true \
	percentageWidth:44.0 labelOnTop:false text:"60" bold:true readOnly:false --帧率数值
	button btnSetFps "Set" pos:[80,8]
	label labTips strCurrentFps

	on rolCustomFps open do 
	(
		edtFpsValue.text = framerate as string
		labTips.text = "当前帧率: " + framerate as string + " FPS"
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
		labTips.text = "当前帧率: " + framerate as string + " FPS"
		slidertime -= 1
		slidertime += 1
	)
)

fn fnSetFps numFps =
(
	framerate = numFps
	valueFps = numFps
	strCurrentFps = numFps as string + " FPS"
	rolloutBulletKeyTools.btnSetFpsAndSpeed.text = " |  " + strCurrentFps + "  | " + valuePlaySpeed + " |"
	slidertime -= 1
	slidertime += 1
)

fn judgePlaySpeedValue =
(
	case of
	(
		(timeConfiguration.playbackSpeed == 1):(valuePlaySpeed = "--1/4x--")
		(timeConfiguration.playbackSpeed == 2):(valuePlaySpeed = "--1/2x--")
		(timeConfiguration.playbackSpeed == 3):(valuePlaySpeed = "-- 1x --")
		(timeConfiguration.playbackSpeed == 4):(valuePlaySpeed = "-- 2x --")
		(timeConfiguration.playbackSpeed == 5):(valuePlaySpeed = "-- 4x --")
	)
)

fn fnSetSpeed numSpeed =
(
	timeConfiguration.playbackSpeed = numSpeed
	judgePlaySpeedValue ()
	rolloutBulletKeyTools.btnSetFpsAndSpeed.text = " |  " + strCurrentFps + "  | " + valuePlaySpeed + " |"
)

rcmenu menuSetFps
(
	menuItem menuCurrentFps "" enabled:false
	menuItem menuSet60Fps "-- 60 Fps --"
	menuItem menuSet30Fps "-- 30 Fps --"
	menuItem menuSet24Fps "-- 24 Fps --"
	separator menuSepCustom
	menuItem menuCustomFps "自定义帧率"

	on menuSetFps open do 
	(
		menuSetFps.menuCurrentFps.text = "当前帧率: " + framerate as string + " FPS"
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
		createdialog rolCustomFps 120 55 fgcolor:(color 255 20 100) \
		pos:[mouse.screenpos.x,mouse.screenpos.y]
	)
)

rcmenu menuSetSpeed
(
	menuItem menuCurrentSpeed "" enabled:false
	menuItem menuSet14Speed "-- 1/4x --"
	menuItem menuSet12Speed "-- 1/2x --"
	separator menuSepSpeedLow
	menuItem menuSet1Speed "--  1x  --"
	separator menuSepSpeedHigh
	menuItem menuSet2Speed "--  2x  --"
	menuItem menuSet4Speed "--  4x  --"

	on menuSetSpeed open do 
	(
		judgePlaySpeedValue ()
		menuSetSpeed.menuCurrentSpeed.text = "当前播速: " + valuePlaySpeed
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
rollout rolloutBulletKeyTools "" width:200 height:235
(
	---------------------------------UI--------------------------------------
	groupbox gbxMainUI "[ K 帧工具_v0.7 ] ------ 中键关闭" pos:[5,5] width:190 height:175
	
		label lblRangeTimeText "| 起始帧 |      | 结束帧 |" pos:[10,25] width:180 \
		spinner spiStartTime "" pos:[10,45] width:50 type:#integer \
		range:[-999999999,999999999,animationrange.start] scale:1
		label lblTo "▃"  pos:[65,41] tooltip:"整数小数帧切换,\r\n平滑拖帧看卡顿" \
		width:20 height:20
		spinner spiEndTime "" pos:[80,45] width:50 type:#integer \
		range:[-999999999,999999999,animationrange.end] scale:1
		-- checkbutton ckbHelpBtn "？觉醒" pos:[135,23] width:55 height:20 border:false \
		-- tooltip:"打开帮助模式！"
		button btnMagicBtn "✧(≖ ◡ ≖" pos:[135,26] width:55 height:35 border:false \
		tooltip:"点我点我点我~良心小工具"
		edittext edtMoveKey "移动" width:70 usePercentageWidth:true percentageWidth:44.0 \ 
		pos:[10,75] labelOnTop:false text:"5f" bold:true readOnly:false 
		button btnSet5 "5f" width:35 pos:[90,72]
		button btnSetAdd "+5f" width:35 pos:[125,72]
		button btnSetOpposite "负" width:30 pos:[160,72]
		checkBox btnJudgeLinkKey "Link?" \
		pos:[18,107] tooltip:"是否存在Link帧?" checked:false 
		button btnSelBeforeKeys " " \
		pos:[70,98] width:30 height:30 toolTip:"选择滑条前面关键帧" border:false
		button btnSelAllKeys " " \
		pos:[100,98] width:30 height:30 toolTip:"选择所有关键帧" border:false
		button btnSelAfterKeys " " \
		pos:[130,98] width:30 height:30 toolTip:"选择滑条后面关键帧" border:false
		button btnMoveKeys " " width:30 height:30 \
		pos:[160,98] toolTip:"移动关键帧,先左边选帧\r\n左：帧栏范围保持不变~\r\n右：帧栏范围同步增减~" border:false
		button btnFileOpen "★  美好时光" pos:[10,130] width:70 height:22.5 \
		tooltip:"快速打开max文件\r\n可收藏常用目录" border:false
		button btnCutFrameDisplay "◐ 帧预览" pos:[80,130] width:60 height:22.5 \
		tooltip:"左：预览选择帧范围\r\n右：预览全部帧范围\r\n再点回到上次帧范围\r\n别晃晕了。╮(￣▽￣)╭" border:false
		button btnSpringMagic "✿ 飘带" pos:[140,130] width:50 height:22.5 \
		tooltip:"左点新版,右点旧版\r\n不久可能会有强化版~" border:false
		button btnQuickSave "✪ 备份|另存" pos:[10,153] width:70 height:22.5 \
		toolTip:"左：快速备份\r\n右：另存文件" border:false
		button btnSetFpsAndSpeed " " pos:[80,153] width:110 height:22.5 \
		toolTip:"左：设置帧率\r\n右：播放速度" border:false
	
	groupbox gbxMinTools "" pos:[200,5] width:160 height:225
	
		button btnC1 "帧" width:30 height:25 \
		pos:[205,15] toolTip:""
		button btnC2 "显" width:30 height:25 \
		pos:[235,15] toolTip:""
		button btnC3 "选" width:30 height:25 \
		pos:[265,15] toolTip:""
		button btnC4 "骨" width:30 height:25 \
		pos:[295,15] toolTip:""
		button btnC5 "乱" width:30 height:25 \
		pos:[325,15] toolTip:""

		button btnBoneTraj "◆ Bone轨迹" width:150 height:30   visible:false \
		toolTip:"左：切换显示Bone轨迹,\r\n右：清除所有Bone轨迹"
		button btnBipedTraj "◇ Biped轨迹" width:150 height:30   visible:false \
		toolTip:"左：切换显示单个Biped轨迹,\r\n右：切换显示所有Biped轨迹~"
		button btnFnFrame "● 整小数帧" width:150 height:30   visible:false \
		tooltip:"整数小数帧切换,\r\n平滑拖帧看卡顿"
		button btnSelByColor "◪ 同色选择" width:150 height:30   visible:false \
		tooltip:"选择同颜色物体"
		button btnFnTCB "☯ TCB 互转" width:150 height:30   visible:false \
		tooltip:"欧拉和TCB互转"
		button btnEulerFilter "✈ 欧拉过滤" width:150 height:30   visible:false \
		tooltip:"Bone骨骼过滤欧拉旋转"
		button btnBoneTool "❁ 骨骼工具" width:150 height:30   visible:false \
		tooltip:"左：骨骼工具,\r\n右：BoneOn切换"
		button btnNiceSet "✎ 易用设置" width:150 height:30   visible:false \
		tooltip:"改K帧键，自动备份等设置"
		button btnNull13 " < 未定义 > " width:150 height:30   visible:false \
		tooltip:"功能待添加"
		button btnClearSelKeys "▲ 取消选帧" width:150 height:30   visible:false \
		tooltip:"取消关键帧选择 (非删除帧)"
		button btnDelOutKeys "✖ 删关键帧" width:150 height:30   visible:false \
		toolTip:"左：清除选择或所有帧\r\nLink帧请手动删~\r\n右：清范围外帧(无限帧)"
		checkbutton ckbFreezeMesh "✲ 冻结模型" width:150 height:30   visible:false \
		toolTip:"冻结解冻模型"
		button btnHideBones "☁ 隐藏骨骼" width:150 height:30   visible:false \
		toolTip:"左：隐藏bone\r\n右：隐藏biped和bone"
		button btnSelBoneBiped "☑ 选择骨骼" width:150 height:30   visible:false \
		toolTip:"左：选择所有biped\r\n右：选择所有bone"
		button btnEndBone "✚ 末端操作" width:150 height:30   visible:false \
		toolTip:"清除添加Bone末端"
		checkbutton ckbFnBoxDisplay "㊣ BOX切显" width:150 height:30   visible:false \
		toolTip:"左:骨骼切换Box显示\r\n右:Clay显示开关"
		button btnFastAlign "▌ 快速对齐" width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnNull2 " < 未定义 > " width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnNull3 " < 未定义 > " width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnFnKeyType "♣  改滑动帧" width:150 height:30   visible:false \
		toolTip:"批量转换滑动关键帧等,\r\n后续可能按需优化更多设置"
		button btnCopyKeyTools "✔ 暴力粘贴" width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnAnimMirror "〼 动画镜像" width:150 height:30   visible:false \
		toolTip:"功能待添加"
		checkbutton ckbFnMtlDisplay "▣ 白模切显" width:150 height:30   visible:false \
		toolTip:"左:切换显示隐藏贴图,方便白模预览\r\n右:\r\n注意：暂不支持子材质..."
		button btnNull8 " < 未定义 > " width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnNull9 " < 未定义 > " width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnCSTools "❤  CS 选择" width:150 height:30   visible:false \
		toolTip:"快速选择CS骨骼\r\n右键添加或解除自启"
		button btnCutSequence "✄ 时间标签 " width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnPoseTool "♚ Pose 存取" width:150 height:30   visible:false \
		toolTip:"功能待添加"
		button btnMopherSlider "☺ 表情滑条" width:150 height:30   visible:false \
		toolTip:"选择带morpher的mesh，\r\n打开快速调节滑条方便K表情~"
		button btnImportOut "◮ 导入导出" width:150 height:30   visible:false \
		toolTip:"功能待添加"
	
	-- groupbox gbxMyScripts "" pos:[5,230] width:335 height:45

		button btnMyScripts1 "< ＋＋＋ >" pos:[5,232] width:70 height:20 border:false
		button btnMyScripts2 "< ＋＋＋ >" pos:[76,232] width:70 height:20 border:false
		button btnMyScripts3 "< ＋＋＋ >" pos:[147,232] width:70 height:20 border:false
		button btnMyScripts4 "< ＋＋＋ >" pos:[218,232] width:70 height:20 border:false
		button btnMyScripts5 "< ＋＋＋ >" pos:[290,232] width:70 height:20 border:false

	groupbox gbxTips "" pos:[5,180] width:190 height:50
	
		HyperLink lnkLink "---  | 2019.9  miHoYo_Bullet.S |  - ？ --"
		color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
		pos:[7,190] address:"https://space.bilibili.com/2031113"
		label labmiHoYo "--- TECH OTAKUS SAVE THE WORLD --" \
		pos:[7,210]

		-- timer tick_tock interval:666 active:iniHelpBtn
----------------------------------UI及作者ID------------------------------------------------
	fn fnRefreshMagicBtn =
	(
		if switchToolPanel == 0 then
		(
			rolloutBulletKeyTools.width               = 200
			rolloutBulletKeyTools.height              = 235
			rolloutBulletKeyTools.gbxMinTools.visible = false
			btnMagicBtn.text                          = "✧(≖ ◡ ≖"
		)
		else
		(
			rolloutBulletKeyTools.width               = 365
			rolloutBulletKeyTools.height              = 255
			rolloutBulletKeyTools.gbxMinTools.visible = true
			btnMagicBtn.text                          = "( = `▽`)"
		)
	)

	fn fnSwitchMagicBtn =
	(
		if switchToolPanel == 1 then
		(
			rolloutBulletKeyTools.width               = 200
			rolloutBulletKeyTools.height              = 235
			rolloutBulletKeyTools.gbxMinTools.visible = false
			btnMagicBtn.text                          = "✧(≖ ◡ ≖"
			switchToolPanel                           = 0
		)
		else
		(
			rolloutBulletKeyTools.width               = 365
			rolloutBulletKeyTools.height              = 255
			rolloutBulletKeyTools.gbxMinTools.visible = true
			btnMagicBtn.text                          = "( = `▽`)"
			switchToolPanel                           = 1
		)
	)

	fn fnSwitchToolsBtn idBtn =
	(
		arrToolC1 = #(rolloutBulletKeyTools.btnClearSelKeys,\
						rolloutBulletKeyTools.btnDelOutKeys,\
						rolloutBulletKeyTools.btnFastAlign,\
						rolloutBulletKeyTools.btnCopyKeyTools,\
						rolloutBulletKeyTools.btnAnimMirror,\
						rolloutBulletKeyTools.btnFnKeyType)
		arrToolC2 = #(rolloutBulletKeyTools.btnBoneTraj,\
						rolloutBulletKeyTools.btnBipedTraj,\
						rolloutBulletKeyTools.btnFnFrame,\
						rolloutBulletKeyTools.btnHideBones,\
						rolloutBulletKeyTools.ckbFnBoxDisplay,\
						rolloutBulletKeyTools.ckbFnMtlDisplay)
		arrToolC3 = #(rolloutBulletKeyTools.ckbFreezeMesh,\
						rolloutBulletKeyTools.btnSelByColor,\
						rolloutBulletKeyTools.btnSelBoneBiped,\
						rolloutBulletKeyTools.btnNull8,\
						rolloutBulletKeyTools.btnNull9,\
						rolloutBulletKeyTools.btnCSTools)
		arrToolC4 = #(rolloutBulletKeyTools.btnFnTCB,\
						rolloutBulletKeyTools.btnEulerFilter,\
						rolloutBulletKeyTools.btnEndBone,\
						rolloutBulletKeyTools.btnNull3,\
						rolloutBulletKeyTools.btnNull2,\
						rolloutBulletKeyTools.btnBoneTool)
		arrToolC5 = #(rolloutBulletKeyTools.btnPoseTool,\
						rolloutBulletKeyTools.btnMopherSlider,\
						rolloutBulletKeyTools.btnCutSequence,\
						rolloutBulletKeyTools.btnImportOut,\
						rolloutBulletKeyTools.btnNull13,\
						rolloutBulletKeyTools.btnNiceSet)

		local arrBtnAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4 + arrToolC5
		
		for b in arrBtnAll do
		(
			b.visible = false
			-- b.width = 75
			-- b.height = 32
		)

		str  = "for b = 1 to arrToolC" + idBtn as string + ".count do" + "\r\n"
		str += "(" + "\r\n"
		str += "	arrToolC" + idBtn as string + "[b].visible = true" + "\r\n"
		str += "	arrToolC" + idBtn as string + "[b].pos = " + posToolBtn as string + " + [0,(b - 1) * 30]" + "\r\n"
		str += ")"
		
		execute str
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
					if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
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
							if i.selected == true then appendIfUnique arrKeysSelected i.time
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
										if i.selected == true then appendIfUnique arrKeysSelected i.time
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
						if i.selected == true then appendIfUnique arrKeysSelected i.time
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
						if i.selected == true then appendIfUnique arrKeysSelected i.time
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
							if i.selected == true then appendIfUnique arrKeysSelected i.time
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
					if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
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
								if i.selected == true then appendIfUnique arrKeysSelected i.time
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
		case of  -----------处理选中,未选中则处理全部
		(
			(selection.count == 0):
			(
				for i in (objects as array) where (i.ishidden == false) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
			default:
			(
				for i in (selection as array) where (i.ishidden == false) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
		)
	)
	
	fn fnChangetRangeTime =   ------------关键帧数字随滑条改变
	(
		rolloutBulletKeyTools.spiStartTime.value = animationrange.start
		rolloutBulletKeyTools.spiEndTime.value = animationrange.end
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
				if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then
				(
					fnSelLinkKeys keyFirst KeyEnd symbol --------------选中link帧
				)
			)
			else
			(
				if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then
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
	
	mapped fn fnMoveKeysAndLinkKeys obj offset =  ----https://forums.cgsociety.org/t/moving-keys-from-link-constraint-keys-access/1575053
	(
		local arrTargetID  = #()
		moveKeys obj offset #selection  ---先移动非link帧
		if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then 
		(
			if classof obj.controller == Link_Constraint do
			(
				nTargets = obj.controller.getNumTargets()  ---得到link的帧数量
	
				if nTargets > 0 do
				(
					for i = nTargets to 1 by -1 do  ------如果大于0则从最后link帧开始移
					(
						fNumber = obj.controller.getFrameNo i
						if ((fNumber >= keySelFirst) and (fNumber <= keySelEnd)) then
						(
							appendIfUnique arrTargetID i
						)
					)
					if offset > 0 then  --------判断向前还是向后移动帧
					(
						for i = arrTargetID.count to 1 by -1 do  ------如果大于0则从最后link帧开始移
						(
							fNumber = obj.controller.getFrameNo arrTargetID[i]
							obj.controller.setFrameNo i (fNumber + offset)
						)
					)
					else
					(
						for i = 1 to arrTargetID.count do  ---如果移动帧小于0,从第一个link帧开始移
						(
							fNumber = obj.controller.getFrameNo arrTargetID[i]
							obj.controller.setFrameNo i (fNumber + offset)
						)
					)
				)
			)
		)
	)

	-- fn fnSplitSelBiped = --分开选择四肢和身体,例如同一条手臂只选择最父级的(方便移动帧)
	-- (
	-- 	arrSelBiped = for i in selection where classof i.controller == BipSlave_Control collect i 

	-- )

	fn fnMoveBipedKeys offsetFrame =  -------移动Biped帧
	(
		bipedRoot = #()   -------判断选择了几个biped骨架
		for i in selection where ((classof i == Biped_Object) and (i.ishidden == false)) do  
		(
			appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
		)
		for c in bipedRoot do  ---按每个骨架处理
		(
			ctrlBiped = c.controller
			bipedAll = #(biped.getNode ctrlBiped #pelvis, -----四肢同帧处理,只处理他首节biped
						biped.getNode ctrlBiped #spine,
						biped.getNode ctrlBiped #neck,
						biped.getNode ctrlBiped #larm,
						biped.getNode ctrlBiped #rarm,
						biped.getNode ctrlBiped #lleg,
						biped.getNode ctrlBiped #rleg,
						biped.getNode ctrlBiped #prop1,
						biped.getNode ctrlBiped #prop2,
						biped.getNode ctrlBiped #prop3,
						biped.getNode ctrlBiped #tail)

			vertCtrl = ctrlBiped.vertical.controller  -----质心ctrl关键帧
			horzCtrl = ctrlBiped.horizontal.controller
			if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
			(turnCtrl = ctrlBiped.flip.controller)
			else(turnCtrl = ctrlBiped.turning.controller)
			bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
			for c in bipCtrlTemp do
			(
				biped.moveKeys c offsetFrame #selection  -----移动选定的质心帧
			)
			for nodeBiped in bipedAll where nodeBiped != undefined do  -----移动其他biped的选定帧
			(
				biped.moveKeys nodeBiped.controller offsetFrame #selection
			)
		)
	)		

	mapped fn fnMoveBipedScaleKeys tempObj offsetFrame =  -------移动biped的缩放帧
	(
		ctrlBiped = tempObj.controller
		if classof ctrlBiped == BipSlave_Control then  --------下面判定子动画是否为scaleXYZ
		(
			if ((ctrlBiped[1][1] != undefined) and ((getSubAnimName ctrlBiped[1][1] 1) == #ScaleXYZ)) then
			(
				movekeys ctrlBiped[1][1][1] offsetFrame #selection
			)
		)
	)

	fn fnMoveAllKeys keyMovedOffset fnRange:off =
	(
		local rangEnd = animationrange.end
		local rangeStart = animationrange.start
		local n = 0  --n来判定是否有选中biped

		if keyMovedOffset != undefined then
		(
			if selection.count != 0 then
			(
				for i in selection where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset
					)
					else 
					(
						fnMoveBipedScaleKeys i keyMovedOffset
						n += 1
					)
				)
				if n != 0 then  ----------分开解决biped多移动的问题,傻瓜式方法
				(
					fnMoveBipedKeys keyMovedOffset
				)
			)
			else  ---跟上面一样,只是对所有物体
			(
				for i in objects where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset
					)
					else fnMoveBipedScaleKeys i keyMovedOffset
				)
				fnMoveBipedKeys keyMovedOffset
			)
			if fnRange == on then
			(
				if keyMovedOffset > 0 then 
				(
					rangEnd = animationrange.end + keyMovedOffset
					animationrange = interval animationrange.start rangEnd
				)
				else if keyMovedOffset < 0 then 
				(
					rangeStart = animationrange.start + keyMovedOffset
					animationrange = interval rangeStart animationrange.end
				)
			)
			keySelFirst += keyMovedOffset
			keySelEnd  += keyMovedOffset
		)
	)

	fn fnAddTrajLayer =
	(
		if (LayerManager.getLayerFromName "Biped_Trajectories") != undefined then
		(
			layerTraj = LayerManager.getLayerFromName "Biped_Trajectories"
		)
		else layerTraj = LayerManager.newLayerFromName "Biped_Trajectories"
		layerTraj.lock = on
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
			arrFilesNum = for i in arrFiles collect \
			(fnGetVerNum (getFilenameFile i)) as integer;sort arrFilesNum
			suffixFile = arrFilesNum[arrFilesNum.count] + 1
		)
		else suffixFile = 1
		fileSave = maxFilePath + nameCurrentFile + strNameSplit + (suffixFile as string) + ".max"
		saveMaxFile fileSave
	)

	fn fnCutDisplayKeyRange keyFirst keyEnd =  ---显示首尾帧范围
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

	fn fnHelpPosRange btnPos btnSize:[75,32] =
	(
		local mouseClientPos = mouse.screenPos - (getDialogPos rolloutBulletKeyTools) + uiClientOffsets
		-- local btnPos = pos
		-- local btnSize = [75,32]
		local btnBox = (Box2 btnPos.x btnPos.y btnSize.x btnSize.y)

		local dialogPos = getDialogPos rolloutBulletKeyTools
		local dialogBox = (Box2 dialogPos.x dialogPos.y \
			rolloutBulletKeyTools.width rolloutBulletKeyTools.height)
		return (contains btnBox mouseClientPos)
	)

	-- fn fnRefreshHelpText = 
	-- (
	-- 	if ((ckbHelpBtn.state) and (uiClientOffsets != undefined)) then 
	-- 	(
	-- 		posToolBtn1 = posToolBtn
	-- 		posToolBtn2 = posToolBtn + [0,32]
	-- 		posToolBtn3 = posToolBtn + [0,2 * 32]
	-- 		posToolBtn4 = posToolBtn + [0,3 * 32]
	-- 		posToolBtn5 = posToolBtn + [0,4 * 32]
	-- 		posToolBtn6 = posToolBtn + [0,5 * 32]

	-- 		if (fnHelpPosRange [245,26] btnSize:[90,192]) == true then 
	-- 		(
	-- 			if fnHelpPosRange posToolBtn1 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 取消关键帧选择 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " 显示轨迹  ||  清除所有 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " 冻结显示模型 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " TCB和欧拉属性互转 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " Pose库，要鸽 ")
	-- 				)
	-- 			)
	-- 			if fnHelpPosRange posToolBtn2 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 删选择帧  ||  删轴外帧 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " 切显单个  ||  切显所有 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " 根据颜色选择同色物体 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " Bone过滤欧拉曲线 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " Mopher表情选择滑条 ")
	-- 				)
	-- 			)
	-- 			if fnHelpPosRange posToolBtn3 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " 方便拖帧平滑预览 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " Biped骨骼 ||  Bone骨骼 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " 清除末端  ||  添加末端 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " 动画片断标签，要鸽 ")
	-- 				)
	-- 			)
	-- 			if fnHelpPosRange posToolBtn4 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " Bone骨骼 ||  Biped骨骼 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " 批量导入导出，要鸽 ")
	-- 				)
	-- 			)
	-- 			if fnHelpPosRange posToolBtn5 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " Box显示   ||  Clay显示 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " 功能待添加 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " 功能待添加  ")
	-- 				)
	-- 			)
	-- 			if fnHelpPosRange posToolBtn6 == true then
	-- 			(
	-- 				case of 
	-- 				(
	-- 					(idBtn == 1):(gbxMinTools.caption = " 批量转换滑动帧 ")
	-- 					(idBtn == 2):(gbxMinTools.caption = " 隐藏贴图，预览动画 ")
	-- 					(idBtn == 3):(gbxMinTools.caption = " 选择CS骨骼工具 ")
	-- 					(idBtn == 4):(gbxMinTools.caption = " 打开BoneTools面板 ")
	-- 					(idBtn == 5):(gbxMinTools.caption = " 快捷键，备份设置 ")
	-- 				)
	-- 			)
	-- 		)
	-- 		else 
	-- 		(
	-- 			gbxMinTools.caption = " < 小工具说明 > "
	-- 			myTimer.stop()
	-- 		)
	-- 	)
	-- )

	fn fnHidebyCategory cate:BoneGeometry =
	(
		if switchHideBones == 0 then
		(
			for o in objects where ((classof o == cate) and (o.isHidden == false)) do
			(
				append arrTempBones o
			)
			for b in arrTempBones do
			(
				b.isHidden = true
			)
			switchHideBones = 1
		)
		else
		(
			for b in arrTempBones do
			(
				b.isHidden = false
			)
			arrTempBones = #()
			switchHideBones = 0
		)
	)

	on rolloutBulletKeyTools open do  ----打开脚本时操作
	(------刷新图标, 图标是max自带的,主要是懒得做
		btnSelBeforeKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,3,3,3,3,true,true) 
		btnSelAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
		btnSelAllKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,26,26,26,26,true,true)
		btnMoveKeys.images = #("ViewportNavigationControls_24i.bmp","ViewportNavigationControls_24i.bmp",46,39,39,39,39,true,true)
-- 		btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		-- dotnet.AddEventHandler myTimer #elapsed fnRefreshHelpText
		-- myTimer.Start()
		-- ckbHelpBtn.checked = iniHelpBtn
		timeDIsTemp      = timeDisplayMode  ----小数帧还是整数帧
		-- iniPos = (GetDialogPos rolloutBulletKeyTools) 
		fnSaveConfig ()  ---------------脚本位置赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		registerTimeCallback fnChangetRangeTime  -------------帧范围改变添加回调
		rolloutBulletKeyTools.gbxMinTools.visible  = false
		judgePlaySpeedValue ()  -----判断播放速度
		rolloutBulletKeyTools.btnSetFpsAndSpeed.text = " |  " + strCurrentFps + "  | " + valuePlaySpeed + " |"
		fnRefreshMagicBtn ()
		fnSwitchToolsBtn idBtn
	)
	
	on rolloutBulletKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolloutBulletKeyTools)
		fnSetConfig ()
	)
	-----------------------------------------------------------------------------------------
	on rolloutBulletKeyTools mbuttondown pos do 
	(
		try (destroydialog rolloutBulletKeyTools) catch ()
	)
	
	on rolloutBulletKeyTools lbuttondown posMou do
	(
		posMouMoved = posMou
		switchMouseState = on
	)
	
	on rolloutBulletKeyTools lbuttonup posMou do
	(
		switchMouseState = off
	)
	
	on rolloutBulletKeyTools mouseMove pos do
	(
		-- myTimer.Start()
		if switchMouseState == on then
		(
			SetDialogPos rolloutBulletKeyTools (mouse.screenpos - posMouMoved)			
		)
		if (uiClientOffsets == undefined) then 
		(
			uiClientOffsets = pos - (mouse.screenPos - (getDialogPos rolloutBulletKeyTools)) 
		)
	)

	-- on tick_tock tick do
	-- (
	-- 	fnRefreshHelpText ()
	-- )
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	on btnSelBoneBiped pressed do ----选择bone或者biped
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == Biped_Object then selectmore o
		)
	)

	on btnSelBoneBiped rightclick do ----选择bone或者biped
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

	-- on ckbHelpBtn changed state do 
	-- (
	-- 	iniHelpBtn = state
	-- 	if state == off then 
	-- 	(
	-- 		gbxMinTools.caption = " < 小工具说明 > "
	-- 		-- tick_tock.active = false
	-- 	)
	-- 	-- else tick_tock.active = true
	-- )

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

	on btnBoneTraj pressed do ------显示bone的轨迹
	(
		for i in (selection as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
			else i.showtrajectory = true
		)
	)

	on btnBoneTraj rightclick do   ----右键取消bone的轨迹显示
	(
		for i in (objects as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
		)
	)

	on btnBipedTraj pressed do 
	(
		fnAddTrajLayer () ----是否创建轨迹层
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
		-- bipedRoot = #()   -------判断选择了几个biped骨架
		if (selection.count > 0) then
		(
			-- for i in (selection as array) where classof i == Biped_Object do  
			-- (
			-- 	appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
			-- )
			for i in (selection as array) do 
			(
				if (classof i == Biped_Object) then
				(
					nodeTemp = i.controller.rootNode
					trajDisFn = nodeTemp.controller.displayTrajectories
					if trajDisFn == true then nodeTemp.controller.displayTrajectories = false
					else nodeTemp.controller.displayTrajectories = true
					exit
				)
			)
		)
	)

	on edtMoveKey entered val do   -----移动帧数自定义,输入即可
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(------"."他也认为是数字...
			keyMovedOffset = val as integer
			rolloutBulletKeyTools.edtMoveKey.text = keyMovedOffset as string + "f"
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
	
	on btnSetFpsAndSpeed pressed do popupMenu menuSetFps
		
	on btnSetFpsAndSpeed rightclick do popupMenu menuSetSpeed

	on btnClearSelKeys pressed do  ---------------------清除帧选择
	(
		fnCollectKeys ()
		if arrKeysTime.count != 0 then  ----清除非link帧
		(
			for i in objects where (i.ishidden == false) do 
			(
				deselectKeys i
				if classof i == Biped_Object then
				(
					ctrlBiped      = i.controller
					numLayers      = biped.numLayers ctrlBiped
					idCurrentLayer = biped.getCurrentLayer ctrlBiped
					while numLayers >= 0 do
					(
						biped.setCurrentLayer ctrlBiped numLayers
						deselectKeys i
						numLayers -= 1
					)
					biped.setCurrentLayer ctrlBiped idCurrentLayer
				)
			)
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then  ---清除link帧
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
	)
	
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

	on btnDelOutKeys rightclick do with undo on-----------清理范围外帧(无限帧)
	(
		if (selection as array).count == 0 then 
		(
			for tempObject in (objects as Array) do fnCleanOutRangeKeys tempObject
		)
		else
		(
			for tempObject in (selection as Array) do fnCleanOutRangeKeys tempObject
		)
	)

	on btnDelOutKeys pressed do with undo on-----------清理选择帧
	(
		if selection.count != 0 then fnDelSelKeys ()
		else
		(
			actionMan.executeAction 0 "40021"  -- Selection: Select All
			fnCollectKeys ()
			fnSelKeys keyFirst keyEnd 2
			fnDelSelKeys ()
			if arrLinkKeys.count != 0 then
			(
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time 2
			)
		)
	)

	on btnHideBones pressed do
	(
-- 		if hideByCategory.bones == false then 
-- 		(
-- 			hideByCategory.bones = true
-- 			btnHideBones.text = "☀ 显示骨骼"
-- 		)
-- 		else 
-- 		(
-- 			hideByCategory.bones = false
-- 			btnHideBones.text = "☁ 隐藏骨骼"
-- 		)
-- 		redrawviews()
-- 		slidertime -= 1
-- 		slidertime += 1
		fnHidebyCategory cate:BoneGeometry
	)
	
	on btnHideBones rightclick do
	(
		fnHidebyCategory cate:Biped_Object
	)

	on ckbFreezeMesh changed state do 
	(
		if state == on then
		(
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject)) \
			and (o.isHidden == false)) do
			(
				freeze o
				o.showFrozenInGray = off
			)
			ckbFreezeMesh.text = "☀ 解冻模型"
		)
		else
		(
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject)) \
			and (o.isHidden == false)) do
			(
				unfreeze o
				o.showFrozenInGray = off
			)
			ckbFreezeMesh.text = "✲ 冻结模型"
		)
	)

	on btnQuickSave pressed do 
	(
		if maxFilePath == "" then 
		(
			messagebox "------------------------------------\r\n当前场景未保存过,\r\n请先右键点击保存初始版本~"
		)
		else fnQuickSave ()
	)
	on btnQuickSave rightclick do 
	(
		max file saveas
	)

	on btnCutFrameDisplay pressed do with undo on  ---------------帧栏显示首尾帧范围
	(
		if switchSelKeyRange == 0 then
		(
			arrLastSelRange = #(animationrange.start,animationrange.end)
			fnCollectKeys ()
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
	on btnCutFrameDisplay rightclick do with undo on  ---------------帧栏显示首尾帧范围
	(
		if switchAllKeyRange == 0 then
		(
			arrLastAllRange = #(animationrange.start,animationrange.end)
			fnCollectKeys ()
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

	------------切换工具栏分类--------------------------------------------
	on btnC1 pressed do (idBtn = 1;fnSwitchToolsBtn idBtn)
	on btnC2 pressed do (idBtn = 2;fnSwitchToolsBtn idBtn)
	on btnC3 pressed do (idBtn = 3;fnSwitchToolsBtn idBtn)
	on btnC4 pressed do (idBtn = 4;fnSwitchToolsBtn idBtn)
	on btnC5 pressed do (idBtn = 5;fnSwitchToolsBtn idBtn)
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

	on btnBoneTool pressed do (macros.run "Animation Tools" "BoneAdjustmentTools")

	on btnBoneTool rightclick do 
	(
		for i in selection where classof i == BoneGeometry do
		(
			if i.boneEnable == false then i.boneEnable = true
			else i.boneEnable = false
		)
	)
	
	on btnFnKeyType pressed do 
	(
		try(destroydialog rolFnKeys)catch()
		Createdialog rolFnKeys fgcolor:(color 255 20 100)
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
		for o in Geometry where (o.isHidden == false) do 
		(
			if ((classof o == BoneGeometry) or (classof o == Biped_Object)) then
			(
				if state == on then o.boxmode = on 
				else o.boxmode = off
			)
		)
	)
	on ckbFnBoxDisplay rightclick do 
	(
		local disp = NitrousGraphicsManager.GetActiveViewportSetting() 
		if disp.VisualStyleMode == #clay then disp.VisualStyleMode = #Realistic
		else disp.VisualStyleMode =  #clay
	)
	
	on ckbFnMtlDisplay changed state do 
	(
		if state == off then
		(
			for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat on
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat on
		)
		else
		(
			for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat off
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat off
		)
	)

	-- on ckbFnMtlDisplay rightclick do 
	-- (
		
	-- )

	on btnMopherSlider pressed do 
	(
		macros.run "Tools" "MorphSliders"
	)
)
Createdialog rolloutBulletKeyTools fgcolor:(color 255 20 100) pos:iniPos style:#()
-- clearListener()  ---------清除侦听器


------------------------toolbar----------------------------------------------------
macroScript BulletKeyTools
category:"_[BulletTools]"
buttonText:"K帧工具"
toolTip:"K帧工具"
-- Icon:#("Systems",2)
(
	on execute do
	(
		fileIn ((getDir #Scripts)+ "\\BulletScripts\\" + "BulletKeyTools.ms")
	)
)
-------------------------------------------------------------------------------------