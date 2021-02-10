If (viewport.Gettype() == #view_persp_user) and (not theHold.Holding()) then 
(CreateCameraFromView(FreeCamera))
else (messagebox "请按“P”在自由视角创建，之后可能优化为任意视角~        \r\n" beep:false)