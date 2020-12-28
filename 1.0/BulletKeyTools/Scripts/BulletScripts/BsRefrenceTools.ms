/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2020-12-29 01:14:12
 * @Email: animator.bullet@foxmail.com
 */

DotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"
tempImage = DotNetClipboard.GetImage()
if tempImage != undefined do tempImage.save "C:\Users\Administrator\Desktop\0.png"


if DotNetClipboard.ContainsFileDropList() do 
(
    fileList = DotNetClipboard.GetFileDropList()
    for i = 0 to (fileList.count - 1) do
    (
        print (fileList.item i)
    )
)