/*
 * @Description: 选择集工具 修改自:@Takayuki Sato
 * @Author: Bullet.S
 * @Date: 2021-05-07 12:33:36
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-05-07 13:48:14
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolSelSetTools)catch()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)

global rolSelSetTools
global rolLoadSelSet
global dotNetXmlDoc = dotNetObject "System.xml.xmlDocument"
global strXmlRootName = "SelectionSet_Tools"
	
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
		messagebox( "Selection Set \"" + arrSelSetName[n] + "\" 是空的。\n选择集\"" + arrSelSetName[n] + "\"未被读取...                    \t")
	)
)
fn fnUpdateSelSetList = 
(
	local arrNodesList = #()
	for s in selectionSets do append arrNodesList s.name
	sort arrNodesList
	rolSelSetTools.LB_selset.items = arrNodesList
)

rollout rolLoadSelSet "Load_SelectionSet"
(
	multilistbox mlbLoadSelSet "SelectionSet List" height:22
	button btnLoadSel "Load selected" width:80 height: 25 across:2
	button btnLoadAll "Load ALL" width:80 height:25
		
	on btnLoadSel pressed do(
		for n in mlbLoadSelSet.selection do(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
	)
	
	on btnLoadAll pressed do(
		for n = 1 to mlbLoadSelSet.items.count do(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
	)
)

rollout rolSelSetTools "[选择集工具]BsSelSetTools v1.0"
(
	button BTN_save_xml "Save SelSets" width:90 height:20 across:2
	button BTN_load_xml "Load SelSets" width:90 height:20
	
	button BTN_update "update list" width:190 height:18 offset:[0,5]
	listbox LB_selset "Selection Set" height:20

	on rolSelSetTools open do
	(
		fnUpdateSelSetList()
	)

	on BTN_save_xml pressed do
	(
		local save_path = getSaveFileName caption:"Save XML File " filename:".xml" types:"XML(*.xml)|*.xml|"
		if save_path != undefined then
		(
			fnSaveSelSetAll save_path
		)
	)	

	on BTN_load_xml pressed do
	(
		local load_path = getOpenFileName caption:"Load XML File" types:"XML(*.xml)|*.xml|"
		if load_path != undefined then
		(
			local load_data = fnLoadSelXml load_path
			
			if load_data != undefined then
			(
				print (load_data as string)
				arrSelSetNameLoaded = load_data[1]
				arrSelSetObjLoaded = load_data[2]
				
				createdialog rolLoadSelSet pos:[SST_RF.pos.x+SST_RF.size.x, SST_RF.pos.y ] width:200 height:370 parent:rolSelSetTools.hwnd
				rolLoadSelSet.mlbLoadSelSet.items = load_data[1]
				
			)
		)
	)

	on BTN_update pressed do
	(
		fnUpdateSelSetList()
	)

	on LB_selset selected sel do
	(
		if LB_selset.selected != undefined then
		(
			local set_a = selectionSets[LB_selset.selected]
			try(select set_a)catch()
		)	
	)
)
Createdialog rolSelSetTools 250 400 fgcolor:myFgColor