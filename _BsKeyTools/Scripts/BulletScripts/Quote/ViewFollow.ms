--
-- 
-- mimicking biped's inplace mode. applies to current selection.
-- v1
-- tested with max 2012
-- huijunpark@gmail.com
--

global vTm = inverse (getViewTM())
global offsetPos = [0,0,0]
global zVal = 0
global fixZ = false

fn setView =
(
	if selection.count > 0 do
	(
		vTm.row4 = selection.center + offsetPos
		if fixZ do vTm.row4.z = zVal
		
		with redraw off viewport.settm (inverse vTm)
	)
)

fn storeView =
(
	if selection.count > 0 do
	(
		crrVTm = inverse (getViewTM())
		
		if vTm.pos != crrVTm.pos or vTm.rotation != crrVTm.rotation do
		(
			vTm = crrVTm
			
			offsetPos = vTm.row4 - selection.center
			zVal = vTm.row4.z
		)
	)
)

fn unregisterCallbacks =
(
	unRegisterTimeCallback setView
	unRegisterRedrawViewsCallback storeView
)

storeView()

try destroydialog roll_viewFollow catch()

rollout roll_viewFollow "View Follow" width:160
(
	checkbox chk_fixZ "Fix Z" align:#left checked:false across:2 offset:[0,4]
	checkbutton ckb_go "ON" width:85 height:26 align:#right
	
	on chk_fixZ changed arg do
	(
		fixZ = chk_fixZ.state
	)
	
	on ckb_go changed arg do
	(
		if arg then
		(
			registerTimeCallback setView
			registerRedrawViewsCallback storeView
			completeRedraw()
			ckb_go.text = "OFF"
		)
		else
		(
			unregisterCallbacks()
			ckb_go.text = "ON"
		)
	)
	
	on roll_viewFollow close do
	(
		unregisterCallbacks()
	)
)

createdialog roll_viewFollow style:#(#style_sysmenu, #style_toolwindow)
