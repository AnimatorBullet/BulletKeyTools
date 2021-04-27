global rolBsAnimButton 
try(destroyDialog rolBsAnimButton)catch()

global myFgColor
global myClickColor
global myCheckedColor ----fnGetColorTheme.ms

Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global iniPosAnimButtonTools
Global posAnimButtonMouMove     = [0,0]
Global switchAnimButtonMouState = false
global iniAnimButtonSelected    = 1

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
    iniPosAnimButtonTools = fnGetConfig iniPosAnimButtonTools "BsAnimButtonSet" "PosAnimButton" (mouse.screenpos as string)
    iniAnimButtonSelected = fnGetConfig iniAnimButtonSelected "BsAnimButtonSet" "AnimButtonSelected" "1"
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BsAnimButtonSet" "PosAnimButton" (iniPosAnimButtonTools as string)
)

---------------配合BulletTools工具的ini文件保存位置信息----------------------------------

rollout rolAnimBtn1 "模型"
(
    
)
rollout rolAnimBtn2 "蒙皮"
(
    
)
rollout rolAnimBtn3 "约束"
(
    
)
rollout rolAnimBtn4 "动画"
(
    
)
rollout rolAnimBtn5 "系统"
(
    
)

arrRolAnimBtn = #(
    #("☘︎模型☘︎",#(rolAnimBtn1)),
    #("☕︎蒙皮☕︎",#(rolAnimBtn2)),
    #("✜动画✜",#(rolAnimBtn3)),
    #("✈︎系统✈︎",#(rolAnimBtn4))
)	

rcmenu RCmenuConfig
(
    menuItem mAbout "📺 miHoYo_Bullet.S"

    on mAbout picked do 
    (shellLaunch "https://space.bilibili.com/2031113" "")
)

rollout rolBsAnimButton  "BsAnimButton_v1.0"
(
    local LastSubRollout = 1

    dotNetControl dotnetTabCon "System.Windows.Forms.TabControl" height:20 width:285 align:#center pos:[0,0]
    button btnExit "✖" width:20 height:20 pos:[980,0]  border:false
    button btnHelp "？" width:20 height:20 pos:[960,0]  border:false
    subRollout subRolMainUI width:1000 height:85 align:#center pos:[0,20]
    
    on btnHelp pressed do 
    (shellLaunch "https://www.notion.so/bullet4869/BsKeyTools-17b5ba7c37ae45f6a69ce90f45fa0657" "")

    on dotnetTabCon Selected itm do
    (
        if LastSubRollout != (itm.TabPageIndex+1) do --处理相同tab情况
        (
            for subroll in arrRolAnimBtn[LastSubRollout][2] do
                removeSubRollout subRolMainUI subroll
            for subroll in arrRolAnimBtn[LastSubRollout = itm.TabPageIndex+1][2] do	
                addSubRollout subRolMainUI subroll
        ) 
    )
    
    on rolBsAnimButton open do
    (
        fnSaveConfig ()  ---------------脚本位置等赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
        -- dotnetTabCon.Appearance = dotnetTabCon.Appearance.Buttons
        dotnetTabCon.dock     = dotnetTabCon.dock.Fill
        dotnetTabCon.Drawmode = dotnetTabCon.Drawmode.OwnerDrawFixed
        dotnetTabCon.SizeMode = dotnetTabCon.SizeMode.Fixed
        dotnetTabCon.ItemSize = dotNetobject "System.Drawing.Size" 70 20
        
        for aTab in arrRolAnimBtn do
        (
            dotnetTabCon.TabPages.add aTab[1]
        )
        for subroll in arrRolAnimBtn[1][2] do addSubRollout subRolMainUI subroll			
    )

	on rolBsAnimButton close do -- 关闭记忆浮动窗口位置
	(
        iniPosAnimButtonTools   = (GetDialogPos rolBsAnimButton)
		fnSetConfig ()
	)

	on rolBsAnimButton mbuttondown pos do 
	(
		try (destroydialog rolBsAnimButton) catch ()
	)

	on rolBsAnimButton lbuttondown posMou do
	(
		posAnimButtonMouMove = posMou
		switchAnimButtonMouState = on
	)

	on rolBsAnimButton lbuttonup posMou do
	(
		switchAnimButtonMouState = off
	)

	on rolBsAnimButton rbuttondown pos do 
	(
		popupMenu RCmenuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y]
	)

	on rolBsAnimButton mouseMove pos do
	(
		if switchAnimButtonMouState == on then
		(
			SetDialogPos rolBsAnimButton (mouse.screenpos - posAnimButtonMouMove)			
		)
	)

)
-- createDialog rolBsAnimButton 1000 100 fgcolor:myFgColor menu:RCmenuConfig
if (iniPosAnimButtonTools != 0) then 
(Createdialog rolBsAnimButton 1000 85 fgcolor:myFgColor pos:iniPosAnimButtonTools style:#())
else (Createdialog rolBsAnimButton 1000 85 fgcolor:myFgColor style:#())