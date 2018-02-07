Python下eval()函数是如何实现的？
https://github.com/python/cpython/blob/05d68a8bd84cb141be9f9335f5b3540f15a989c4/Python/ceval.c
https://github.com/apaxa-go/eval


apaxa-go/eval的实现依赖了下面的库，python eval估计也类似。

go/token库   定义代表Go编程语言的词汇标记的常量和令牌（打印，谓词）的基本操作。
go/ast       声明用于表示Go包的语法树的类型。
go/parser    为Go源文件实现解析器。

#https://github.com/apaxa-go/eval 中的例子

src:="int8(1*(1+2))"
expr,err:=ParseString(src,"")
if err!=nil{
	return err
}
r,err:=expr.EvalToInterface(nil)
if err!=nil{
	return err
}
fmt.Printf("%v %T", r, r)	// "3 int8"

#apaxa-go/eval的部分源码，大概就是把字符串放入文件，再解析
func Parse(filename string, src interface{}, pkgPath string) (r *Expression, err error) {
	r = new(Expression)
	r.fset = token.NewFileSet()
	r.e, err = parser.ParseExprFrom(r.fset, filename, src, 0)
	if err != nil {
		return nil, err
	}
	r.pkgPath = pkgPath
	return
}

func ParseString(src string, pkgPath string) (r *Expression, err error) {
	return Parse(DefaultFileName, src, pkgPath)
}


