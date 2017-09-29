#http://www.cnblogs.com/tibit/p/6387199.html 参考notepad++ 替换中使用正则
#notepad++ 中替换行首的逗号为句号
([0-9])[，]
(\1). 

#查找中文
[\u4e00-\u9fa5]
[^x00-xff]

dadawdad匹配中文和wadada英文字符
([A-Za-z])([^x00-xff])
(\1)  (\2)


#sublime 配置 Terminal cmder
在 packagecontrol.io 可以找到 Terminal 
在 cmder.net 下载 cmder
复制 Terminal.sublime-settings 文件到 C:\Users\WXG\AppData\Roaming\Sublime Text 3\Packages\User 目录下. 作如下修改:
{
    "terminal": "C:/wxg/tools/cmder_mini/Cmder.exe",
    "parameters": ["/START", "%CWD%"]
}
然后就可以在sublime下调用cmder了.
如果加上 "parameters": ["/START", "%CWD%"] -> 可以定位到当前打开文件所在的目录.
