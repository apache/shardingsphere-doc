+++
toc = true
title = "Spring Namespace Configuration"
weight = 4
+++

## Notice

Inline expression identifier can can use `${...} ` or `$->{...}`, but the former one clashes with the placeholder in property documents of Spring, so it is suggested to use `$->{...}` for inline expression identifier under Spring environment.

## Configuration Instance

### Data Sharding

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:sharding="http://shardingsphere.io/schema/shardingsphere/sharding"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
                        http://www.springframework.org/schema/beans/spring-beans.xsd
                        http://shardingsphere.io/schema/shardingsphere/sharding 
                        http://shardingsphere.io/schema/shardingsphere/sharding/sharding.xsd
                        http://www.springframework.org/schema/context
                        http://www.springframework.org/schema/context/spring-context.xsd
                        http://www.springframework.org/schema/tx
                        http://www.springframework.org/schema/tx/spring-tx.xsd">
    <context:annotation-config />
    <context:component-scan base-package="io.shardingsphere.example.spring.namespace.jpa" />
    
    <bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="dataSource" ref="shardingDataSource" />
        <property name="jpaVendorAdapter">
            <bean class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter" p:database="MYSQL" />
        </property>
        <property name="packagesToScan" value="io.shardingsphere.example.spring.namespace.jpa.entity" />
        <property name="jpaProperties">
            <props>
                <prop key="hibernate.dialect">org.hibernate.dialect.MySQLDialect</prop>
                <prop key="hibernate.hbm2ddl.auto">create</prop>
                <prop key="hibernate.show_sql">true</prop>
            </props>
        </property>
    </bean>
    <bean id="transactionManager" class="org.springframework.orm.jpa.JpaTransactionManager" p:entityManagerFactory-ref="entityManagerFactory" />
    <tx:annotation-driven />
    
    <bean id="ds0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds0" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="ds1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds1" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="preciseModuloDatabaseShardingAlgorithm" class="io.shardingsphere.example.spring.namespace.jpa.algorithm.PreciseModuloDatabaseShardingAlgorithm" />
    <bean id="preciseModuloTableShardingAlgorithm" class="io.shardingsphere.example.spring.namespace.jpa.algorithm.PreciseModuloTableShardingAlgorithm" />
    
    <sharding:standard-strategy id="databaseShardingStrategy" sharding-column="user_id" precise-algorithm-ref="preciseModuloDatabaseShardingAlgorithm" />
    <sharding:standard-strategy id="tableShardingStrategy" sharding-column="order_id" precise-algorithm-ref="preciseModuloTableShardingAlgorithm" />
    
    <sharding:key-generator id="orderKeyGenerator" type="SNOWFLAKE" column="order_id" />
    <sharding:key-generator id="itemKeyGenerator" type="SNOWFLAKE" column="order_item_id" />
    
    <sharding:data-source id="shardingDataSource">
        <sharding:sharding-rule data-source-names="ds0,ds1">
            <sharding:table-rules>
                <sharding:table-rule logic-table="t_order" actual-data-nodes="ds$->{0..1}.t_order$->{0..1}" database-strategy-ref="databaseShardingStrategy" table-strategy-ref="tableShardingStrategy" key-generator-ref="orderKeyGenerator" />
                <sharding:table-rule logic-table="t_order_item" actual-data-nodes="ds$->{0..1}.t_order_item$->{0..1}" database-strategy-ref="databaseShardingStrategy" table-strategy-ref="tableShardingStrategy" key-generator-ref="itemKeyGenerator" />
            </sharding:table-rules>
            <sharding:binding-table-rules>
                <sharding:binding-table-rule logic-tables="t_order, t_order_item" />
            </sharding:binding-table-rules>
            <sharding:broadcast-table-rules>
                <sharding:broadcast-table-rule table="t_config" />
            </sharding:broadcast-table-rules>
        </sharding:sharding-rule>
    </sharding:data-source>
