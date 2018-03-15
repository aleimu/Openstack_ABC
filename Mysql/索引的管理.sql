CREATE TABLE `award` (
   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
   `aty_id` varchar(100) NOT NULL DEFAULT '' COMMENT '活动场景id',
   `nickname` varchar(12) NOT NULL DEFAULT '' COMMENT '用户昵称',
   `is_awarded` tinyint(1) NOT NULL DEFAULT 0 COMMENT '用户是否领奖',
   `award_time` int(11) NOT NULL DEFAULT 0 COMMENT '领奖时间',
   `account` varchar(12) NOT NULL DEFAULT '' COMMENT '帐号',
   `password` char(32) NOT NULL DEFAULT '' COMMENT '密码',
   `message` varchar(255) NOT NULL DEFAULT '' COMMENT '获奖信息',
   `created_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
   `updated_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
   PRIMARY KEY (`id`)
 ) 
ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='获奖信息表';

/*

#MySQL 索引管理与执行计划
http://www.cnblogs.com/clsn/p/8087501.html

先假设有一张表,表的数据有10W条数据,其中有一条数据是nickname='css',如果要拿这条数据的话需要些的sql是 SELECT * FROM award WHERE nickname = 'css'
一般情况下,在没有建立索引的时候,mysql需要扫描全表及扫描10W条数据找这条数据,如果我在nickname上建立索引,那么mysql只需要扫描一行数据及为我们找到这条nickname='css'的数据,这就是索引能提升查询性能的原因

mysql的索引分为单列索引(主键索引,唯索引,普通索引)和组合索引.
单列索引:一个索引只包含一个列,一个表可以有多个单列索引.
组合索引:一个组合索引包含两个或两个以上的列

#索引的创建

1. 单列索引
CREATE INDEX IndexName ON `TableName`(`字段名`(length)) 或者 ALTER TABLE TableName ADD INDEX IndexName(`字段名`(length))

如果是CHAR,VARCHAR,类型,length可以小于字段的实际长度,如果是BLOB和TEXT类型就必须指定长度

CREATE INDEX account_Index ON `award`(`account`);
ALTER TABLE award ADD INDEX account_Index(`account`)

2. 唯一索引
CREATE UNIQUE INDEX IndexName ON `TableName`(`字段名`(length)); 或者 ALTER TABLE TableName ADD UNIQUE (column_list);

与普通索引类似,但是不同的是唯一索引要求所有的类的值是唯一的,这一点和主键索引一样.但是他允许有空值
CREATE UNIQUE INDEX account_UNIQUE_Index ON `award`(`account`);

3. 主键索引,不允许有空值,(在B+TREE中的InnoDB引擎中,主键索引起到了至关重要的地位)
主键索引建立的规则是 int优于varchar,一般在建表的时候创建,最好是与表的其他字段不相关的列或者是业务不相关的列.一般会设为 int 而且是 AUTO_INCREMENT自增类型的
数据库表经常有一列或多列组合，其值唯一标识表中的每一行。该列称为表的主键。在数据库关系图中为表定义主键将自动创建主键索引，主键索引是唯一索引的特定类型。

4. 组合索引
CREATE INDEX nickname_account_createdTime_Index ON `award`(`nickname`, `account`, `created_time`);

CREATE INDEX IndexName On `TableName`(`字段名`(length),`字段名`(length),...);
一个表中含有多个单列索引不代表是组合索引,通俗一点讲 组合索引是:包含多个字段但是只有索引名称,如果你建立了 组合索引(nickname_account_createdTime_Index) 那么他实际包含的是3个索引 (nickname) (nickname,account)(nickname,account,created_time)

5. 全文索引
ALTER TABLE tablename ADD FULLTEXT(column1, column2)

有了全文索引，就可以用SELECT查询命令去检索那些包含着一个或多个给定单词的数据记录了。
SELECT * FROM tablename WHERE MATCH(column1, column2) AGAINST(‘xxx′, ‘sss′, ‘ddd′)
这条命令将把column1和column2字段里有xxx、sss和ddd的数据记录全部查询出来。

#索引的查看
SHOW INDEX FROM table_name [FROM db_name]；
SHOW INDEX FROM [db_name.]table_name；

#索引的删除
DORP INDEX IndexName ON TableName;
ALTER TABLE table_name DROP INDEX index_name;

#索引的修改
没有提供修改索引的直接指令，一般情况下，我们需要先删除掉原索引，再根据需要创建一个同名的索引，从而变相地实现修改索引操作。
--先删除
ALTER TABLE user
DROP INDEX idx_user_username;
--再以修改后的内容创建同名索引
CREATE INDEX idx_user_username ON user (username(8));

*/

/*
SQL语句优化

1 企业SQL优化思路
　　1、把一个大的不使用索引的SQL语句按照功能进行拆分
　　2、长的SQL语句无法使用索引，能不能变成2条短的SQL语句让它分别使用上索引。
　　3、对SQL语句功能的拆分和修改
　　4、减少'烂'SQL由运维（DBA）和开发交流（确认），共同确定如何改，最终由DBA执行
　　5、制定开发流程

2 不适合走索引的场景
　　1、唯一值少的列上不适合建立索引或者建立索引效率低。例如：性别列
　　2、小表可以不建立索引，100条记录。
　　3、对于数据仓库，大量全表扫描的情况，建索引反而会慢

3 查看表的唯一值数量
    select count(distinct user) from mysql.user;
    select count(distinct user,host) from mysql.user;

4 建立索引流程

　　1、找到慢SQL。
        show processlist;
    　　记录慢查询日志。
　　2、explain select句,条件列多。
　　3、查看表的唯一值数量：
        select count(distinct user) from mysql.user;
        select count(distinct user,host) from mysql.user;
　　　　条件列多。可以考虑建立联合索引。
　　4、建立索引(流量低谷)
　　5、拆开语句（和开发）。
　　6、like '%%'不用mysql
　　7、进行判断重复的行数
        查看行数:
        mysql> select count(*) from city;
        +----------+
        | count(*) |
        +----------+
        |     4079 |
        +----------+
        1 row in set (0.00 sec)
        查看去重后的行数：
        mysql> select count(distinct countrycode) from city;
        +-----------------------------+
        | count(distinct countrycode) |
        +-----------------------------+
        |                         232 |
        +-----------------------------+
        1 row in set (0.00 sec)

 
用explain查看SQL的执行计划,EXPLAIN命令是查看优化器如何决定执行查询的主要方法。可以帮助我们深入了解MySQL的基于开销的优化器，还可以获得很多可能被优化器考虑到的访问策略的细节，以及当运行SQL语句时哪种策略预计会被优化器采用。
explain select id,name from test where name='clsn';

1.EXPLAIN SELECT ……
2.EXPLAIN EXTENDED SELECT ……
　　将执行计划"反编译"成SELECT语句，运行SHOW WARNINGS 可得到被MySQL优化器优化后的查询语句
3.EXPLAIN PARTITIONS SELECT ……
　　用于分区表的EXPLAIN生成QEP的信息

*/

/*

*/

