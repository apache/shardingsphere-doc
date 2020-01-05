+++
pre = "<b>2.3. </b>"
toc = true
title = "Sharding-Sql-Parser"
weight = 2
+++

## 1. Module introduction

|           | *DBType* | *Submodule*  | *Introduction* |
| --------- | --------------- | ----------------- | ------------------ |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| BaseRule.g4| Basic rules, Statement module reference|
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DALStatement.g4| Data access language    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DCLStatement.g4| Database Control Language    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DDLStatement.g4| Database definition language    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DMLStatement.g4| Data manipulation language    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| Keyword.g4| Common keywords   |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| DBKeyword.g4| Database Unique keywords    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| StoreProcedure.g4| Stored procedure    |
|  | MySQL/ORACLE/PostgreSQL/SQL92/SQLServer| TCLStatement.g4| Transaction control language    |

## 二. Case introduction
* 2.1 Exception key "java.sql.SQLException: No value specified for parameter"

      Cause Analysis:The current Statement does not support the corresponding function, you need to add this funciton in functionCall
      Solution:
             2.1.1 Add the function in the [DBKeyword.g4] file
             2.1.2 Add the function to the [BaseRule.g4] file and try again
      Issue:https://github.com/apache/incubator-shardingsphere/issues/3716    
      
*  2.2 Exception key "Cause: java.lang.IllegalStateException"
         
       Cause Analysis:Whether a keyword can be used as a columnname depends on whether the keyword is contained in the reserved words of the corresponding database
       Solution:
             2.2.1 Check if there is this keyword in [Keyword.g4], if not add retry
             2.2.2 Add this keyword in [BaseRule.g4]#unreservedWord_, if not added, try again
       Issue:https://github.com/apache/incubator-shardingsphere/issues/3842       
             