</beans>
```

### Read-Write Split

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:master-slave="http://shardingsphere.io/schema/shardingsphere/masterslave"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
                        http://www.springframework.org/schema/beans/spring-beans.xsd 
                        http://www.springframework.org/schema/context 
                        http://www.springframework.org/schema/context/spring-context.xsd
                        http://www.springframework.org/schema/tx 
                        http://www.springframework.org/schema/tx/spring-tx.xsd
                        http://shardingsphere.io/schema/shardingsphere/masterslave  
                        http://shardingsphere.io/schema/shardingsphere/masterslave/master-slave.xsd">
    <context:annotation-config />
    <context:component-scan base-package="io.shardingsphere.example.spring.namespace.jpa" />
    
    <bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="dataSource" ref="masterSlaveDataSource" />
        <property name="jpaVendorAdapter">
            <bean class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter" p:database="MYSQL" />
        </property>
        <property name="packagesToScan" value="io.shardingsphere.example.spring.namespace.jpa.entity" />
        <property name="jpaProperties">
            <props>
                <prop key="hibernate.dialect">org.hibernate.dialect.MySQLDialect</prop>
                <prop key="hibernate.hbm2ddl.auto">create</prop>
                <prop key="hibernate.show_sql">true</prop>
            </props>
        </property>
    </bean>
    <bean id="transactionManager" class="org.springframework.orm.jpa.JpaTransactionManager" p:entityManagerFactory-ref="entityManagerFactory" />
    <tx:annotation-driven />
    
    <bean id="ds_master" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="ds_slave0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_slave0" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="ds_slave1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_slave1" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="randomStrategy" class="io.shardingsphere.example.spring.namespace.algorithm.masterslave.RandomMasterSlaveLoadBalanceAlgorithm" />
    <master-slave:data-source id="masterSlaveDataSource" master-data-source-name="ds_master" slave-data-source-names="ds_slave0, ds_slave1" strategy-ref="randomStrategy">
            <master-slave:props>
                <prop key="sql.show">${sql_show}</prop>
                <prop key="executor.size">10</prop>
                <prop key="foo">bar</prop>
            </master-slave:props>
    </master-slave:data-source>
</beans>
```

### Data Sharding + Read-Write Split

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:sharding="http://shardingsphere.io/schema/shardingsphere/sharding"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
                        http://www.springframework.org/schema/beans/spring-beans.xsd
                        http://www.springframework.org/schema/context
                        http://www.springframework.org/schema/context/spring-context.xsd
                        http://www.springframework.org/schema/tx
                        http://www.springframework.org/schema/tx/spring-tx.xsd
                        http://shardingsphere.io/schema/shardingsphere/sharding 
                        http://shardingsphere.io/schema/shardingsphere/sharding/sharding.xsd">
    <context:annotation-config />
    <context:component-scan base-package="io.shardingsphere.example.spring.namespace.jpa" />
    
    <bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="dataSource" ref="shardingDataSource" />
        <property name="jpaVendorAdapter">
            <bean class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter" p:database="MYSQL" />
        </property>
        <property name="packagesToScan" value="io.shardingsphere.example.spring.namespace.jpa.entity" />
        <property name="jpaProperties">
            <props>
                <prop key="hibernate.dialect">org.hibernate.dialect.MySQLDialect</prop>
                <prop key="hibernate.hbm2ddl.auto">create</prop>
                <prop key="hibernate.show_sql">true</prop>
            </props>
        </property>
    </bean>
    <bean id="transactionManager" class="org.springframework.orm.jpa.JpaTransactionManager" p:entityManagerFactory-ref="entityManagerFactory" />
    <tx:annotation-driven />
    
    <bean id="ds_master0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master0" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>

    <bean id="ds_master0_slave0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master0_slave0" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>

    <bean id="ds_master0_slave1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master0_slave1" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>

    <bean id="ds_master1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master1" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="ds_master1_slave0" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master1_slave0" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="ds_master1_slave1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/ds_master1_slave1" />
        <property name="username" value="root" />
        <property name="password" value="" />
    </bean>
    
    <bean id="randomStrategy" class="io.shardingsphere.example.spring.namespace.algorithm.masterslave.RandomMasterSlaveLoadBalanceAlgorithm" />
    
    <sharding:inline-strategy id="databaseStrategy" sharding-column="user_id" algorithm-expression="ds_ms$->{user_id % 2}" />
    <sharding:inline-strategy id="orderTableStrategy" sharding-column="order_id" algorithm-expression="t_order$->{order_id % 2}" />
    <sharding:inline-strategy id="orderItemTableStrategy" sharding-column="order_id" algorithm-expression="t_order_item$->{order_id % 2}" />
    
    <sharding:key-generator id="orderKeyGenerator" type="SNOWFLAKE" column="order_id" />
    <sharding:key-generator id="itemKeyGenerator" type="SNOWFLAKE" column="order_item_id" />
    
    <sharding:data-source id="shardingDataSource">
        <sharding:sharding-rule data-source-names="ds_master0,ds_master0_slave0,ds_master0_slave1,ds_master1,ds_master1_slave0,ds_master1_slave1">
            <sharding:master-slave-rules>
                <sharding:master-slave-rule id="ds_ms0" master-data-source-name="ds_master0" slave-data-source-names="ds_master0_slave0, ds_master0_slave1" strategy-ref="randomStrategy" />
                <sharding:master-slave-rule id="ds_ms1" master-data-source-name="ds_master1" slave-data-source-names="ds_master1_slave0, ds_master1_slave1" strategy-ref="randomStrategy" />
            </sharding:master-slave-rules>
            <sharding:table-rules>
                <sharding:table-rule logic-table="t_order" actual-data-nodes="ds_ms$->{0..1}.t_order$->{0..1}" database-strategy-ref="databaseStrategy" table-strategy-ref="orderTableStrategy" key-generator-ref="orderKeyGenerator" />
                <sharding:table-rule logic-table="t_order_item" actual-data-nodes="ds_ms$->{0..1}.t_order_item$->{0..1}" database-strategy-ref="databaseStrategy" table-strategy-ref="orderItemTableStrategy" key-generator-ref="itemKeyGenerator" />
            </sharding:table-rules>
            <sharding:binding-table-rules>
                <sharding:binding-table-rule logic-tables="t_order, t_order_item" />
            </sharding:binding-table-rules>
            <sharding:broadcast-table-rules>
                <sharding:broadcast-table-rule table="t_config" />
            </sharding:broadcast-table-rules>
        </sharding:sharding-rule>
    </sharding:data-source>
</beans>
```

### Data Orchestration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:orchestration="http://shardingsphere.io/schema/shardingsphere/orchestration"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans.xsd
                           http://shardingsphere.io/schema/shardingsphere/orchestration
                           http://shardingsphere.io/schema/shardingsphere/orchestration/orchestration.xsd">
    <orchestration:registry-center id="regCenter" server-lists="localhost:2181" namespace="orchestration-spring-namespace-demo" operation-timeout-milliseconds="1000" max-retries="3" />
</beans>
```

## Configuration Item Explanation

### Sharding

Namespace: <http://shardingsphere.io/schema/shardingsphere/sharding/sharding.xsd>

#### <sharding:data-source />

| *Name*         | *Type*   | *Explanation*                      |
| -------------- | -------- | ---------------------------------- |
| id             | Property | Spring Bean Id                     |
| sharding-rule  | Tag      | Data sharding configuration rules  |
| config-map (?) | Tag      | Users' self-defined configurations |
| props (?)      | Tag      | Property configurations            |

#### <sharding:sharding-rule />

| *Name*                            | *Type*   | *Explanation*                                                |
| --------------------------------- | -------- | ------------------------------------------------------------ |
| data-source-names                 | Property | Data source Bean list with comma separating multiple Beans   |
| table-rules                       | Tag      | Configuration objects of table sharding rules                |
| binding-table-rules (?)           | Tag      | Binding table rule list                                      |
| broadcast-table-rules (?)         | Tag      | Broadcast table rule list                                    |
| default-data-source-name (?)      | Property | Tables without sharding rules will be located through default data source |
| default-database-strategy-ref (?) | Property | Default database sharding strategy, which corresponds to strategy id in <sharding:xxx-strategy>; default means the database is not split |
| default-table-strategy-ref (?)    | Property | Default table sharding strategy, which corresponds to strategy id in <sharding:xxx-strategy>; default means the database is not split |
| default-key-generator-ref (?)     | Property | Default auto-increment generator reference, using `org.apache.shardingsphere.core.keygen.generator.impl.SnowflakeKeyGenerator`  in default |

#### <sharding:table-rules />

| *Name*         | *Type* | *Explanation*                                 |
| -------------- | ------ | --------------------------------------------- |
| table-rule (+) | Tag    | Configuration objects of table sharding rules |

#### <sharding:table-rule />

