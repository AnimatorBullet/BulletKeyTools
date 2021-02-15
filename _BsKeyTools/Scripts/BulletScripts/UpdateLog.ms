try(destroydialog rolUpdateLog)catch()

	
rollout rolUpdateLog "更新记录" 
(
	local strUpdateLog = "
✅ [修复]修复2018及以上中文版的报错（官方API有改动导致，加了版本判断）

✅ [优化]取消主面板作者名处的点击跳转网页，移至设置菜单的\"关于我\"当中，防止手误弹出网页

✅ [优化]界面按钮名字和文字间距，稍微加大界面，尽量简洁美观

✅ [优化]优化隐藏骨骼，当骨骼所在层是隐藏时，显示骨骼不会将隐藏层内的物体显示

✅ [优化]转移隐藏显示所有骨骼功能（加独显模型功能按钮），改成隐显bone和隐显biped，并做了优化

✅ [优化]取消时光机工具打开文件时的静默模式，防止出现单位问题，虽然理论上不会有问题

🔲 [特性]新增动画相关系统自带命令的按钮集方便使用，以菜单形式打开，点击不同分类弹出面板

🔲 [特性]参考库增加动图支持，可以抽出gif序列帧，播放时根据滑条自动切换相应帧的图

🔲 [特性]Transform归零，重置模型，蒙皮缩放，批量导出，Pose库，暴力粘贴等待添加或优化

🔲 [特性]简易刀光破碎等辅助动画特效

🔲 [特性]增加右边小工具自定义位置功能，方便按喜好和使用频率排列

✅ [特性]增加切换剪影显示

✅ [特性]增加辅助构图工具(修改版)

✅ [特性]增加从视角创建相机(Max自带方法)

✅ [特性]增加一键创建和删除末端骨骼功能

✅ [特性]增加运动重影工具(修改自San_oOo)

✅ [特性]增加一键创建碎块的骨骼(修改自San_oOo)

✅ [特性]增加动画分段工具(修改自San_oOo)"
	
	-- label lblUpdateLog strUpdateLog pos:[10,10] width:999999 height:999999
	edittext edtUpdateLog "BsKeyTools v0.9.5 更新记录" pos:[5,5] width:590 height:490 labelOnTop:true text:strUpdateLog readOnly:true
	-- label lblLink "✨ 2019.9 [ miHoYo_Bullet.S ] ✨" pos:[410,5] width:200 height:15
	HyperLink lnkLink "✨ 2019.9 [ miHoYo_Bullet.S ] ✨" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	pos:[420,5] address:"https://space.bilibili.com/2031113"
)
createDialog rolUpdateLog width:600 height:520