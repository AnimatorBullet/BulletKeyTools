/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-30 21:46:15
 * @Email: animator.bullet@foxmail.com
 */

global dotDrawingImage = dotNetclass "System.Drawing.Image"
global dotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"

strFilePath = @"C:\Users\chao.liu\Desktop\0.jpg"

fn fnCreateRefPlane filePath =
(
    tempRefImage = dotDrawingImage.fromfile filePath 
    planeRef = plane width:tempRefImage.width length:tempRefImage.height lengthsegs:1 widthsegs:1 
    planeRef.rotation.x_rotation = 90
    bitmapRef = Bitmaptexture fileName:filePath
    planeRef.material = standard diffuseMap:(bitmapRef) showInViewport:true
    planeRef.material.name = "matReferencePic"
)

-- fnCreateRefPlane strFilePath

tempImage = dotNetClipboard.GetImage()
if tempImage != undefined do tempImage.save "C:\Users\chao.liu\Desktop\0.jpg"


if dotNetClipboard.ContainsFileDropList() do 
(
    fileList = dotNetClipboard.GetFileDropList()
    for i = 0 to (fileList.count - 1) do
    (
        fnCreateRefPlane (fileList.item i)
    )
)

if (queryBox "是否切换高分辨率贴图显示？      \r\n( 会改变显示贴图精度 )\r\n        " \
		title:"切换高分辨率贴图显示" beep:false) then
(
    
)