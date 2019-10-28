+++
toc = true
title = "测试引擎"
weight = 9
+++

ShardingSphere提供了完善的测试引擎。它以XML方式定义SQL，每条SQL由SQL解析单元测试引擎和整合测试引擎驱动，每个引擎分别为H2、MySQL、PostgreSQL、SQLServer和Oracle数据库运行测试用例。

SQL解析单元测试全面覆盖SQL占位符和字面量维度。整合测试进一步拆分为策略和JDBC两个维度，策略维度包括分库分表、仅分表、仅分库、读写分离等策略，JDBC维度包括Statement、PreparedStatement。

因此，1条SQL会驱动5种数据库的解析 * 2种参数传递类型 + 5种数据库 * 5种分片策略 * 2种JDBC运行方式 = 60个测试用例，以达到ShardingSphere对于高质量的追求。

# 整合测试

## 配置

为了能让测试变得更容易上手，integration-test 引擎无需修改任何 Java 代码，只需要配置好以下几种配置文件，就可以运行所有的断言了：
  - 环境类文件
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env.properties
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env/SQL-TYPE/dataset.xml
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env/SQL-TYPE/schema.xml
  - 测试用例类文件
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/sql-type-integrate-test-cases.xml
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/dataset/*.xml
  - sql-case 文件
  	- /incubator-shardingsphere/sharding-sql-test/src/main/resources/sql/sharding/SQL-TYPE/*.xml

**环境配置** - 整合测试需要真实的数据库环境，需要根据要测试的数据库创建相关环境并修改相应的配置文件：  

修改 `/incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env.properties` 文件，例如 ： 

```.env
# 测试主键，并发，column index 等的开关
run.additional.cases=false

# 分片策略，可以指定多种策略
sharding.rule.type=db,tbl,dbtbl_with_masterslave,masterslave

# 指定要测试的数据库，可以指定多种数据库(H2,MySQL,Oracle,SQLServer,PostgreSQL)
databases=MySQL,PostgreSQL

# mysql 的配置
mysql.host=127.0.0.1
mysql.port=13306
mysql.username=root
mysql.password=root

## postgresql 的配置
postgresql.host=db.psql
postgresql.port=5432
postgresql.username=postgres
postgresql.password=

## sqlserver 的配置
sqlserver.host=db.mssql
sqlserver.port=1433
sqlserver.username=sa
sqlserver.password=Jdbc1234

## oracle 的配置
oracle.host=db.oracle
oracle.port=1521
oracle.username=jdbc
oracle.password=jdbc
```

## 注意事项

1. 如需测试Oracle，请在pom.xml中增加Oracle驱动依赖。

1. 为了保证测试数据的完整性，整合测试中的分库分表采用了10库10表的方式，因此运行测试用例的时间会比较长。

# SQL解析引擎测试

## 测试环境

SQL解析引擎测试是基于SQL本身的解析，因此无需连接数据库，直接运行`AllParsingTests`即可。

