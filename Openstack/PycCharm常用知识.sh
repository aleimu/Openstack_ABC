----------------------- Page 1-----------------------

                                                                                      Running                                                                                Search/Replace 

                                                                                      Alt + Shift + F10          Select configuration and run                                Ctrl + F / Ctrl + R       Find/Replace 
DEFAULT KEYMAP                                                                        Alt + Shift + F9           Select configuration and debug                              F3 / Shift + F3           Find next/previous 
                                                                                      Shift + F10                Run                                                         Ctrl + Shift + F          Find in path 
                                                                                      Shift + F9                 Debug                                                       Ctrl + Shift + R          Replace in path 
                                                                                      Ctrl + Shift + F10         Run context configuration from editor 
                                                                                      Ctrl + Alt + R             Run manage.py task                                          Usage Search 

Editing                                                                               Debugging                                                                              Alt + F7 / Ctrl + F7      Find usages / Find usages in file 
                                                                                                                                                                             Ctrl + Shift + F7         Highlight usages in file 
Ctrl + Space               Basic code completion (the name                            F8 / F7                    Step over/into                                              Ctrl + Alt + F7           Show usages 
                           of any class, method or variable)                          Shift + F8                 Step out 
Ctrl + Alt + Space         Class name completion (the name of any                     Alt + F9                   Run to cursor                                               Refactoring 
                           project class independently of current                     Alt + F8                   Evaluate expression 
                           imports)                                                   Ctrl + Alt + F8            Quick evaluate expression                                   F5 / F6                   Copy / Move 
