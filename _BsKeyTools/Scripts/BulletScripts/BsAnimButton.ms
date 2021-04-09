global rolBsAnimButton 
try(destroyDialog rolBsAnimButton)catch()

global myFgColor
global myClickColor
global myCheckedColor ----fnGetColorTheme.ms

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
    #("✜约束✜",#(rolAnimBtn3)),
    #("⚔︎动画⚔︎",#(rolAnimBtn4)),
    #("✈︎系统✈︎",#(rolAnimBtn5))
)	

rcmenu RCmenuConfig
(
    menuItem mConfig "设置"
    menuItem mHelp "帮助"
    menuItem mAbout "📺 miHoYo_Bullet.S"
    menuItem mTips "[整合常用命令]" enabled:false

	on mHelp picked do 
	(shellLaunch "https://www.notion.so/bullet4869/BsKeyTools-17b5ba7c37ae45f6a69ce90f45fa0657" "")

    on mAbout picked do 
    (shellLaunch "https://space.bilibili.com/2031113" "")
)

rollout rolBsAnimButton  "BsAnimButton_v1.0"
(
    local LastSubRollout = 1

    dotNetControl dotnetTabCon "System.Windows.Forms.TabControl" height:20 width:300 align:#center pos:[5,5]
    -- edittext lblBilibili "" pos:[0,480] readonly:true width:305 height:15 text:"https://space.bilibili.com/2031113"
    subRollout subRolMainUI width:310 height:500 align:#center pos:[0,28]
    
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
        for aTab in arrRolAnimBtn do
        (
            dotnetTabCon.TabPages.add aTab[1]
        )
        for subroll in arrRolAnimBtn[1][2] do addSubRollout subRolMainUI subroll				
    )

)
createDialog rolBsAnimButton 310 500 fgcolor:myFgColor menu:RCmenuConfig