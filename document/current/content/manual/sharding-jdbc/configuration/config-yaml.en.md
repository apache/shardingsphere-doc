+++
toc = true
title = "Yaml Configuration"
weight = 2
+++

## Configuration Instance

### Data Sharding

```yaml
dataSources:
  ds0: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds0
    username: root
    password: 
  ds1: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds1
    username: root
    password: 

shardingRule:  
  tables:
    t_order: 
      actualDataNodes: ds${0..1}.t_order${0..1}
      tableStrategy: 
        inline:
          shardingColumn: order_id
          algorithmExpression: t_order${order_id % 2}
      keyGeneratorColumnName: order_id
    t_order_item:
      actualDataNodes: ds${0..1}.t_order_item${0..1}
      tableStrategy:
        inline:
          shardingColumn: order_id
          algorithmExpression: t_order_item${order_id % 2}  
  bindingTables:
    - t_order,t_order_item
  broadcastTables:
    - t_config
  
  defaultDataSourceName: ds0
  defaultDatabaseStrategy:
    inline:
      shardingColumn: user_id
      algorithmExpression: ds${user_id % 2}
  defaultTableStrategy:
    none:
  defaultKeyGeneratorClassName: io.shardingsphere.core.keygen.DefaultKeyGenerator
  
props:
  sql.show: true
```

### Read-Write Split

```yaml
dataSources:
  ds_master: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds_master
    username: root
    password: 
  ds_slave0: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds_slave0
    username: root
    password: 
  ds_slave1: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds_slave1
    username: root
    password: 

masterSlaveRule:
  name: ds_ms
  masterDataSourceName: ds_master
  slaveDataSourceNames: 
    - ds_slave0
    - ds_slave1

props:
    sql.show: true
```

### Data Sharding + Read-Write Split

```yaml
dataSources:
  ds0: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds0
    username: root
    password: 
  ds0_slave0: !!org.apache.commons.dbcp.BasicDataSource
      driverClassName: com.mysql.jdbc.Driver
      url: jdbc:mysql://localhost:3306/ds0_slave0
      username: root
      password: 
  ds0_slave1: !!org.apache.commons.dbcp.BasicDataSource
      driverClassName: com.mysql.jdbc.Driver
      url: jdbc:mysql://localhost:3306/ds0_slave1
      username: root
      password: 
  ds1: !!org.apache.commons.dbcp.BasicDataSource
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ds1
    username: root
    password: 
  ds1_slave0: !!org.apache.commons.dbcp.BasicDataSource
        driverClassName: com.mysql.jdbc.Driver
        url: jdbc:mysql://localhost:3306/ds1_slave0
        username: root
        password: 
  ds1_slave1: !!org.apache.commons.dbcp.BasicDataSource
        driverClassName: com.mysql.jdbc.Driver
        url: jdbc:mysql://localhost:3306/ds1_slave1
        username: root
        password: 

shardingRule:  
  tables:
    t_order: 
      actualDataNodes: ms_ds${0..1}.t_order${0..1}
      tableStrategy: 
        inline:
          shardingColumn: order_id
          algorithmExpression: t_order${order_id % 2}
      keyGeneratorColumnName: order_id
    t_order_item:
      actualDataNodes: ms_ds${0..1}.t_order_item${0..1}
      tableStrategy:
        inline:
          shardingColumn: order_id
          algorithmExpression: t_order_item${order_id % 2}  
  bindingTables:
    - t_order,t_order_item
  broadcastTables:
    - t_config
  
  defaultDataSourceName: ds_0
  defaultDatabaseStrategy:
    inline:
      shardingColumn: user_id
      algorithmExpression: ms_ds${user_id % 2}
  defaultTableStrategy:
    none:
  defaultKeyGeneratorClassName: io.shardingsphere.core.keygen.DefaultKeyGenerator
  
  masterSlaveRules:
      ms_ds0:
        masterDataSourceName: ds0
        slaveDataSourceNames:
          - ds0_slave0
          - ds0_slave1
        loadBalanceAlgorithmType: ROUND_ROBIN
        configMap:
          master-slave-key0: master-slave-value0
      ms_ds1:
        masterDataSourceName: ds1
        slaveDataSourceNames: 
          - ds1_slave0
          - ds1_slave1
        loadBalanceAlgorithmType: ROUND_ROBIN
        configMap:
          master-slave-key1: master-slave-value1

props:
  sql.show: true
```

### Data Orchestration

```yaml
#Omit data sharding and read-write split configurations

orchestration:
  name: orchestration_ds
  overwrite: true
  registry:
    namespace: orchestration
    serverLists: localhost:2181
```

## Configuration Item Explanation

### config-xxx.yaml Data Sharding + Read-Write Split (revised according to the latest 3.1 version)

```yaml
#The following configurations are up till 3.1 version
#In configuration documents, schemaName and dataSources must be configurated; sharidngRule and masterSlaveRulemust must be configured at least one (to be noticed, except that server.yaml has defined Orchestration, there must be at least one config-xxxx document); other items are optional
schemaName: test #schema name, each document is a standalone schema; multiple schemas mean multiple yaml documents, named by config-xxxx.yaml; though there is no compulsive requirement, recommend to keep xxxx in name same as schemaName, easy to maintain

dataSources: #Configure data source list; must be valid jdbc configurations; currently only support MySQL and PostgreSQL; through other unpublic variables (which can be seen in codes and may change in the future), configure other databases to be compatible with JDBC, but there is not enough supporting tests, so there may be serious compatiability problems; configure at least one
  master_ds_0: #Data source name, can be legal strings; there is no mandatory requirements in current verification rules, as long as they are legal yaml strings; what's applied in sharding configurations must be meaningful signs (explained in sharding configurations); here are revealed legal configuration items, not including internal configuration parameters
    #The following parameters are compulsary
    url: jdbc:mysql://127.0.0.1:3306/demo_ds_slave_1?serverTimezone=UTC&useSSL=false #It requires legal jdbc connection strings here; not competiable with MySQL 8.x yet; it requires to upgrade MySQL JDBC to 5.1.46 or 47 version (not recommend to 8.x versions of JDBC, because many codes need to revise and many test cases cannot pass)
    username: root #MySQL user name
    password: password #MySQL users' clear text passwords
    #The following parameters are optional; instances are default configurations mainly used for connection pool control
    connectionTimeoutMilliseconds: 30000 #Connection timeout control
    idleTimeoutMilliseconds: 60000 #Idle timeout setting
    maxLifetimeMilliseconds: 0 #Maximum lifetime; 0 for no limit
    maxPoolSize: 50 #Maximum connection number in the pool
    minPoolSize: 1 #Minimum connection number in the pool
    maintenanceIntervalMilliseconds: 30000 #Interval time for connection maintenance, which is required by atomikos framework
  #The presumption for the following configurations: 3307 is the slave database of 3306, 3309 and 3310 are slave databases of 3308
  slave_ds_0:
    url: jdbc:mysql://127.0.0.1:3307/demo_ds_slave_1?serverTimezone=UTC&useSSL=false
    username: root
    password: password
  master_ds_1:
    url: jdbc:mysql://127.0.0.1:3308/demo_ds_slave_1?serverTimezone=UTC&useSSL=false
    username: root
    password: password
  slave_ds_1:
    url: jdbc:mysql://127.0.0.1:3309/demo_ds_slave_1?serverTimezone=UTC&useSSL=false
    username: root
    password: password
  slave_ds_1_slave2:
    url: jdbc:mysql://127.0.0.1:3310/demo_ds_slave_1?serverTimezone=UTC&useSSL=false
    username: root
    password: password
masterSlaveRule: #The rule configured here is equal to global read-write split configurations
  name: ds_rw #Name that requires legal strings, but if sharding configurations are involved on basis of read-write split, names should be meaningful; in addition, though there is no compulsary requirement, master-slave databases need to be configurated on actural related ones; if data sources are separate between master and slave, written data may not be read by read only session
  #If a session is written but not submitted (transaction is open), SharidngSphere will implement select in master database in the following routes, until the session is submitted
  masterDataSourceName: master_ds_0 #Data source name of the master database
  slaveDataSourceNames: #Data source list of the slave database; at least have one
    - slave_ds_0
  loadBalanceAlgorithmClassName: io.shardingsphere.api.algorithm.masterslave #The implementation class of MasterSlaveLoadBalanceAlgorithm; can be self-defined; default to provide two; configuration path: RandomMasterSlaveLoadBalanceAlgorithm (Random) and RoundRobinMasterSlaveLoadBalanceAlgorithm (Round Robin: times % slave database number) under io.shardingsphere.api.algorithm.masterslave
  loadBalanceAlgorithmType: #Slave database load balance algorithm type, optional value: ROUND_ROBIN, RANDOM; if there is loadBalanceAlgorithmClassName, the configuration can be neglected; default to be ROUND_ROBIN

shardingRule: #Sharding configuration
  #There are two kinds of configurations: one is the default configuration for all the tables under sharding rules; the other is the specific configuration for some certain sharding tables
  #First, default configurations
  masterSlaveRules: #shardingRule can also be configured in shardingRule, having effect on shards. Its content is consistent with overall masterSlaveRule, but with the syntax of:
    master_test_0:
      masterDataSourceName: master_ds_0
      slaveDataSourceNames:
        - slave_ds_0
    master_test_1:
      masterDataSourceName: master_ds_1
      slaveDataSourceNames:
        - slave_ds_1
        - slave_ds_1_slave2
  defaultDataSourceName: master_test_0 #The data source here can be the configuration item of dataSources or the configuration name of masterSlaveRules; masterSlaveRule configuration equals to read-write split configuration
  broadcastTables: #For the table list configured here, all the data change will not be processed by sharding, but will be sent to all data nodes. To be noticed, here is the list and each item is a table name
    - broad_1
    - broad_2
  bindingTables: #They are actually lists configured with sharding rules, which need to take effect. They are configured as yaml list, allowing to be divided by commas in one single item; what's configured must already be logic table
    - sharding_t1
    - sharding_t2,sharding_t3
  defaultDatabaseShardingStrategy: #It corresponds to ShardingStrategy interface type in codes, supporting five kinds of configurations, none, inline, hint, complex and standard, but only one out of five can be set as default configuration
  #Rule configurations can also be applied in table sharding configurations and are chosen among these algorithms
    none: #Not configured with any rule; SQL will be sent to all nodes to execute; this rule does not have any sub-program to configure
    inline: #Inline expression sharding
      shardingColumn: test_id #Sharding Column Name
      algorithmExpression: master_test_${test_id % 2} #According to delegated expressions, it needs to calculate the data resource that needs to be routed to, and can  only be legitimate groovy expressions. In example configurations, statements will be routed to master_test_0 and master_test_1 respectively with remainder being 0 and being 1
    hint: #Sharding based on marks
      shardingAlgorithm: #It needs to be the implementation of HintShardingAlgorithm interface; there is only OrderDatabaseHintShardingAlgorithm for test and no useable implementation in production environment in current codes
    complex: #Support multi-column shariding, no useable production implementation
      shardingColumns: #Columns divided by commas
      shardingAlgorithm: #ComplexKeysShardingAlgorithm interface implementation
    standard: #Single column sharidng algorithm, which needs to be used with preciseShardingAlgorithm and rangeShardingAlgorithm interface implementation; no useable production implementation for now
      shardingColumn: #Column name, single column is allowed
      preciseShardingAlgorithm: #preciseShardingAlgorithm interface implementation
      rangeShardingAlgorithm: #rangeShardingAlgorithm interface implementation
  defaultTableStrategy: #Refer to defaultDatabaseShardingStrategy for configurations; their difference is that the algorithmExpression result needs physical table names rather than data source names in inline algorithm configurations
  defaultKeyGenerator: #Default to be SNOWFLAKE algorithms without any configurations
    column: #The column name corresponds to auto-increment key
    type: #The auto-increment key type, which is  used to call innate primary keys; it has three available values: SNOWFLAKE (time stamp + worker id + auto-increment id), UUID (arbitrary UUID generated by java.util.UUID type) and LEAF; among them, Snowflake algorithm and UUID algorithm have been realized and LEAF have not for now (2018-01-14)
    className: #Other KeyGenerator types that are not innate; to be noticed, if it is set, type will not be set; otherwise, type configurations will cover class configurations
    props:
      #Indexes needed by customized algorithms, such as worker.id and max.tolerate.time.difference.milliseconds of SNOWFLAKE algorithms
  tables: #The main position of configuration table sharding
    sharding_t1:
      actualDataNodes: master_test_${0..1}.t_order${0..1} #The data source and physical name correspond to sharidng tables; they need to be processed by expressions and indicate tables actually exist in what data sources; the configuration example means there are totally 4 shards: master_test_0.t_order0, master_test_0.t_order1, master_test_1.t_order0 and master_test_1.t_order1
      #To be noticed, databaseStrategy must be routed to the only dataSource, and tableStrategy to the only physical table of it; otherwise, the mistake of one insert sentence in multiple physical tables can happen
      databaseStrategy: #Partial configurations will cover overall configurations; please refer to defaultDatabaseShardingStrategy
      tableStrategy: #Partial configurations will cover overall configurations; please refer to defaultTableStrategy
      keyGenerator: #Partial configurations will cover overall configurations; please refer to defaultKeyGenerator
      logicIndex: #In databases as Oracle and PG, index share name spaces with table, so if drop index statements have been received, corresponding physical table names will be determined according to that before execution
props:
  sql.show: #Whether to show SQL or not; default value: false
  acceptor.size: #The thread number of accept connection; default to be 2 times of cpu core
  executor.size: #Maximum executing thread number; default value: no limitation
  max.connections.size.per.query: #Maximum connection number that can be opened per query; default to be 1
  proxy.frontend.flush.threshold: #The service time of proxy; for each large query, it returns every a few packets
  check.table.metadata.enabled: #Whether to check metadata consistency of sharding table when it initializes; default value: false
  proxy.transaction.type: #Default LOCAL and proxy transaction model; permit three values: LOCAL,XA and BASE; LOCAL does not have distributed transactions; XA uses atomikos to implement distributed transactions; BASE has not been available for now
  proxy.opentracing.enabled: #Whether to enable opentracing or not
  proxy.backend.use.nio: #Whether to connect backend database through NIO mechanism of netty; default value: False; use epoll mechanism
  proxy.backend.max.connections: #If NIO rather than epoll is used, the maximum default value (not database connection restriction) of proxy backend connecting to each netty server is 8
  proxy.backend.connection.timeout.seconds: #If NIO rather than epoll is used, the default proxy backend connection time is 60s
  check.table.metadata.enabled: #Whether to check the consistency of actual metadata of sharding tables when it intializes; default to be False
configMap: #Users' self-defined configurations
  key1: value1
  key2: value2
  keyx: valuex
```

### Read-Write Split

```yaml
dataSources: #Omit data source configurations; keep it consistent with data sharding

masterSlaveRule:
  name: #Read-write split data source name
  masterDataSourceName: #Master data source name
  slaveDataSourceNames: #Slave data source name
    - <data_source_name1>
    - <data_source_name2>
    - <data_source_name_x>
  loadBalanceAlgorithmClassName: #Slave database load balance algorithm class name; the class should implement MasterSlaveLoadBalanceAlgorithm interface and provide parameter-free constructor
  loadBalanceAlgorithmType: #Slave database load balance algorithm type; optional value, ROUND_ROBIN and RANDOM, can be omitted if `loadBalanceAlgorithmClassName` exists
    
props: #Property configuration
  sql.show: #Show SQL or not; default value: false
  executor.size: #Executing thread number; default value: CPU core number
  check.table.metadata.enabled: # Whether to check table metadata consistency when it initializes; default value: false
  
configMap: #Users' self-defined configurations
  key1: value1
  key2: value2
  keyx: valuex
```

### Data Orchestration

```yaml
dataSources: #Omit data source configurations
shardingRule: #Omit sharding rule configurations
masterSlaveRule: #Omit read-write split rule configurations

orchestration:
  name: #Data orchestration instance name
  overwrite: #Whether to overwrite local configurations with registry center configurations; if it can, each initialization should refer to local configurations
  registry: #Registry center configuration
    serverLists: #The list of servers that connect to registry center, including IP and port number; use commas to seperate addresses, such as: host1:2181,host2:2181
    namespace: #Registry center namespace
    digest: #The token that connects to the registry center; default means there is no need for authentication
    operationTimeoutMilliseconds: #Default value: 500 milliseconds
    maxRetries: #Maximum retry time after failing; default value: 3 times
    retryIntervalMilliseconds: #Interval time to retry; default value: 500 milliseconds
    timeToLiveSeconds: #Living time of temporary nodes; default value: 60 seconds
```

## Yaml Syntax Explanation

`!!` means instantiation of that class

`-` means one or multiple can be included

`[]` means array, substitutable with minus 