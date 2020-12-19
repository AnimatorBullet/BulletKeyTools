/*
 * @Description: 提取快捷键功能优化自：https://forums.cgsociety.org/t/assign-action-to-keyboard-shortcut-through-script/1395733/47
 * @Author: Bullet.S
 * @Date: 2019-12-24 12:39:55
 * @LastEditors  : Bullet.S
 * @LastEditTime : 2019-12-27 20:24:39
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolHotBox1)catch()
try(destroydialog rolHotBox2)catch()

Global posMouse = mouse.screenpos
Global arrHotBox = #(rolHotBox1,rolHotBox2)

rollout rolHotBox1 "" height:30 width:70
(
	button btnHot01 "1" pos:[0,0] height:30 width:70
)

rollout rolHotBox2 "" height:30 width:70
(
	button btnHot02 "2" pos:[0,0] height:30 width:70
)
createdialog rolHotBox1 pos:([20,20] + mouse.screenpos) style:#()
createdialog rolHotBox2 pos:([-100,20] + mouse.screenpos) style:#()