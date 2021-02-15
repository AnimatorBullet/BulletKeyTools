global myFgColor
global myClickColor
global myCheckedColor

curColorThemeFile = colorMan.getFileName()
if (curColorThemeFile != undefined) then
(
	if (matchpattern curColorThemeFile pattern:"*light*") then
	(
		myFgColor    = (color 65 105 225)
		myClickColor = (color 0 139 139)
		myCheckedColor = (color 238 204 85)
	)
	else
	(
		myFgColor    = (color 219 209 72)
		myClickColor = (color 0 255 127)
		myCheckedColor = (color 95 138 193)
	)
)
else
(
	myFgColor    = (color 219 209 72)
	myClickColor = (color 0 255 127)
	myCheckedColor = (color 95 138 193)
)
----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms