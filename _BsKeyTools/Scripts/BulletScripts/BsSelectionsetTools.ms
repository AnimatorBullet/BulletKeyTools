--encoding:UTF-8//////////////////////////////////////////////////////////////////////////////
--
--Script for 3dsMax (MaxScript)
--***SelectionSet_Tools***
--updated 2020/03/03
--Copyright (c) 2020 @Takayuki Sato All rights reserved.
--
--////////////////////////////////////////////////////////////////////////////////////////////

try (closerolloutfloater SST_RF) catch() --AVOID DOUBLE WINDOW. YOU MUST MAKE "SST_RF" ORIGINAL NAME !!

-- macroScript SelectionSet_Tools category:"SP_Tools"
(
--Check the expiration day ===============================================================================================	
	(
		local fromLimit = #( 0000, 00, 00 ) --START DAY
		local toLimit = #( 9999, 99, 99) --END DAY
		local FLG_expiration = false
		local c_time = getLocalTime() --Get Windows time

		currentDay = c_time[1] * 10000 + c_time[2] * 100 + c_time[4]
		fromDay = fromLimit[1] * 10000 + fromLimit[2] * 100 + fromLimit[3]
		toDay = toLimit[1] * 10000 + toLimit[2] * 100 + toLimit[3]

		if currentDay < fromDay do (
			MessageBox("This Script has been expired.有効期限が切れています。")
			return()
		)
		if currentDay > toDay do (
			MessageBox("This Script has been expired.有効期限が切れています。")
			return()
		)
	)
--Check the expiration day END ==============================================================================================

global SST_RO
global SST_load_RO
global RF_width = 230 --Define RolloutFloater Width
global RF_height = 370 --Define RolloutFloater Height
global SST_RF = newrolloutfloater "SelectionSet Tools" RF_width RF_height 
global XmlDoc = dotNetObject "System.xml.xmlDocument"
global SST_xml_root_name = "SelectionSet_Tools"
	
global loaded_selset_name_list
global loaded_selset_obj_list
	
--////////////////////////////////////////////////////////////////////////////////////
--FUNCTION Save Selection Sets ALL////////////////////////////////////////////////
fn save_selset_all xml_path = (
/*
引数
xml_path：書き出すXMLのパス
*/
	local root_elem = XmlDoc.createElement SST_xml_root_name --ルートのXML要素を作成
	XmlDoc.appendChild root_elem

	for s in selectionSets do(
		--print s.name --選択セットの名前
		local set_elem = XmlDoc.createElement "SelectionSet" --各選択セットのXML要素を作成
		set_elem.SetAttribute "SetName" s.name  --アトリビュートに選択セット名を格納
		root_elem.appendChild set_elem

		--print s.count --選択セットの含まれるオブジェクトの数
		for o in s do( --各選択セット内のオブジェクト名のXML要素を作成
			--print o.name
			local obj_elem = XmlDoc.createElement "ObjectName" --各オブジェクトのXML要素を作成
			--obj_elem.SetAttribute "ObjName" o.name
			obj_elem.InnerText = o.name --オブジェクト名を各XML要素のテキストに格納
			set_elem.appendChild obj_elem
		)--end for o
	)--end for s

	XmlDoc.save xml_path --xmlを書き出し

)

--////////////////////////////////////////////////////////////////////////////////////
--FUNCTION Load Selection Sets ALL////////////////////////////////////////////////
fn load_selset_xml xml_path = (
/*
引数
xml_path：読み込むXMLのパス
返り値
result：配列#（選択セット名のリスト、選択セットに含まれるオブジェクトのリストの配列）
*/
	xmlDoc.Load xml_path
	local root_elem = xmlDoc.DocumentElement
	
	--print root_elem.name
	if root_elem.name != SST_xml_root_name then( --このツールで作成されたXMLかチェック
		messagebox "これはSelectionSet_Toolsで作成されたXMLファイルではありません。\t"
		return undefined
	)--end if
	
	local selset_nodes = root_elem.ChildNodes
	--print selset_nodes.count

	--選択セット名と含まれるオブジェクト名を取得するための変数
	local selset_name_list = #() --選択セット名のリスト
	local selset_obj_list = #() --選択セットに含まれているオブジェクトのリスト（2次元配列）

	for i = 0 to selset_nodes.count - 1 do(

		local selset_elem = selset_nodes.Item[i] --選択セットの要素
		--print "Loaded Selection Set Name is "
		--print (selset_elem.Attributes.GetNamedItem "SetName").value
		append selset_name_list (selset_elem.Attributes.GetNamedItem "SetName").value --配列に選択セット名をアトリビュートから取得
		
		local obj_nodes = selset_elem.ChildNodes --選択セットに含まれる全てのオブジェクトの要素
		--print ("OBJ count :" + obj_nodes.count as string)
		
		selset_obj_list[i+1] = #() --2次元配列を用意
		for j = 0 to obj_nodes.count - 1 do( --選択セットに含まれる全てのオブジェクトのXML要素を巡回
			local obj_elem = obj_nodes.Item[j] --選択セットのオブジェクトのXML要素
			append selset_obj_list[i+1] obj_elem.InnerText --オブジェクト名をXML要素から取得
		)--end for j
	)--end for i
	
	--結果を配列に入れて返す
	local result = #(selset_name_list, selset_obj_list)
	return result
)

--////////////////////////////////////////////////////////////////////////////////////
--FUNCTION Create Selection Sets ////////////////////////////////////////////////
fn create_selset selset_name_list selset_obj_list n = (
/*
引数
selset_name_list：選択セット名のリスト
selset_obj_list：選択セットに含まれるオブジェクトの配列のリスト
n：何番目の選択セットを作成するか
*/
	--XML内のオブジェクトがシーン内にあるかチェックする処理
	local re_selset_obj_list = #() --セット内のオブジェクトで、シーン内に存在するものだけを集めるリスト
	for o in selset_obj_list[n] do(
		if getNodeByName o != undefined  then(--XMLのセット内に含まれるオブジェクト名がシーンにもあれば、リストに追加
			append re_selset_obj_list o
		)--end if
	)--end for
	
	--選択セットを作成する処理
	if re_selset_obj_list.count != 0 then(--オブジェクトの配列に含まれるオブジェクト数が0でなければ
		local txt = "selectionSets[\""
		txt += selset_name_list[n] + "\"] = #("
		for o in re_selset_obj_list do(
			txt += "$'" + o +"', "
		)--end for o
		txt = substring txt  1 (txt.count - 2) --最後の2文字を削除した文字列を取得
		txt+= ")"

		--print txt
		execute txt
	)else(
		messagebox( "Selection Set \"" + selset_name_list[n] + "\" is Empty.\n選択セット\"" + selset_name_list[n] + "\"に含まれるオブジェクトが、シーン内になかったため読み込みませんでした。\t")
	)
	--end if 
)

--////////////////////////////////////////////////////////////////////////////////////
--FUNCTION update selection set in list box////////////////////////////////////////////////
fn update_listbox = (
	local n_list = #()
	for s in selectionSets do append n_list s.name
	sort n_list --アルファベット順に並び替え
	SST_RO.LB_selset.items = n_list

)

--////////////////////////////////////////////////////////////////////////////////////
--ROLLOUT Load Selection Set/////////////////////////////////////////////////////
rollout SST_load_RO "Load_SelectionSet"
(
	multilistbox MLB_load_selset "SelectionSet List" height:22
	button BTN_load "Load selected" width:80 height: 25 across:2
	button BTN_load_all "Load ALL" width:80 height:25
		
	on BTN_load pressed do(
		for n in MLB_load_selset.selection do(
			create_selset loaded_selset_name_list loaded_selset_obj_list n
		)--end for
		update_listbox()
	)--end on
	
	on BTN_load_all pressed do(
		for n = 1 to MLB_load_selset.items.count do(
			create_selset loaded_selset_name_list loaded_selset_obj_list n
		)--end for
		update_listbox()
	)--end on
)


--////////////////////////////////////////////////////////////////////////////////////
--ROLLOUT /////////////////////////////////////////////////////
rollout SST_RO "SelectionSet Tools"
(
	button BTN_save_xml "Save SelSets" width:90 height:20 across:2
	button BTN_load_xml "Load SelSets" width:90 height:20
	
	button BTN_update "update list" width:190 height:18 offset:[0,5]
	listbox LB_selset "Selection Set" height:20
	
	on SST_RO open do(
		update_listbox()
	)--end on
	
	on BTN_save_xml pressed do(
		local save_path = getSaveFileName caption:"Save XML File " filename:".xml" types:"XML(*.xml)|*.xml|"
		if save_path != undefined then(
			save_selset_all save_path
		)--end if
	)--end on	

	on BTN_load_xml pressed do(
		local load_path = getOpenFileName caption:"Load XML File" types:"XML(*.xml)|*.xml|"
		if load_path != undefined then(
			local load_data = load_selset_xml load_path
			
			if load_data != undefined then( --load_dataがundefinedでなければ読み込み
				print (load_data as string)
				--create_selset load_data[1] load_data[2] 2
				--データをグローバルに渡す
				loaded_selset_name_list = load_data[1]
				loaded_selset_obj_list = load_data[2]
				
				createdialog SST_load_RO pos:[SST_RF.pos.x+SST_RF.size.x, SST_RF.pos.y ] width:200 height:370 parent:SST_RO.hwnd
				SST_load_RO.MLB_load_selset.items = load_data[1]
				
			)--end if
		)--end if
	)--end on
	
	on BTN_update pressed do(
		update_listbox()
	)--end on
	
	on LB_selset selected sel do(
		if LB_selset.selected != undefined then(
			local set_a = selectionSets[LB_selset.selected]
			try(select set_a)catch()
		)--end if	
	)--end on
)

addRollout SST_RO SST_RF rolledUp:false
--createdialog SST_RO RF_width RF_height menu:SST_menu

)-- end of script and end of macro definition