Ctrl + Shift + Enter       Complete statement                                         F9                         Resume program                                              Alt + Delete              Safe Delete 
Ctrl + P                   Parameter info (within method call arguments)              Ctrl + F8                  Toggle breakpoint                                           Shift + F6                Rename 
Ctrl + Q                   Quick documentation lookup                                 Ctrl + Shift + F8          View breakpoints                                            Ctrl + F6                 Change Signature 
Shift + F1                 External Doc                                                                                                                                      Ctrl + Alt + N             Inline 
Ctrl + mouse over code     Brief Info                                                 Navigation                                                                             Ctrl + Alt + M            Extract Method 
Ctrl + F1                  Show descriptions of error or warning at caret                                                                                                    Ctrl + Alt + V            Extract Variable 
Alt + Insert               Generate code...                                           Ctrl + N                   Go to class                                                 Ctrl + Alt + F            Extract Field 
Ctrl + O                   Override methods                                           Ctrl + Shift + N           Go to file                                                  Ctrl + Alt + C            Extract Constant 
Ctrl + Alt + T             Surround with...                                           Ctrl + Alt + Shift + N     Go to symbol                                                Ctrl + Alt + P            Extract Parameter 
Ctrl + /                   Comment/uncomment with line comment                        Alt + Right                Go to next editor tab 
Ctrl + Shift + /           Comment/uncomment with block comment                       Alt + Left                 Go to previous editor tab                                   VCS/Local History 
Ctrl + W                   Select successively increasing code blocks                 F12                        Go back to previous tool window 
Ctrl + Shift + W           Decrease current selection to previous state               Esc                        Go to editor (from tool window)                             Ctrl + K                  Commit project to VCS 
Ctrl + Shift + ]           Select till code block end                                 Shift + Esc                Hide active or last active window                           Ctrl + T                  Update project from VCS 
Ctrl + Shift + [           Select till code block start                               Ctrl + Shift + F4          Close active run/messages/find/... tab                      Alt + Shift + C           View recent changes 
Alt + Enter                Show intention actions and quick-fixes                     Ctrl + G                   Go to line                                                  Alt + BackQuote (`)       ‘VCS’ quick popup 
Ctrl + Alt + L             Reformat code                                              Ctrl + E                   Recent files popup 
Ctrl + Alt + O             Optimize imports                                           Ctrl + Alt + Right         Navigate forward                                            Live Templates 
Ctrl + Alt + I             Auto-indent line(s)                                        Ctrl + Alt + Left          Navigate back 
Tab                        Indent selected lines                                      Ctrl + Shift + Backspace Navigate to last edit location                                Ctrl + Alt + J            Surround with Live Template 
Shift + Tab                Unindent selected lines                                    Alt + F1                   Select current file or symbol in any view                   Ctrl + J                   Insert Live Template 
Ctrl + X , Shift + Delete  Cut current line or selected block to clipboard            Ctrl + B , Ctrl + Click    Go to declaration 
Ctrl + C , Ctrl + Insert   Copy current line or selected block                        Ctrl + Alt + B             Go to implementation(s)                                     General 
                           to clipboard                                               Ctrl + Shift + I           Open quick definition lookup 
Ctrl + V , Shift + Insert  Paste from clipboard                                       Ctrl + Shift + B           Go to type declaration                                      Alt + #[0-9]              Open corresponding tool window 
Ctrl + Shift + V           Paste from recent buffers...                               Ctrl + U                   Go to super-method/super-class                              Ctrl + S                  Save all 
Ctrl + D                   Duplicate current line or selected block                   Alt + Up / Down            Go to previous/next method                                  Ctrl + Alt + Y            Synchronize 
Ctrl + Y                   Delete line at caret                                       Ctrl + ] / [               Move to code block end/start                                Ctrl + Shift + F12        Toggle maximizing editor 
Ctrl + Shift + J           Smart line join                                            Ctrl + F12                 File structure popup                                        Alt + Shift + F           Add to Favorites 
Ctrl + Enter               Smart line split                                           Ctrl + H                   Type hierarchy                                              Alt + Shift + I            Inspect current file with current profile 
Shift + Enter              Start new line                                             Ctrl + Shift + H           Method hierarchy                                            Ctrl + BackQuote (`)      Quick switch current scheme 
Ctrl + Shift + U           Toggle case for word at caret or selected                  Ctrl + Alt + H             Call hierarchy                                              Ctrl + Alt + S            Open Settings dialog 
                           block                                                      F2 / Shift + F2            Next/previous highlighted error                             Ctrl + Shift + A          Find Action 
Ctrl + Delete              Delete to word end                                         F4                         Edit source                                                 Ctrl + Tab                Switch between tabs and tool window 
Ctrl + Backspace           Delete to word start                                       Ctrl + Enter               View source 
Ctrl + NumPad+             Expand code block                                          Alt + Home                 Show navigation bar                                         To find any action inside the IDE use Find Action (Ctrl + Shift + A) 
Ctrl + NumPad-             Collapse code block                                        F11                        Toggle bookmark 
Ctrl + Shift + NumPad+     Expand all                                                 Ctrl + Shift + F11         Toggle bookmark with mnemonic 
Ctrl + Shift + NumPad-     Collapse all                                               Ctrl + #[0-9]              Go to numbered bookmark 
Ctrl + F4                  Close active editor tab                                    Shift + F11                Show bookmarks                                             jetbrains.com/pycharm        blog.jetbrains.com/pycharm        @pycharm 




在PyCharm安装目录 /opt/pycharm-3.4.1/help目录下可以找到ReferenceCard.pdf快捷键英文版说明 or 打开pycharm > help > default keymap ref
PyCharm3.0默认快捷键(翻译的)
{
PyCharm Default Keymap
1、编辑（Editing）
Ctrl + Space    基本的代码完成（类、方法、属性）
Ctrl + Alt + Space  快速导入任意类
Ctrl + Shift + Enter    语句完成
Ctrl + P    参数信息（在方法中调用参数）
Ctrl + Q    快速查看文档
F1   外部文档
Shift + F1    外部文档，进入web文档主页
Ctrl + Shift + Z --> Redo 重做
Ctrl + 悬浮/单击鼠标左键    简介/进入代码定义
Ctrl + F1    显示错误描述或警告信息
Alt + Insert    自动生成代码
Ctrl + O    重新方法
Ctrl + Alt + T    选中
Ctrl + /    行注释/取消行注释
Ctrl + Shift + /    块注释
Ctrl + W    选中增加的代码块
Ctrl + Shift + W    回到之前状态
Ctrl + Shift + ]/[     选定代码块结束、开始
Alt + Enter    快速修正
Ctrl + Alt + L     代码格式化
Ctrl + Alt + O    优化导入
Ctrl + Alt + I    自动缩进
Tab / Shift + Tab  缩进、不缩进当前行
Ctrl+X/Shift+Delete    剪切当前行或选定的代码块到剪贴板
Ctrl+C/Ctrl+Insert    复制当前行或选定的代码块到剪贴板
Ctrl+V/Shift+Insert    从剪贴板粘贴
Ctrl + Shift + V    从最近的缓冲区粘贴
Ctrl + D  复制选定的区域或行
Ctrl + Y    删除选定的行
Ctrl + Shift + J  添加智能线
Ctrl + Enter   智能线切割
Shift + Enter    另起一行
Ctrl + Shift + U  在选定的区域或代码块间切换
Ctrl + Delete   删除到字符结束
Ctrl + Backspace   删除到字符开始
Ctrl + Numpad+/-   展开/折叠代码块（当前位置的：函数，注释等）
Ctrl + shift + Numpad+/-   展开/折叠所有代码块
Ctrl + F4   关闭运行的选项卡
 2、查找/替换(Search/Replace)
F3   下一个
Shift + F3   前一个
Ctrl + R   替换
Ctrl + Shift + F  或者连续2次敲击shift   全局查找{可以在整个项目中查找某个字符串什么的，如查找某个函数名字符串看之前是怎么使用这个函数的}
Ctrl + Shift + R   全局替换
 3、运行(Running)
Alt + Shift + F10   运行模式配置
Alt + Shift + F9    调试模式配置
Shift + F10    运行
Shift + F9   调试
Ctrl + Shift + F10   运行编辑器配置
Ctrl + Alt + R   运行manage.py任务
 4、调试(Debugging)
F8   跳过
F7   进入
Shift + F8   退出
Alt + F9    运行游标
Alt + F8    验证表达式
Ctrl + Alt + F8   快速验证表达式
F9    恢复程序
Ctrl + F8   断点开关
Ctrl + Shift + F8   查看断点
 5、导航(Navigation)
Ctrl + N    跳转到类
Ctrl + Shift + N    跳转到符号
Alt + Right/Left    跳转到下一个、前一个编辑的选项卡（代码文件）
Alt + Up/Down跳转到上一个、下一个方法
F12    回到先前的工具窗口
Esc    从工具窗口回到编辑窗口
Shift + Esc   隐藏运行的、最近运行的窗口
Ctrl + Shift + F4   关闭主动运行的选项卡
Ctrl + G    查看当前行号、字符号
Ctrl + E   当前文件弹出，打开最近使用的文件列表
Ctrl+Alt+Left/Right   后退、前进
Ctrl+Shift+Backspace    导航到最近编辑区域 {差不多就是返回上次编辑的位置}
Alt + F1   查找当前文件或标识
Ctrl+B / Ctrl+Click    跳转到声明
Ctrl + Alt + B    跳转到实现
Ctrl + Shift + I查看快速定义
Ctrl + Shift + B跳转到类型声明
Ctrl + U跳转到父方法、父类
Ctrl + ]/[跳转到代码块结束、开始
Ctrl + F12弹出文件结构
Ctrl + H类型层次结构
Ctrl + Shift + H方法层次结构
Ctrl + Alt + H调用层次结构
F2 / Shift + F2下一条、前一条高亮的错误
F4 / Ctrl + Enter编辑资源、查看资源
Alt + Home显示导航条F11书签开关
Ctrl + Shift + F11书签助记开关
Ctrl + #[0-9]跳转到标识的书签
Shift + F11显示书签
 6、搜索相关(Usage Search)
Alt + F7/Ctrl + F7文件中查询用法
Ctrl + Shift + F7文件中用法高亮显示
Ctrl + Alt + F7显示用法
 7、重构(Refactoring)
F5复制F6剪切
Alt + Delete安全删除
Shift + F6重命名
Ctrl + F6更改签名
Ctrl + Alt + N内联
Ctrl + Alt + M提取方法
Ctrl + Alt + V提取属性
Ctrl + Alt + F提取字段
Ctrl + Alt + C提取常量
Ctrl + Alt + P提取参数
 8、控制VCS/Local History
Ctrl + K提交项目
Ctrl + T更新项目
Alt + Shift + C查看最近的变化
Alt + BackQuote(’)VCS快速弹出
 9、模版(Live Templates)
Ctrl + Alt + J当前行使用模版
Ctrl +Ｊ插入模版
 10、基本(General)
Alt + #[0-9]打开相应的工具窗口
Ctrl + Alt + Y同步
Ctrl + Shift + F12最大化编辑开关
Alt + Shift + F添加到最喜欢
Alt + Shift + I根据配置检查当前文件
Ctrl + BackQuote(’)快速切换当前计划
Ctrl + Alt + S　打开设置页
Ctrl + Shift + A查找编辑器里所有的动作
Ctrl + Tab在窗口间进行切换 

}
#http://blog.csdn.net/pipisorry/article/details/39909057?locationNum=2&fps=1
pycharm常用设置{
pycharm中的设置是可以导入和导出的，file>export settings可以保存当前pycharm中的设置为jar文件，重装时可以直接import settings>jar文件，就不用重复配置了。

file -> Setting ->Editor
1. 设置Python自动引入包，要先在 >general > autoimport -> python :show popup
   快捷键：Alt + Enter: 自动添加包
2. “代码自动完成”时间延时设置
  > Code Completion   -> Auto code completion in (ms):0  -> Autopopup in (ms):500
3. Pycharm中默认是不能用Ctrl+滚轮改变字体大小的，可以在〉Mouse中设置
4. 显示“行号”与“空白字符”
  > Appearance  -> 勾选“Show line numbers”、“Show whitespaces”、“Show method separators”
5. 设置编辑器“颜色与字体”主题
  > Colors & Fonts -> Scheme name -> 选择"monokai"“Darcula”
  说明：先选择“monokai”，再“Save As”为"monokai-pipi"，因为默认的主题是“只读的”，一些字体大小颜色什么的都不能修改，拷贝一份后方可修改！
  修改字体大小
> Colors & Fonts -> Font -> Size -> 设置为“14”
6. 设置缩进符为制表符“Tab”
  File -> Default Settings -> Code Style
  -> General -> 勾选“Use tab character”
  -> Python -> 勾选“Use tab character”
  -> 其他的语言代码同理设置
7. 去掉默认折叠
  > Code Folding -> Collapse by default -> 全部去掉勾选 
8. pycharm默认是自动保存的，习惯自己按ctrl + s  的可以进行如下设置：
    > General -> Synchronization -> Save files on frame deactivation  和 Save files automatically if application is idle for .. sec 的勾去掉
    > Editor Tabs -> Mark modified tabs with asterisk 打上勾
9.>file and code template>python scripts
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
__title__ = '$Package_name'
__author__ = '$USER'
__mtime__ = '$DATE'
"""

}



