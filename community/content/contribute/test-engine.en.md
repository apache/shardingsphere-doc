+++
toc = true
title = "Test Engine"
weight = 9
+++

ShardingSphere provided a full functionality test engine. it defines SQL by XML format, and every single SQL is drove by SQL parse unit test engine and integration test engine,
and each engine is suit for H2、MySQL、PostgreSQL、SQLServer and Oracle

The SQL parsing unit test covers both SQL placeholder and literal dimension. 
Integration test can be further divided into two dimensions of strategy and JDBC; the former one includes strategies as Sharding, table Sharding, database Sharding, and read-write split while the latter one includes `Statement` and `PreparedStatement`.

Therefore, one SQL can drive 5 kinds of database parsing * 2 kinds of parameter transmission modes + 5 kinds of databases * 5 kinds of Sharding strategies * 2 kinds of JDBC operation modes = 60 test cases, to enable ShardingSphere to achieve the pursuit of high quality.

# Integration Test

## Configuration

in order to make test easier to start, integration-test designed for just modify the following configuration files to execute all asserts without any java code modification
  - environment type
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env.properties
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env/SQL-TYPE/dataset.xml
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env/SQL-TYPE/schema.xml
  - test case type
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/SQL-TYPE-integrate-test-cases.xml
    - /incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/dataset/SHARDING-TYPE/*.xml
  - sql-case 
  	- /incubator-shardingsphere/sharding-sql-test/src/main/resources/sql/sharding/SQL-TYPE/*.xml

### Environment Configuration

Integration test depends on existed database environment, we need to modify the config file for corresponding database to test

first, modify config file `/incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env.properties` ，for example ： 

```.env
# the switch for PK, concurrent, column index testing and so on
run.additional.cases=false

# sharding rule, could define multiple rules
sharding.rule.type=db,tbl,dbtbl_with_masterslave,masterslave

# databse type, could define multiple databses(H2,MySQL,Oracle,SQLServer,PostgreSQL)
databases=MySQL,PostgreSQL

# mysql config
mysql.host=127.0.0.1
mysql.port=13306
mysql.username=root
mysql.password=root

## postgresql config
postgresql.host=db.psql
postgresql.port=5432
postgresql.username=postgres
postgresql.password=

## sqlserver config
sqlserver.host=db.mssql
sqlserver.port=1433
sqlserver.username=sa
sqlserver.password=Jdbc1234

## oracle config
oracle.host=db.oracle
oracle.port=1521
oracle.username=jdbc
oracle.password=jdbc
```

after that we need to modify config file `/incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/env/SQL-TYPE/dataset.xml` 。
in dataset.xml, set up metadata(sharding rule) and row(test data) to start the data initialization. for example, define table sharding rule and test data as following:
```xml
<dataset>
    <metadata data-nodes="tbl.t_order_${0..9}">
        <column name="order_id" type="numeric" />
        <column name="user_id" type="numeric" />
        <column name="status" type="varchar" />
    </metadata>
    <row data-node="tbl.t_order_0" values="1000, 10, init" />
    <row data-node="tbl.t_order_1" values="1001, 10, init" />
    <row data-node="tbl.t_order_2" values="1002, 10, init" />
    <row data-node="tbl.t_order_3" values="1003, 10, init" />
    <row data-node="tbl.t_order_4" values="1004, 10, init" />
    <row data-node="tbl.t_order_5" values="1005, 10, init" />
    <row data-node="tbl.t_order_6" values="1006, 10, init" />
    <row data-node="tbl.t_order_7" values="1007, 10, init" />
    <row data-node="tbl.t_order_8" values="1008, 10, init" />
    <row data-node="tbl.t_order_9" values="1009, 10, init" />
</dataset>
```

and you could add more create table / create schema clause if you want some other test data

### SQL 配置

前面我们已经设置好了集成测试的相关环境以及初始化的数据，接下来我们要定义一下要测试的 SQL，换句话说，基于上面的环境，我们要断言什么 SQL。
要断言的 SQL 存放在 `/incubator-shardingsphere/sharding-sql-test/src/main/resources/sql/sharding/SQL-TYPE/*.xml`，就像如下配置：

```xml
<sql-cases>
    <sql-case id="update_without_parameters" value="UPDATE t_order SET status = 'update' WHERE order_id = 1000 AND user_id = 10" />
    <sql-case id="update_with_alias" value="UPDATE t_order AS o SET o.status = ? WHERE o.order_id = ? AND o.user_id = ?" db-types="MySQL,H2" />
  </sql-cases>
```

通过这个配置，我们指定了要断言的 SQL 以及数据库类型。这个 SQL 可以在不同模块下的测试用例中共享，这也是为什么我们把 sharding-sql-test 提取为单独的模块

### 断言配置

通过前面的配置，我们确定了什么 SQL 在什么环境执行的问题，这里我们定义下需要断言的数据。
断言的配置，需要两种文件，第一类文件位于 `/incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/SQL-TYPE-integrate-test-cases.xml`
这个文件类似于一个索引，定义了要执行的 SQL，参数以及期待的数据的位置。这里的 SQL，引用的就是 sql-test 中 SQL 对应的 sql-case-id，例子如下：

```xml
<integrate-test-cases>
    <dml-test-case sql-case-id="insert_with_all_placeholders">
       <assertion parameters="1:int, 1:int, insert:String" expected-data-file="insert_for_order_1.xml" />
       <assertion parameters="2:int, 2:int, insert:String" expected-data-file="insert_for_order_2.xml" />
    </dml-test-case>
</integrate-test-cases>
```
还有一类文件，就是具体的断言数据，也就是上面配置中的 expected-data-file 对应的文件，文件在 `/incubator-shardingsphere/sharding-integration-test/sharding-jdbc-test/src/test/resources/integrate/cases/SQL-TYPE/dataset/SHARDING-TYPE/*.xml`
这个文件内容根前面提及的 dataset.xml 的内容特别相似，只不过 expected-data-file 文件中不仅定义了断言的数据，还有相应 SQL 执行后的返回值等，例子如下：

```xml
<dataset update-count="1">
    <metadata data-nodes="db_${0..9}.t_order">
        <column name="order_id" type="numeric" />
        <column name="user_id" type="numeric" />
        <column name="status" type="varchar" />
    </metadata>
    <row data-node="db_0.t_order" values="1000, 10, update" />
    <row data-node="db_0.t_order" values="1001, 10, init" />
    <row data-node="db_0.t_order" values="2000, 20, init" />
    <row data-node="db_0.t_order" values="2001, 20, init" />
</dataset>
```
至此，所有需要配置的数据，都已经配置完毕，接了来我们启动相应的集成测试类即可，全程不需要修改任何 Java 代码，只需要在 xml 中做数据初始化以及断言，极大的降低了ShardingSphere 数据测试的门槛以及复杂度。

## 注意事项

1. 如需测试Oracle，请在pom.xml中增加Oracle驱动依赖。

1. 为了保证测试数据的完整性，整合测试中的分库分表采用了10库10表的方式，因此运行测试用例的时间会比较长。

# SQL解析引擎测试

## 数据准备

不同于集成测试，SQL 解析不需要真实的测试环境，只需要我们定义好要测试的 SQL，以及解析后的断言数据即可：

### SQL 数据

在集成测试的部分，我们提到过 sql-case-id，这个 id 对应的 SQL，是可以在不同模块共享的，我们只需要在 `/incubator-shardingsphere/sharding-sql-test/src/main/resources/sql/sharding/SQL-TYPE/*.xml` 添加要测试的 SQL 就可以了

### 断言解析数据

断言的解析数据保存在 `/incubator-shardingsphere/sharding-core/sharding-core-parse/sharding-core-parse-test/src/test/resources/sharding/SQL-TYPE/*.xml`
在 xml 文件中，我们可以针对表名，token，SQL 条件等去进行断言，例如如下的配置：

```.xml
<parser-result-sets>
<parser-result sql-case-id="insert_with_multiple_values">
        <tables>
            <table name="t_order" />
        </tables>
        <tokens>
            <table-token start-index="12" table-name="t_order" length="7" />
        </tokens>
        <sharding-conditions>
            <and-condition>
                <condition column-name="order_id" table-name="t_order" operator="EQUAL">
                    <value literal="1" type="int" />
                </condition>
                <condition column-name="user_id" table-name="t_order" operator="EQUAL">
                    <value literal="1" type="int" />
                </condition>
            </and-condition>
            <and-condition>
                <condition column-name="order_id" table-name="t_order" operator="EQUAL">
                    <value literal="2" type="int" />
                </condition>
                <condition column-name="user_id" table-name="t_order" operator="EQUAL">
                    <value literal="2" type="int" />
                </condition>
            </and-condition>
        </sharding-conditions>
    </parser-result>
</parser-result-sets>
```
设置好上面两类数据，我们就可以通过 sharding-core-parse-test 下对应的 engine 启动 SQL 解析的测试了。