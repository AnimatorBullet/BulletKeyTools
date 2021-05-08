/*
 * @Description: 选择集工具 参考自:@Takayuki Sato
 * @Author: Bullet.S
 * @Date: 2021-05-07 12:33:36
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-05-09 04:32:01
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

fn fnUpdateSelSetList = 
(
	local arrNodesList = #()
	for s in selectionSets do
	(
		append arrNodesList s.name
	)
	qsort arrNodesList fnPseudoNaturalSort
	rolSelSetTools.lbxSelSet.items = arrNodesList
	rolSelSetTools.lbxSelSet.selection = 0
	rolSelSetTools.mlbSelSetNode.items = #()
	rolSelSetTools.lblCount.text = "共 " + selectionsets.count as string + " 个选择集"
)

rollout rolLoadSelSet "加载选择集"
(
	multilistbox mlbLoadSelSet "选择集列表" height:22
	button btnLoadSel "加载选中" width:80 height: 25 across:2
	button btnLoadAll "加载所有" width:80 height:25
		
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
	listbox lbxSelSet " " width:180 height:16 pos:[5,5]
	label lblCount "" width:180 height:16 pos:[5,5]
	
	button btnCloseRol "关闭" width:40 height:20 pos:[5,235]
	button btnUpdateList "更新列表" width:90 height:20 pos:[45,235]
	checkbutton chkMoreTools "更多" width:50 height:20 pos:[135,235]

	button btnCreateSelSet "" width:30 height:20 pos:[195,0] enabled:false tooltip:"创建选择集"
	button btnDeleteSelSet "" width:30 height:20 pos:[225,0] enabled:false tooltip:"删除选择集"
	button btnAddToSelSet "" width:30 height:20 pos:[255,0] enabled:false tooltip:"添加所选物体到选中的选择集"
	button btnRemoveFromSelSet "" width:30 height:20 pos:[285,0] enabled:false tooltip:"从选中的选择集中移除所选物体"
	button btnHighlightSelObj "" width:30 height:20 pos:[315,0] enabled:false tooltip:"高亮选中物体及其所在选择集"
	MultiListBox mlbSelSetNode "" width:165 height:16 pos:[190,20] enabled:false
	button btnSaveXml "保存" width:60 height:20 pos:[190,235] enabled:false
	button btnLoadXml "加载" width:60 height:20 pos:[250,235] enabled:false
	button btnHelp "帮助" width:45 height:20 pos:[310,235] enabled:false

	fn fnUpdateMoreToolsState =
	(
		if chkMoreTools.state then rolSelSetTools.width = 360 else rolSelSetTools.width = 190
	)

	fn fnUpdateSelSetNodeList arrTemp =
	(
		local arrSelSetNodesName = (for i in arrTemp collect i.name)
		qsort arrSelSetNodesName fnPseudoNaturalSort
		mlbSelSetNode.items = arrSelSetNodesName
		mlbSelSetNode.selection = 0
		lblCount.text = "当中共有 " + selectionsets[lbxSelSet.selected].count as string + " 个物体"
	)
	fn fnAddRemoveNode action =
	(
		local arrCurSelSet = selectionsets[lbxSelSet.selected]
		if lbxSelSet.selected != undefined then 
		(
			local arrSelection = getcurrentselection()
			if arrSelection != undefined then 
			(
				case of
				(
					(action == "Add"):(arrCurSelSet = join (join #() arrCurSelSet) arrSelection)
					(action == "Del"):
					(
						for o in arrSelection do 
						(
							arrCurSelSet = for n in arrCurSelSet where n != o collect n
						)
					)
				)
				fnUpdateSelSetNodeList selectionsets[lbxSelSet.selected]
			)
		)
		return arrCurSelSet
	)

	fn fnRefreshBtnEnabled =
	(
		btnSaveXml.enabled          = chkMoreTools.state
		btnLoadXml.enabled          = chkMoreTools.state
		mlbSelSetNode.enabled       = chkMoreTools.state
		btnHelp.enabled             = chkMoreTools.state
		btnCreateSelSet.enabled     = chkMoreTools.state
		btnDeleteSelSet.enabled     = chkMoreTools.state
		btnAddToSelSet.enabled      = chkMoreTools.state
		btnRemoveFromSelSet.enabled = chkMoreTools.state
		btnHighlightSelObj.enabled  = chkMoreTools.state
	)

	on btnCloseRol pressed do (try (destroydialog rolSelSetTools) catch ())

	on btnHelp pressed do 
	(shellLaunch "https://www.notion.so/bullet4869/5e0e30442ad348a09d7aa45ea6f8d53a" "")

	on rolSelSetTools mbuttondown pos do (try (destroydialog rolSelSetTools) catch ())

	on rolSelSetTools lbuttondown posMou do
	(
		posRolSelSetMouMove = posMou
		switchRolSelSetMouState = on
	)

	on rolSelSetTools lbuttonup posMou do switchRolSelSetMouState = off

	on rolSelSetTools rbuttondown pos do 
		popupMenu RCmenuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y]

	on rolSelSetTools mouseMove pos do if switchRolSelSetMouState do
		SetDialogPos rolSelSetTools (mouse.screenpos - posRolSelSetMouMove)

	on rolSelSetTools open do
	(
		stLoadConfig.fnLoadConfigSelSetTools()  ---------------脚本位置等赋值
		stSetConfig.fnSetConfigSelSetTools()  ----------------保存位置信息到ini文件
		btnCreateSelSet.images     = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,1,1,2,2,false,true)
		btnDeleteSelSet.images     = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		btnAddToSelSet.images      = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		btnRemoveFromSelSet.images = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,7,7,8,8,false,true)
		btnHighlightSelObj.images  = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,12,12,13,13,false,true)
		fnUpdateMoreToolsState()
		fnRefreshBtnEnabled()
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
				arrSelSetObjLoaded  = dataLoad[2]
				iniPosSelSetTools   = (GetDialogPos rolSelSetTools)
				createdialog rolLoadSelSet pos:[iniPosSelSetTools.x+rolSelSetTools.width, iniPosSelSetTools.y ] width:200 height:350 parent:rolSelSetTools.hwnd
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
			try(select selSet;fnUpdateSelSetNodeList selSet)catch()
		)	
	)

	on btnDeleteSelSet pressed do
	(
		if lbxSelSet.selected != undefined then 
		(
			deleteItem selectionSets lbxSelSet.selected
			fnUpdateSelSetList()
		)
	)

	on btnAddToSelSet pressed do
	(
		selectionsets[lbxSelSet.selected] = (fnAddRemoveNode "Add")
		fnUpdateSelSetNodeList selectionsets[lbxSelSet.selected]
	)

	on btnRemoveFromSelSet pressed do 
	(
		selectionsets[lbxSelSet.selected] = (fnAddRemoveNode "Del")
		fnUpdateSelSetNodeList selectionsets[lbxSelSet.selected]
	)

	on btnHighlightSelObj pressed do 
	(
		local arrCurSelection = getCurrentSelection()
		local arrCurSelSet = (join #() selectionsets[lbxSelSet.selected])
		local arrSelIndex = #()
		for i in arrCurSelection do 
		(
			local indexTemp = findItem arrCurSelSet i
			if indexTemp != 0 then append arrSelIndex indexTemp
		)
		mlbSelSetNode.selection = arrSelIndex
		lblCount.text = "选中高亮 " + arrSelIndex.count as string + " 个物体"
	)

	on mlbSelSetNode selectionEnd do 
	(
		if mlbSelSetNode.selection != undefined then
		(
			local strSelSetNode = for i in mlbSelSetNode.selection collect mlbSelSetNode.items[i]
			clearselection()
			for o in strSelSetNode where (getNodeByName o != undefined) do selectmore (getNodeByName o)
		)
	)

	on chkMoreTools changed state do 
	(
		fnUpdateMoreToolsState ()
		fnRefreshBtnEnabled()
	)

)
if (iniPosSelSetTools != 0) then 
(Createdialog rolSelSetTools 360 260 fgcolor:myFgColor pos:iniPosSelSetTools style:#())
else (Createdialog rolSelSetTools 360 260 fgcolor:myFgColor style:#())