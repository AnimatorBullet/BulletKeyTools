Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
-------------------------------------------------------------------------------
Global iniPos  	--位置保存记录
struct myScript (id,msName,dir)
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
---------------------------------------------------------------------BsKeyTools
Global iniPosAnimButtonTools
global iniAnimButtonSelected = 0
---------------------------------------------------------------------BsAnimButton
struct itemsFolder (name,dir)
Global iniPosOpenTools
Global iniWidthOpenTools = 340
Global iniDesktop        = (itemsFolder name:"Desktop" dir:"")
Global iniSelectedID     = 1
Global iniLikedFolder    = #()
Global iniFilterPrefix   = #()
--------------------------------------------------------------------------
Global iniPosRefTools
global iniLastRefFolder = (itemsFolder name:"" dir:"")
global iniRefFolder1    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder2    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder3    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder4    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniFilterRefName = #()
----------------------------------------------------------------------------------
global iniPosSelSetTools

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if ((nameAttr == "ArrMyScripts") or (nameAttr == "LikedFolder") \
	or (nameAttr == "Desktop") or (matchpattern nameAttr  pattern:"RefFolder*") \
	or (nameAttr == "LastRefFolder"))then
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

struct stLoadConfig
(
	fn fnLoadConfigBsKeyTools =
	(
		iniPos             = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" (0 as string)
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
	),
	fn fnLoadConfigBsAnimButton =
	(
		iniPosAnimButtonTools = fnGetConfig iniPosAnimButtonTools "BsAnimButtonSet" "PosAnimButton" (0 as string)
		iniAnimButtonSelected = fnGetConfig iniAnimButtonSelected "BsAnimButtonSet" "AnimButtonSelected" "0"
	),
	fn fnLoadConfigBsOpenTools =
	(
		iniPosOpenTools   = fnGetConfig iniPosOpenTools "BsOpenToolsSet" "PosOpenTools" (0 as string)
		iniSelectedID     = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		iniLikedFolder    = fnGetConfig iniLikedFolder "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
		iniFilterPrefix   = fnGetConfig iniFilterPrefix "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
		iniWidthOpenTools = fnGetConfig iniWidthOpenTools "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
		iniDesktop        = fnGetConfig iniDesktop "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
	),
	fn fnLoadConfigBsRefTools =
	(
		iniPosRefTools   = fnGetConfig iniPosRefTools "BsRefToolsSet" "PosRefTools" (0 as string)
		iniRefFolder1    = fnGetConfig iniRefFolder1 "BsRefToolsSet"  "RefFolder1" (iniRefFolder1 as string)
		iniRefFolder2    = fnGetConfig iniRefFolder2 "BsRefToolsSet"  "RefFolder2" (iniRefFolder2 as string)
		iniRefFolder3    = fnGetConfig iniRefFolder3 "BsRefToolsSet"  "RefFolder3" (iniRefFolder3 as string)
		iniRefFolder4    = fnGetConfig iniRefFolder4 "BsRefToolsSet"  "RefFolder4" (iniRefFolder4 as string)
		iniFilterRefName = fnGetConfig iniFilterRefName "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
		iniLastRefFolder = fnGetConfig iniLastRefFolder "BsRefToolsSet"  "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnLoadConfigSelSetTools =
	(
		iniPosSelSetTools = fnGetConfig iniPosSelSetTools "BsSelSetToolsSet" "PosSelSetTools" (0 as string)
	)
)
struct stSetConfig
(
	fn fnSetConfigBsKeyTools =
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
	),
	fn fnSetConfigBsAnimButton =
	(
		SetINISetting BulletConfig "BsAnimButtonSet" "PosAnimButton" (iniPosAnimButtonTools as string)
		SetINISetting BulletConfig "BsAnimButtonSet" "AnimButtonSelected" (rolBsAnimButton.dotnetTabCon.SelectedIndex as string)
	),
	fn fnSetConfigBsOpenTools =
	(
		SetINISetting BulletConfig "BsOpenToolsSet"  "PosOpenTools" (iniPosOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "SelectedID" (iniSelectedID as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
	),
	fn fnSetConfigBsRefTools =
	(
		SetINISetting BulletConfig "BsRefToolsSet"  "PosRefTools" (iniPosRefTools as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder1" (iniRefFolder1 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder2" (iniRefFolder2 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder3" (iniRefFolder3 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder4" (iniRefFolder4 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnSetConfigSelSetTools =
	(
		SetINISetting BulletConfig "BsSelSetToolsSet"  "PosSelSetTools" (iniPosSelSetTools as string)
	)
)