| *Name*                    | *Type*   | *Explanation*                                                |
| ------------------------- | -------- | ------------------------------------------------------------ |
| logic-table               | Property | Logic table name                                             |
| actual-data-nodes (?)     | Property | It is consisted of data source name + table name and separated by decimal points; multiple tables are separated by commas and support inline expressions; default means using existing data sources and logic table names to generate data nodes; it can be applied in broadcast tables (each database needs a same table for relevance query, dictionary table mostly) or the situation with sharding database but without sharding table (table structures of all the databases are consistent) |
| database-strategy-ref (?) | Property | Database sharding strategy, which corresponds to strategy id in <sharding:xxx-strategy>;  default means using <sharding:sharding-rule/> to configure default database sharding strategy |
| table-strategy-ref (?)    | Property | Table sharding strategy, which corresponds to strategy id in <sharding:xxx-strategy>; default means using <sharding:sharding-rule/> to configure default table sharding strategy |
| key-generator-ref (?)     | Property | Auto-increment generator reference; default means using default auto-increment generator |
| logic-index (?)           | Property | Logic index name; for table-sharding DROP INDEX XXX in Oracle/PostgreSQL, logic index name needs to be configured to locate actual sharding tables of the executing SQL |

#### <sharding:binding-table-rules />

| *Name*                 | *Type* | *Explanation*       |
| ---------------------- | ------ | ------------------- |
| binding-table-rule (+) | Tag    | Binding table rules |

#### <sharding:binding-table-rule />

| *Name*       | *Type*   | *Explanation*                                                |
| ------------ | -------- | ------------------------------------------------------------ |
| logic-tables | Property | Logic table name bound with rules; multiple tables are separated by commas |

#### <sharding:broadcast-table-rules />

| *Name*                   | *Type* | *Explanation*         |
| ------------------------ | ------ | --------------------- |
| broadcast-table-rule (+) | Tag    | Broadcast table rules |

#### <sharding:broadcast-table-rule />

| *Name* | *Type*   | *Explanation*                |
| ------ | -------- | ---------------------------- |
| table  | Property | Rule name of broadcast table |

#### <sharding:standard-strategy />

| *Name*                  | *Type*   | *Explanation*                                                |
| ----------------------- | -------- | ------------------------------------------------------------ |
| id                      | Property | Spring Bean id                                               |
| sharding-column         | Property | Sharding column name                                         |
| precise-algorithm-ref   | Property | Precise algorithm reference, applied in `=` and `IN`; the class needs to implement `PreciseShardingAlgorithm` interface |
| range-algorithm-ref (?) | Property | Range algorithm reference, applied in `BETWEEN`; the class needs to implement `RangeShardingAlgorithm` interface |

#### <sharding:complex-strategy />

| *Name*           | *Type*   | *Explanation*                                                |
| ---------------- | -------- | ------------------------------------------------------------ |
| id               | Property | Spring Bean id                                               |
| sharding-columns | Property | Sharding column name; multiple columns are separated by commas |
| algorithm-ref    | Property | Complex sharding algorithm reference; the class needs to implement `ComplexKeysShardingAlgorithm` interface |

#### <sharding:inline-strategy />

| *Name*               | *Type*   | *Explanation*                                                |
| -------------------- | -------- | ------------------------------------------------------------ |
| id                   | Property | Spring Bean id                                               |
| sharding-column      | Property | Sharding column name                                         |
| algorithm-expression | Property | Sharding algorithm inline expression, which needs to conform to groovy statements |

#### <sharding:hint-database-strategy />

| *Name*        | *Type*   | *Explanation*                                                |
| ------------- | -------- | ------------------------------------------------------------ |
| id            | Property | Spring Bean id                                               |
| algorithm-ref | Property | Hint sharding algorithm; the class needs to implement `HintShardingAlgorithm` interface |

#### <sharding:none-strategy />

| *Name* | *Type*   | *Explanation*  |
| ------ | -------- | -------------- |
| id     | Property | Spring Bean Id |

#### <sharding:key-generator />

| *Name*    | *Type*   | *Explanation*                                                |
| --------- | -------- | ------------------------------------------------------------ |
| column    | Property | Auto-increment column name                                   |
| type      | Property | Auto-increment key generator `Type`; self-defined generator or internal Type generator (SNOWFLAKE or UUID) can both be selected |
| props-ref | Property | Property configuration, such as worker.id and max.tolerate.time.difference.milliseconds in SNOWFLAKE algorithm |

#### <sharding:props />

| *Name*                             | *Type*   | *Explanation*                                                |
| ---------------------------------- | -------- | ------------------------------------------------------------ |
| sql.show (?)                       | Property | Show SQL or not; default value: false                        |
| executor.size (?)                  | Property | Executing thread number; default value: CPU core number      |
| max.connections.size.per.query (?) | Property | The maximum connection number that each physical database allocates to each query; default value: 1 |
| check.table.metadata.enabled (?)   | Property | Whether to check meta-data consistency of sharding table when it initializes; default value: false |

#### <sharding:config-map />

### Read-Write Split

Namespace: <http://shardingsphere.io/schema/shardingsphere/masterslave/master-slave.xsd>

#### <master-slave:data-source />

| *Name*                  | *Type*   | *Explanation*                                                |
| ----------------------- | -------- | ------------------------------------------------------------ |
| id                      | Property | Spring Bean id                                               |
| master-data-source-name | Property | Bean id of data source in master database                    |
| slave-data-source-names | Property | Bean id list of data source in slave database; multiple Beans are separated by commas |
| strategy-ref (?)        | Property | Slave database load balance algorithm reference; the class needs to implement `MasterSlaveLoadBalanceAlgorithm` interface |
| strategy-type (?)       | Property | Load balance algorithm type of slave database; optional value: ROUND_ROBIN and RANDOM; if there is `load-balance-algorithm-class-name`, the configuration can be omitted |
| config-map (?)          | Tag      | Users' self-defined configurations                           |
| props (?)               | Tag      | Property configurations                                      |

#### <master-slave:config-map />

#### <master-slave:props />

| *Name*                             | *Type*   | *Explanation*                                                |
| ---------------------------------- | -------- | ------------------------------------------------------------ |
| sql.show (?)                       | Property | Show SQL or not; default value: false                        |
| executor.size (?)                  | Property | Executing thread number; default value: CPU core number      |
| max.connections.size.per.query (?) | Property | The maximum connection number that each physical database allocates to each query; default value: 1 |
| check.table.metadata.enabled (?)   | Property | Whether to check meta-data consistency of sharding table when it initializes; default value: false |

### Data Sharding + Data Orchestration

Namespace: <http://shardingsphere.io/schema/shardingsphere/orchestration/orchestration.xsd>

#### <orchestration:sharding-data-source />

| *Name*              | *Type*   | *Explanation*                                                |
| ------------------- | -------- | ------------------------------------------------------------ |
| id                  | Property | ID                                                           |
| data-source-ref (?) | Property | Orchestrated database id                                     |
| registry-center-ref | Property | Registry center id                                           |
| overwrite           | Property | Whether to overwrite local configurations with registry center configurations; if it can, each initialization should refer to local configurations; default means not to overwrite |

### Read-Write Split + Data Orchestration

Namespace: <http://shardingsphere.io/schema/shardingsphere/orchestration/orchestration.xsd>

#### <orchestration:master-slave-data-source />

| *Name*              | *Type*   | *Explanation*                                                |
| ------------------- | -------- | ------------------------------------------------------------ |
| id                  | Property | ID                                                           |
| data-source-ref (?) | Property | Orchestrated database id                                     |
| registry-center-ref | Property | Registry center id                                           |
| overwrite           | Property | Whether to overwrite local configurations with registry center configurations; if it can, each initialization should refer to local configurations; default means not to overwrite |

### Data Orchestration Registry Center

Namespace: <http://shardingsphere.io/schema/shardingsphere/orchestration/orchestration.xsd>

#### <orchestration:registry-center />

| *Name*                             | *Type*   | *Explanation*                                                |
| ---------------------------------- | -------- | ------------------------------------------------------------ |
| id                                 | Property | Spring Bean id in registry center                            |
| server-lists                       | Property | The list of servers that connect to registry center, including IP and port number; use commas to separate addresses, such as: host1:2181,host2:2181 |
| namespace (?)                      | Property | Registry center namespace                                    |
| digest (?)                         | Property | The token that connects to the registry center; default means there is no need for authentication |
| operation-timeout-milliseconds (?) | Property | The millisecond number for operation timeout; default value: 500 milliseconds |
| max-retries (?)                    | Property | Maximum retry time after failing; default value: 3 times     |
| retry-interval-milliseconds (?)    | Property | Interval time to retry; default value: 500 milliseconds      |
| time-to-live-seconds (?)           | Property | Living time of temporary nodes; default value: 60 seconds    |