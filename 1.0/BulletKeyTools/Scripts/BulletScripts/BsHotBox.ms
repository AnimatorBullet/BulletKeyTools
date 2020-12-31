/*
 * @Description: 提取快捷键功能优化自：https://forums.cgsociety.org/t/assign-action-to-keyboard-shortcut-through-script/1395733/47
 * @Author: Bullet.S
 * @Date: 2019-12-24 12:39:55
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-31 15:29:36
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolHotBox1)catch()
try(destroydialog rolHotBox2)catch()
try(destroydialog rolHotBox3)catch()
try(destroydialog rolHotBox4)catch()

global switchRolHotBox = off
Global posMouse = mouse.screenpos
Global arrHotBox = #(rolHotBox1,rolHotBox2,rolHotBox3,rolHotBox4)

global strTools1 = "创建参考图"
global pathTools1 = ((getDir #Scripts)+ "\\BulletScripts\\" + "BsReferenceTools.ms")
global strTools2 = "2"
global pathTools2 = ((getDir #Scripts)+ "\\BulletScripts\\" + "BulletKeyTools.ms")
global strTools3 = "3"
global pathTools3 = ""
global strTools4 = "4"
global pathTools4 = ""
global posHot1   = [-100,-40]

fn fnCloseHotBox =
(
	try(destroydialog rolHotBox1)catch()
	try(destroydialog rolHotBox2)catch()
	try(destroydialog rolHotBox3)catch()
	try(destroydialog rolHotBox4)catch()
)

str = ""
str += "rollout rolHotBoxConfig \"\" height:30 width:30"
str += "\r\n(\r\n"
str += "	button btnConfig \"SetKey\" pos:[0,0] height:30 width:30 border:false"
str += "\r\n)\r\n"

for n = 1 to arrHotBox.count do 
(
	str += "rollout rolHotBox" + (n as string) + " \"\" height:30 width:70"
	str += "\r\n(\r\n"
	str += "	button btnHot" + (n as string) + " strTools" + (n as string) + \
	" pos:[0,0] height:30 width:70 border:false\r\n"
	str += "	on btnHot" + (n as string) + " pressed do"
	str += "	\r\n(if doesfileexist pathTools" + (n as string) + " then \
	(fileIn pathTools" + (n as string) + "))"
	str += "\r\n)\r\n"
)

str += "createdialog rolHotBox1 pos:(" + (posHot1 as string) + \
" + mouse.screenpos) style:#()\r\n"
str += "createdialog rolHotBox2 pos:(" + ((posHot1 + [0,60]) as string) + \
" + mouse.screenpos) style:#()\r\n"
str += "createdialog rolHotBox3 pos:(" + ((posHot1 + [130,0]) as string) + \
" + mouse.screenpos) style:#()\r\n"
str += "createdialog rolHotBox4 pos:(" + ((posHot1 + [130,60]) as string) + \
" + mouse.screenpos) style:#()\r\n"

execute str
