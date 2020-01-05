+++
pre = "<b>2.3. </b>"
toc = true
title = "Sharding-Sql-Parser"
weight = 2
+++

## 1. 模块介绍

|           | *DBType* | *子模块*  | *介绍* |
| --------- | --------------- | ----------------- | ------------------ |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| BaseRule.g4| 基础规则,Statement模块引用    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DALStatement.g4| 数据访问语言    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DCLStatement.g4| 数据库控制语言    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DDLStatement.g4| 数据库定义语言    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DCLStatement.g4| 数据库控制语言    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DMLStatement.g4| 数据操纵语言    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| Keyword.g4| 常用关键字   |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DBKeyword.g4| DB特有的关键字    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| StoreProcedure.g4| 存储过程    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| TCLStatement.g4| 事务控制语言    |

## 二. Case介绍
* 2.1 异常关键字 "java.sql.SQLException: No value specified for parameter"

      原因分析:当前Statement不支持相应的function，需要在functionCall添加此funciton
      解决方案:
             2.1.1 在[**{DBType}**Keyword.g4]文件中添加该函数
             2.1.2 在[BaseRule.g4]文件中添加改函数然后进行重试
      issue:https://github.com/apache/incubator-shardingsphere/issues/3716    
      
*  2.2 异常关键字 "Cause: java.lang.IllegalStateException"
         
       原因分析:关键词能否作为columnname取决于对应数据库的reserved words里是否包含此关键词
       解决方案:
             2.2.1 在[Keyword.g4]检查是否有此关键词，若没有添加重试
             2.2.2 在[BaseRule.g4]#unreservedWord_添加此关键词,若没有添加重试
       issue:https://github.com/apache/incubator-shardingsphere/issues/3842       
             