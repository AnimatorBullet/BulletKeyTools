try(destroydialog rolloutFileOpen)catch()


Global posMouMove  = [0,0]
Global switchMouState = false
Global iniPosRolFileOpen
Global arrFolders = #()
Global arrFoldersName = #()
Global arrFiles = #()
Global arrFilesName = #()
Global dirLiked = ""
Global dirOpened = ""
Global numFiles = 0

rollout rolloutFileOpen "" width:300 height:345
(
	groupbox grpMain "快速打开_v0.1 ---- 空白拖动,中键关闭 ---- by:Bullet.S" width:290 height:340 pos:[5,0]
	
	editText edtBrowseFolder "" text:" ( 打开目录 )" labelOnTop:true align:#right \
	height:20 width:170 pos:[85,20] readOnly:true enabled:false
	button btnOpenAddress "..." align:#right \
	height:20 width:30 pos:[260,20] 
	button btnRemoveFolder "▬" align:#left border:false \
	height:20 width:20 pos:[10,20] tooltip:"左：删除选中目录\r\n右：清空目录列表（可撤销）"
	button btnAddFolder "✚" align:#left border:false \
	height:20 width:20 pos:[35,20] tooltip:"左：新增常用目录\r\n右：恢复上次删除目录列表"
	button btnAddCurrentFolder "★" align:#left border:false \
	height:20 width:20 pos:[60,20] tooltip:"收藏当前目录"
	button btnLikedFolder " >常用目录<" border:false \
	height:20 width:70 pos:[10,40]
	listBox ltbLikedFolder "" align:#left \
	height:11 width:70 pos:[10,60] items:#("aaaaaaaaaaaa","bbbbbbbbbb","啊啊啊啊啊啊啊啊啊啊")
	listBox ltbFilesList "" align:#right \
	height:20 width:205 pos:[85,45]
	button btnFilterPrefix "✚ 过滤前缀" border:false \
	height:20 width:70 pos:[10,207]
	listBox ltbFilterPrefix "" align:#left \
	height:6 width:70 pos:[10,227] items:#("All","bbbbbbbbbb","啊啊啊啊啊啊啊啊啊啊")
	radioButtons rdoFileType "" columns:4 \
	pos:[95,319] labels:#(".max",".fbx",".bip",".xaf")
	button btnCountTips "" border:false enabled:false \
	height:20 width:70 pos:[10,315]
	

	---历史打开文件夹,支持fbx
	------------------------------------------------- ↑ UI -------------------------------------
    fn fnRefreshList strFilesDir =
    (
		arrFolders = #()
		arrFiles = #()
		arrFoldersName = #()
		arrFilesName = #()
        arrFolders = GetDirectories (strFilesDir + "/*");sort arrFolders
		arrFiles = getFiles (strFilesDir + "\\" + "*.max"); sort arrFiles
		
        if arrFolders[1] != undefined then
		(
			for c in arrFolders do  --获取文件夹名字,后面切换脚本类别和列表会用到
			(
				append arrFoldersName ("○ " + (getFilenameFile (substring c 1 (c.count-1))))
			)
		)
		if arrFiles[1] != undefined then
		(
			for c in arrFiles do  --获取文件夹名字,后面切换脚本类别和列表会用到
			(
				append arrFilesName ("● " + (getFilenameFile c) + ".max")
			)
		)
		rolloutFileOpen.ltbFilesList.items = arrFoldersName + arrFilesName
		numFiles = arrFiles.count
    )
	
	fn fnRefreshAddress =
	(
		if maxFilePath != "" then 
		(
			edtBrowseFolder.text = maxFilePath
		)
		else edtBrowseFolder.text = " ( 打开目录 )"
	)
	----------------------------------------------------------------------------------------------------
	
	on rolloutFileOpen open do 
	(
		fnRefreshList maxFilePath
		fnRefreshAddress ()
		btnCountTips.text = "文件：" + numFiles as string
	)
	
	on rolloutFileOpen mbuttondown pos do 
	(
		try (destroydialog rolloutFileOpen) catch ()
	)

	on rolloutFileOpen lbuttondown posMou do
	(
		posMouMove = posMou
		switchMouState = on
	)

	on rolloutFileOpen lbuttonup posMou do
	(
		switchMouState = off
	)

	on rolloutFileOpen mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolloutFileOpen (mouse.screenpos - posMouMove)			
		)
	)
	
	on btnOpenAddress pressed do 
    (
        dirOpened = getSavePath caption:"请选择Max文件路径:" initialDir:(maxFilePath)
        if (dirOpened != undefined) then
        (
            edtBrowseFolder.text = dirOpened
            fnRefreshList dirOpened
        )
    )
)
CreateDialog rolloutFileOpen fgcolor:(color 255 20 100) style:#()