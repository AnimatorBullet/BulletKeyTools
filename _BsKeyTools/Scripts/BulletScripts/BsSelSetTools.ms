/*
 * @Description: 选择集工具 修改自:@Takayuki Sato
 * @Author: Bullet.S
 * @Date: 2021-05-07 12:33:36
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-05-08 14:07:57
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolSelSetTools)catch()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfig.fnLoadConfigSelSetTools ()

global rolSelSetTools
global rolLoadSelSet
global dotNetXmlDoc = dotNetObject "System.xml.xmlDocument"
global strXmlRootName = "SelectionSet_Tools"
Global switchRolSelSetMouState = false
Global posRolSelSetMouMove     = [0,0]

global arrSelSetNameLoaded
global arrSelSetObjLoaded

fn fnSaveSelSetAll pathXml = 
(
	local rootElement = dotNetXmlDoc.createElement strXmlRootName
	dotNetXmlDoc.appendChild rootElement

	for s in selectionSets do
	(
		local setElement = dotNetXmlDoc.createElement "SelectionSet"
		setElement.SetAttribute "SetName" s.name
		rootElement.appendChild setElement

		for o in s do
		(
			local objElement = dotNetXmlDoc.createElement "ObjectName"
			objElement.InnerText = o.name
			setElement.appendChild objElement
		)
	)
	dotNetXmlDoc.save pathXml
)

fn fnLoadSelXml pathXml = 
(
	dotNetXmlDoc.Load pathXml
	local rootElement = dotNetXmlDoc.DocumentElement
	
	if rootElement.name != strXmlRootName then
	(
		messagebox "这不是BsSelSetTools创建的XML文件。          \t"
		return undefined
	)
	
	local nodesSelSet = rootElement.ChildNodes

	local arrSelSetName = #()
	local arrSelSetObj = #()

	for i = 0 to nodesSelSet.count - 1 do
	(
		local elemSelSet = nodesSelSet.Item[i]
		
		append arrSelSetName (elemSelSet.Attributes.GetNamedItem "SetName").value
		
		local objNodes = elemSelSet.ChildNodes
		
		arrSelSetObj[i+1] = #()
		for j = 0 to objNodes.count - 1 do
		(
			local objElement = objNodes.Item[j]
			append arrSelSetObj[i+1] objElement.InnerText
		)
	)
	local result = #(arrSelSetName, arrSelSetObj)
	return result
)

fn fnCreateSelSet arrSelSetName arrSelSetObj n = 
(
	local re_selset_obj_list = #()
	for o in arrSelSetObj[n] do
	(
		if getNodeByName o != undefined  then
		(
			append re_selset_obj_list o
		)
	)
	if re_selset_obj_list.count != 0 then
	(
		local txt = "selectionSets[\""
		txt += arrSelSetName[n] + "\"] = #("
		for o in re_selset_obj_list do
		(
			txt += "$'" + o +"', "
		)
		txt = substring txt  1 (txt.count - 2)
		txt+= ")"

		execute txt
	)else
	(
		messagebox( "Selection Set \"" + arrSelSetName[n] + "\" 是空的。\n选择集\"" + arrSelSetName[n] + "\"包含的对象不在场景中，所以未被读取...                    \t")
	)
)
fn fnUpdateSelSetList = 
(
	local arrNodesList = #()
	for s in selectionSets do append arrNodesList s.name
	sort arrNodesList
	rolSelSetTools.lbxSelSet.items = arrNodesList
	rolSelSetTools.lbxSelSet.selection = 0
	rolSelSetTools.lbxSelSetNode.items = #()
)

rollout rolLoadSelSet "Load_SelectionSet"
(
	multilistbox mlbLoadSelSet "SelectionSet List" height:22
	button btnLoadSel "Load selected" width:80 height: 25 across:2
	button btnLoadAll "Load ALL" width:80 height:25
		
	on btnLoadSel pressed do
	(
		for n in mlbLoadSelSet.selection do
		(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
	)
	
	on btnLoadAll pressed do(
		for n = 1 to mlbLoadSelSet.items.count do
		(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
	)
)

rollout rolSelSetTools "BsSelSetTools_v1.0"
(
	listbox lbxSelSet "[选择集] Selection Set" width:180 height:16 pos:[5,5]
	checkbutton chkMoreTools "更多" width:50 height:20 pos:[135,1]
	button btnUpdateList "更新列表" width:140 height:20 pos:[5,235]
	button btnCloseRol "关闭" width:40 height:20 pos:[145,235]

	button btnSaveXml "保存" width:60 height:20 pos:[190,0] enabled:false
	button btnLoadXml "加载" width:60 height:20 pos:[250,0] enabled:false
	listbox lbxSelSetNode "" width:120 height:16 pos:[190,20] enabled:false
	button btnHelp "必看帮助" width:120 height:20 pos:[190,235] enabled:false

	fn fnUpdateMoreToolsState =
	(
		btnSaveXml.enabled    = chkMoreTools.state
		btnLoadXml.enabled    = chkMoreTools.state
		lbxSelSetNode.enabled = chkMoreTools.state
		btnHelp.enabled       = chkMoreTools.state
		if chkMoreTools.state then rolSelSetTools.width = 315 else rolSelSetTools.width = 190
	)

	on btnHelp pressed do 
	(shellLaunch "https://www.notion.so/bullet4869/5e0e30442ad348a09d7aa45ea6f8d53a" "")

	on rolSelSetTools mbuttondown pos do 
	(
		try (destroydialog rolSelSetTools) catch ()
	)

	on rolSelSetTools lbuttondown posMou do
	(
		posRolSelSetMouMove = posMou
		switchRolSelSetMouState = on
	)

	on rolSelSetTools lbuttonup posMou do
	(
		switchRolSelSetMouState = off
	)

	on rolSelSetTools rbuttondown pos do 
	(
		popupMenu RCmenuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y]
	)

	on rolSelSetTools mouseMove pos do
	(
		if switchRolSelSetMouState == on then
		(
			SetDialogPos rolSelSetTools (mouse.screenpos - posRolSelSetMouMove)			
		)
	)

	on rolSelSetTools open do
	(
		stLoadConfig.fnLoadConfigSelSetTools ()  ---------------脚本位置等赋值
		stSetConfig.fnSetConfigSelSetTools ()  ----------------保存位置信息到ini文件
		fnUpdateMoreToolsState ()
		fnUpdateSelSetList()
		fnUpdateSelSetList()
	)

	on rolSelSetTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosSelSetTools   = (GetDialogPos rolSelSetTools)
        stSetConfig.fnSetConfigSelSetTools ()
	)

	on btnSaveXml pressed do
	(
		local save_path = getSaveFileName caption:"Save XML File " filename:".xml" types:"XML(*.xml)|*.xml|"
		if save_path != undefined then
		(
			fnSaveSelSetAll save_path
		)
	)	

	on btnLoadXml pressed do
	(
		local pathLoad = getOpenFileName caption:"Load XML File" types:"XML(*.xml)|*.xml|"
		if pathLoad != undefined then
		(
			local dataLoad = fnLoadSelXml pathLoad
			
			if dataLoad != undefined then
			(
				print (dataLoad as string)
				arrSelSetNameLoaded = dataLoad[1]
				arrSelSetObjLoaded = dataLoad[2]
				
				createdialog rolLoadSelSet pos:[SST_RF.pos.x+SST_RF.size.x, SST_RF.pos.y ] width:200 height:370 parent:rolSelSetTools.hwnd
				rolLoadSelSet.mlbLoadSelSet.items = dataLoad[1]
			)
		)
	)

	on btnUpdateList pressed do
	(
		fnUpdateSelSetList()
	)

	on lbxSelSet selected sel do
	(
		if lbxSelSet.selected != undefined then
		(
			local selSet = selectionSets[lbxSelSet.selected]
			try(select selSet;lbxSelSetNode.items = for i in selSet collect i.name)catch()
			lbxSelSetNode.selection = 0
		)	
	)

	on lbxSelSetNode selected sel do 
	(
		if lbxSelSetNode.selected != undefined then
		(
			local strSelSetNode = lbxSelSetNode.selected
			if getNodeByName strSelSetNode != undefined  then
			(
				select (getNodeByName strSelSetNode)
			)
		)
	)

	on chkMoreTools changed state do 
	(
		fnUpdateMoreToolsState ()
	)

)
if (iniPosSelSetTools != 0) then 
(Createdialog rolSelSetTools 315 260 fgcolor:myFgColor pos:iniPosSelSetTools style:#())
else (Createdialog rolSelSetTools 315 260 fgcolor:myFgColor style:#())