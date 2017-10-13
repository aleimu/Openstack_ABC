import chardet

# pip install chardet

# 检测特定页面的编码格式

f = open('./dome3.py', 'rb')
data = f.read()
f.close()
# 得到脚本字符集编码格式
encoding_result = chardet.detect(data)
print(encoding_result)

'''

{'encoding': 'utf-8', 'confidence': 0.99, 'language': ''}
其准确率99%的概率，编码格式为utf-8

'''
# 增量检测编码格式

from chardet.universaldetector import UniversalDetector
detector = UniversalDetector()

with open('./dome3.py', 'rb') as f:
    for x in f.readlines():
        # print(x)
        detector.feed(x)
        if detector.done:
            break
    detector.close()
print(detector.result)

'''
为了提高预测的准确性，基于dector.feed()来实现持续的信息输入，在信息足够充足之后结束信息输入，给出相应的预测和判断。
如果需要复用detector方法，需要进行detector.reset()进行重置，从而可以复用。
'''

# 在安装chardet之后，可以基于命令行来检测文件编码
# 在系统层面，可以直接基于命令行来进行文件编码检测，非常简单易用。
'''
E:\下载9月\python_learn-master\消息队列
λ chardetect.exe .\dome1.py .\direct_mode.py .\dome2.py
.\dome1.py: utf-8 with confidence 0.99
.\direct_mode.py: utf-8 with confidence 0.99
.\dome2.py: utf-8 with confidence 0.99

'''
