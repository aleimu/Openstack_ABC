__new__和__init__的区别
    __new__是一个静态方法,而__init__是一个实例方法.
    __new__方法会返回一个创建的实例,而__init__什么都不返回.
    只有在__new__返回一个cls的实例时后面的__init__才能被调用.
    当创建一个新实例时调用__new__,初始化一个实例时用__init__.
    
    
apache和nginx的区别
    nginx 相对 apache 的优点：

    轻量级，同样起web 服务，比apache 占用更少的内存及资源
    抗并发，nginx 处理请求是异步非阻塞的，支持更多的并发连接，而apache 则是阻塞型的，在高并发下nginx 能保持低资源低消耗高性能
    配置简洁
    高度模块化的设计，编写模块相对简单
    社区活跃
    apache 相对nginx 的优点：

    rewrite ，比nginx 的rewrite 强大
    模块超多，基本想到的都可以找到
    少bug ，nginx 的bug 相对较多
    超稳定

CSRF(Cross-site request forgery)跨站请求伪造
XSS(Cross Site Scripting)跨站脚本攻击

什么是RESTful架构：
　　（1）每一个URI代表一种资源；
　　（2）客户端和服务器之间，传递这种资源的某种表现层；
　　（3）客户端通过四个HTTP动词，对服务器端资源进行操作，实现"表现层状态转化"。
  
  在设计模式中，Socket其实就是一个门面模式，它把复杂的TCP/IP协议族隐藏在Socket接口后面，对用户来说，一组简单的接口就是全部，让Socket去组织数据，以符合指定的协议。
  Socket=Ip address+ TCP/UDP + port
  
HTTP1.0和HTTP1.1
推荐: http://blog.csdn.net/elifefly/article/details/3964766
请求头Host字段,一个服务器多个网站
长链接
文件断点续传
身份认证,状态管理,Cache缓存


常见的代码题

1.交叉链表求交点
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None
def node(l1, l2):
    length1, lenth2 = 0, 0
    # 求两个链表长度
    while l1.next:
        l1 = l1.next
        length1 += 1
    while l2.next:
        l2 = l2.next
        length2 += 1
    # 长的链表先走
    if length1 > lenth2:
        for _ in range(length1 - length2):
            l1 = l1.next
    else:
        for _ in range(length2 - length1):
            l2 = l2.next
    while l1 and l2:
        if l1.next == l2.next:
            return l1.next
        else:
            l1 = l1.next
            l2 = l2.next
 2.二分查找   
def binarySearch(l, t):
    low, high = 0, len(l) - 1
    while low < high:
        print low, high
        mid = (low + high) / 2
        if l[mid] > t:
            high = mid
        elif l[mid] < t:
            low = mid + 1
        else:
            return mid
    return low if l[low] == t else False
 
if __name__ == '__main__':
    l = [1, 4, 12, 45, 66, 99, 120, 444]
    print binarySearch(l, 12)

3.快排    
def qsort(seq):
    if seq==[]:
        return []
    else:
        pivot=seq[0]
        lesser=qsort([x for x in seq[1:] if x<pivot])
        greater=qsort([x for x in seq[1:] if x>=pivot])
        return lesser+[pivot]+greater
 
if __name__=='__main__':
    seq=[5,6,78,9,0,-1,2,3,-65,12]
    print(qsort(seq))
    print binarySearch(l, 1)
    print binarySearch(l, 13)
    print binarySearch(l, 444)
    
4.广度遍历和深度遍历二叉树
## 14 二叉树节点
class Node(object):
    def __init__(self, data, left=None, right=None):
        self.data = data
        self.left = left
        self.right = right
 
tree = Node(1, Node(3, Node(7, Node(0)), Node(6)), Node(2, Node(5), Node(4)))
 
## 15 层次遍历
def lookup(root):
    stack = [root]
    while stack:
        current = stack.pop(0)
        print current.data
        if current.left:
            stack.append(current.left)
        if current.right:
            stack.append(current.right)
## 16 深度遍历
def deep(root):
    if not root:
        return
    print root.data
    deep(root.left)
    deep(root.right)
 
if __name__ == '__main__':
    lookup(tree)
    deep(tree)



