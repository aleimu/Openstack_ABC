
mabiao1=[0,1,2,3,4,5,6,7,8,9]
mabiao2=['0','1','2','3','4','5','6','7','8','9']
#思路：判断正负数，都转为正数数字再除以10取余数，余数再和码表对比获得余数的str格式
def intstr(nb:int):
    strs = []
    index = 0
    if nb < 0:
        strs.insert(0,'-')
        nb *= -1
        index = 1
    elif nb == 0:
        strs='0'
        return strs
    len = 0
    tmpnb = nb
    while 0 != tmpnb:
        len+=1
        tmpnb = tmpnb // 10
    for x in range(len):
        t=mabiao1.index(nb % 10)
        strs.insert(index,mabiao2[t])
        nb = nb // 10

    strs.reverse()
    print(strs)
    s=''
    for x in strs:
        s=x+s
    return s
#思路：判断正负，然后遍历str再对比码表
def strint(bn:str):
    ints=[]
    flag=False
    if bn[0]=='-':
        bn=bn[1:]
        flag = True
    elif bn=='0':
        return 0
    for x in bn:
        t=mabiao2.index(x)
        print('t:',t)
        ints.insert(0,mabiao1[t])
    ints.reverse()
    s=0
    for x in ints:
        s=s*10+x
    if flag:
        s=s*-1
    return s

print('int_to_str:',intstr(-104240))
print('str_to_int:',strint('-1000044400'))

print('int_to_str:',intstr(-104240))
print('str_to_int:',strint('-1000044400'))
