+++
toc = true
title = "Java Configuration"
weight = 1

+++

## Configuration Instance

### Data Sharding

```java
     DataSource getShardingDataSource() throws SQLException {
         ShardingRuleConfiguration shardingRuleConfig = new ShardingRuleConfiguration();
         shardingRuleConfig.getTableRuleConfigs().add(getOrderTableRuleConfiguration());
         shardingRuleConfig.getTableRuleConfigs().add(getOrderItemTableRuleConfiguration());
         shardingRuleConfig.getBindingTableGroups().add("t_order, t_order_item");
         shardingRuleConfig.getBroadcastTables().add("t_config");
         shardingRuleConfig.setDefaultDatabaseShardingStrategyConfig(new InlineShardingStrategyConfiguration("user_id", "ds${user_id % 2}"));
         shardingRuleConfig.setDefaultTableShardingStrategyConfig(new StandardShardingStrategyConfiguration("order_id", new ModuloShardingTableAlgorithm()));
         return ShardingDataSourceFactory.createDataSource(createDataSourceMap(), shardingRuleConfig);
     }
     
     TableRuleConfiguration getOrderTableRuleConfiguration() {
         TableRuleConfiguration result = new TableRuleConfiguration();
         result.setLogicTable("t_order");
         result.setActualDataNodes("ds${0..1}.t_order${0..1}");
         result.setKeyGeneratorColumnName("order_id");
         return result;
     }
     
     TableRuleConfiguration getOrderItemTableRuleConfiguration() {
         TableRuleConfiguration result = new TableRuleConfiguration();
         result.setLogicTable("t_order_item");
         result.setActualDataNodes("ds${0..1}.t_order_item${0..1}");
         return result;
     }
     
     Map<String, DataSource> createDataSourceMap() {
         Map<String, DataSource> result = new HashMap<>();
         result.put("ds0", DataSourceUtil.createDataSource("ds0"));
         result.put("ds1", DataSourceUtil.createDataSource("ds1"));
         return result;
     }
```

### Read-Write Split

```java
     DataSource getMasterSlaveDataSource() throws SQLException {
         MasterSlaveRuleConfiguration masterSlaveRuleConfig = new MasterSlaveRuleConfiguration();
         masterSlaveRuleConfig.setName("ds_master_slave");
         masterSlaveRuleConfig.setMasterDataSourceName("ds_master");
         masterSlaveRuleConfig.setSlaveDataSourceNames(Arrays.asList("ds_slave0", "ds_slave1"));
         return MasterSlaveDataSourceFactory.createDataSource(createDataSourceMap(), masterSlaveRuleConfig, new LinkedHashMap<String, Object>(), new Properties());
     }
     
     Map<String, DataSource> createDataSourceMap() {
         Map<String, DataSource> result = new HashMap<>();
         result.put("ds_master", DataSourceUtil.createDataSource("ds_master"));
         result.put("ds_slave0", DataSourceUtil.createDataSource("ds_slave0"));
         result.put("ds_slave1", DataSourceUtil.createDataSource("ds_slave1"));
         return result;
     }
```

### Data Sharding + Read-Write Split

```java
    DataSource getDataSource() throws SQLException {
        ShardingRuleConfiguration shardingRuleConfig = new ShardingRuleConfiguration();
        shardingRuleConfig.getTableRuleConfigs().add(getOrderTableRuleConfiguration());
        shardingRuleConfig.getTableRuleConfigs().add(getOrderItemTableRuleConfiguration());
        shardingRuleConfig.getBindingTableGroups().add("t_order, t_order_item");
        shardingRuleConfig.getBroadcastTables().add("t_config");
        shardingRuleConfig.setDefaultDatabaseShardingStrategyConfig(new StandardShardingStrategyConfiguration("user_id", new ModuloShardingDatabaseAlgorithm()));
        shardingRuleConfig.setDefaultTableShardingStrategyConfig(new StandardShardingStrategyConfiguration("order_id", new ModuloShardingTableAlgorithm()));
        shardingRuleConfig.setMasterSlaveRuleConfigs(getMasterSlaveRuleConfigurations());
        return ShardingDataSourceFactory.createDataSource(createDataSourceMap(), shardingRuleConfig, new HashMap<String, Object>(), new Properties());
    }
    
    TableRuleConfiguration getOrderTableRuleConfiguration() {
        TableRuleConfiguration result = new TableRuleConfiguration();
        result.setLogicTable("t_order");
        result.setActualDataNodes("ds_${0..1}.t_order_${[0, 1]}");
        result.setKeyGeneratorColumnName("order_id");
        return result;
    }
    
    TableRuleConfiguration getOrderItemTableRuleConfiguration() {
        TableRuleConfiguration result = new TableRuleConfiguration();
        result.setLogicTable("t_order_item");
        result.setActualDataNodes("ds_${0..1}.t_order_item_${[0, 1]}");
        return result;
    }
    
    List<MasterSlaveRuleConfiguration> getMasterSlaveRuleConfigurations() {
        MasterSlaveRuleConfiguration masterSlaveRuleConfig1 = new MasterSlaveRuleConfiguration("ds_0", "demo_ds_master_0", Arrays.asList("demo_ds_master_0_slave_0", "demo_ds_master_0_slave_1"));
        MasterSlaveRuleConfiguration masterSlaveRuleConfig2 = new MasterSlaveRuleConfiguration("ds_1", "demo_ds_master_1", Arrays.asList("demo_ds_master_1_slave_0", "demo_ds_master_1_slave_1"));
        return Lists.newArrayList(masterSlaveRuleConfig1, masterSlaveRuleConfig2);
    }
    
    Map<String, DataSource> createDataSourceMap() {
        final Map<String, DataSource> result = new HashMap<>();
        result.put("demo_ds_master_0", DataSourceUtil.createDataSource("demo_ds_master_0"));
        result.put("demo_ds_master_0_slave_0", DataSourceUtil.createDataSource("demo_ds_master_0_slave_0"));
        result.put("demo_ds_master_0_slave_1", DataSourceUtil.createDataSource("demo_ds_master_0_slave_1"));
        result.put("demo_ds_master_1", DataSourceUtil.createDataSource("demo_ds_master_1"));
        result.put("demo_ds_master_1_slave_0", DataSourceUtil.createDataSource("demo_ds_master_1_slave_0"));
        result.put("demo_ds_master_1_slave_1", DataSourceUtil.createDataSource("demo_ds_master_1_slave_1"));
        return result;
    }
```

### Data Orchestration

```java
    DataSource getDataSource() throws SQLException {
        return OrchestrationShardingDataSourceFactory.createDataSource(
                createDataSourceMap(), createShardingRuleConfig(), new HashMap<String, Object>(), new Properties(), 
                new OrchestrationConfiguration("orchestration-sharding-data-source", getRegistryCenterConfiguration(), false));
    }
    
    private RegistryCenterConfiguration getRegistryCenterConfiguration() {
        RegistryCenterConfiguration regConfig = new RegistryCenterConfiguration();
        regConfig.setServerLists("localhost:2181");
        regConfig.setNamespace("sharding-sphere-orchestration");
        return regConfig;
    }
```

## Configuration Item Explanation

### Data Sharding

#### ShardingDataSourceFactory

| *Name*             | *Data Type*               | *Explanation*                    |
| ------------------ | ------------------------- | -------------------------------- |
| dataSourceMap      | Map<String, DataSource>   | Data source configuration        |
| shardingRuleConfig | ShardingRuleConfiguration | Data sharding configuration rule |
| configMap (?)      | Map<String, Object>       | User defined configuration       |
| props (?)          | Properties                | Property configuration           |

#### ShardingRuleConfiguration

| *Name*                                    | *Data Type*                              | *Explanation*                                                |
| ----------------------------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| tableRuleConfigs                          | Collection<TableRuleConfiguration>       | Sharding rule list                                           |
| bindingTableGroups (?)                    | Collection<String>                       | Binding table rule list                                      |
| broadcastTables (?)                       | Collection<String>                       | Broadcast table rule list                                    |
| defaultDataSourceName (?)                 | String                                   | Tables not configured with sharding rules will locate according to default data sources |
| defaultDatabaseShardingStrategyConfig (?) | ShardingStrategyConfiguration            | Default database sharding strategy                           |
| defaultTableShardingStrategyConfig (?)    | ShardingStrategyConfiguration            | Default table sharding strategy                              |
| defaultKeyGenerator (?)                   | KeyGenerator                             | Default key generator, default value `io.shardingsphere.core.keygen.DefaultKeyGenerator` |
| masterSlaveRuleConfigs (?)                | Collection<MasterSlaveRuleConfiguration> | Read-write split rules, default indicates not using read-write split |

#### TableRuleConfiguration

| *Name*                             | *Data Type*                   | *Explanation*                                                |
| ---------------------------------- | ----------------------------- | ------------------------------------------------------------ |
| logicTable                         | String                        | Logic table name                                             |
| actualDataNodes (?)                | String                        | Consist of data source name + table name; be separated by commas; support inline expressions. Default means generating data nodes with data sources and logic table names. Be used in broadcast tables (each database needs a same table in relevance query, mostly dictionary table) or sharding databases with identically structured tables |
| databaseShardingStrategyConfig (?) | ShardingStrategyConfiguration | Database sharding strategy; Default indicates using default database sharding strategy |
| tableShardingStrategyConfig (?)    | ShardingStrategyConfiguration | Table sharding strategy; default indicates using default table sharding strategy |
| logicIndex (?)                     | String                        | Logic index name; for `DROP INDEX XXX` statements in Oracle/PostgreSQL databases with sharding tables, configure logic index name to locate actual tables of SQL implemented |
| keyGeneratorColumnName (?)         | String                        | Auto-increment column name; default indicates not using auto-increment key generator |
| keyGenerator (?)                   | KeyGenerator                  | Auto-increment column value generator; default indicates using default auto-increment key generator |

#### StandardShardingStrategyConfiguration

The implementation class of `ShardingStrategyConfiguration`, used in standard sharding situation with single sharding key.

| *Name*                     | *Data Type*              | *Explanation*                               |
| -------------------------- | ------------------------ | ------------------------------------------- |
| shardingColumn             | String                   | Sharding column name                        |
| preciseShardingAlgorithm   | PreciseShardingAlgorithm | Precise sharding algorithm used in = and IN |
| rangeShardingAlgorithm (?) | RangeShardingAlgorithm   | Range sharding algorithm used in BETWEEN    |

#### ComplexShardingStrategyConfiguration

The implementation class of `ShardingStrategyConfiguration`, used in complex sharding situations with  multiple sharding keys.

| *Name*            | *Data Type*                  | *Explanation*                             |
| ----------------- | ---------------------------- | ----------------------------------------- |
| shardingColumns   | String                       | Sharding column name, separated by commas |
| shardingAlgorithm | ComplexKeysShardingAlgorithm | Complex sharding algorithm                |

#### InlineShardingStrategyConfiguration

The implementation class of `ShardingStrategyConfiguration`, used in sharding strategy of inline expression.

| *Name*              | *Data Type* | *Explanation*                                                |
| ------------------- | ----------- | ------------------------------------------------------------ |
| shardingColumn      | String      | Sharding column name                                         |
| algorithmExpression | String      | Inline expression of sharding strategies, should conform to groovy syntax; refer to [inline expression](http://shardingsphere.io/document/current/cn/features/sharding/other-features/inline-expression) for more details |

#### HintShardingStrategyConfiguration

The implementation class of `ShardingStrategyConfiguration`,  used to configure hint sharding strategies.

| *Name*            | *Data Type*           | *Explanation*          |
| ----------------- | --------------------- | ---------------------- |
| shardingAlgorithm | HintShardingAlgorithm | Hint sharding strategy |

#### NoneShardingStrategyConfiguration

The implementation class of `ShardingStrategyConfiguration`, used to configure none-sharding strategies.

#### PropertiesConstant

Property configuration items, can be of the following properties.

| *Name*                             | *Data Type* | *Explanation*                                                |
| ---------------------------------- | ----------- | ------------------------------------------------------------ |
| sql.show (?)                       | boolean     | Show SQL or not, default value: false                        |
| executor.size (?)                  | int         | Work thread number, default value: CPU core number           |
| max.connections.size.per.query (?) | int         | The maximum connection number allocated by each query of each physical database. default value: 1 |
| check.table.metadata.enabled (?)   | boolean     | Check meta-data consistency or not in initialization, default value: false |

#### configMap

User defined configurations.

### Read-Write Split

#### MasterSlaveDataSourceFactory

| *Name*                | *Data Type*                  | *Explanation*                       |
| --------------------- | ---------------------------- | ----------------------------------- |
| dataSourceMap         | Map<String, DataSource>      | Mapping of data source and its name |
| masterSlaveRuleConfig | MasterSlaveRuleConfiguration | Read-write split rules              |
| configMap (?)         | Map<String, Object>          | User defined configurations         |
| props (?)             | Properties                   | Property configurations             |

#### MasterSlaveRuleConfiguration

Configuration objects of read-write split rules.

| *Name*                   | *Data Type*                     | *Explanation*                         |
| ------------------------ | ------------------------------- | ------------------------------------- |
| name                     | String                          | Read-write split data source name     |
| masterDataSourceName     | String                          | Master database source name           |
| slaveDataSourceNames     | Collection<String>              | Slave database source name list       |
| loadBalanceAlgorithm (?) | MasterSlaveLoadBalanceAlgorithm | Slave database load balance algorithm |

#### configMap

User defined configurations.

#### PropertiesConstant

Property configuration items, can be of the following properties.

| *Name*                             | *Data Type* | *Explanation*                                                |
| ---------------------------------- | ----------- | ------------------------------------------------------------ |
| sql.show (?)                       | boolean     | Print SQL parse and rewrite log or not, default value: false |
| executor.size (?)                  | int         | Be used in work thread number implemented by SQL; no limits if it is 0. default value: 0 |
| max.connections.size.per.query (?) | int         | The maximum connection number allocated by each query of each physical database, default value: 1 |
| check.table.metadata.enabled (?)   | boolean     | Check meta-data consistency or not in initialization, default value: false |

### Data Orchestration

#### OrchestrationShardingDataSourceFactory

Data sharding + `OrchestrationShardingDataSourceFactory`

| *Name*              | *Data Type*                | *Explanation*                          |
| ------------------- | -------------------------- | -------------------------------------- |
| dataSourceMap       | Map<String, DataSource>    | Same as `ShardingDataSourceFactory`    |
| shardingRuleConfig  | ShardingRuleConfiguration  | Same as `ShardingDataSourceFactory`    |
| configMap (?)       | Map<String, Object>        | Same as `ShardingDataSourceFactory`    |
| props (?)           | Properties                 | Same as `ShardingDataSourceFactory`    |
| orchestrationConfig | OrchestrationConfiguration | Data orchestration rule configurations |

#### OrchestrationMasterSlaveDataSourceFactory

Read-write split + `OrchestrationShardingDataSourceFactory`

| *Name*                | *Data Type*                  | *Explanation*                          |
| --------------------- | ---------------------------- | -------------------------------------- |
| dataSourceMap         | Map<String, DataSource>      | Same as `MasterSlaveDataSourceFactory` |
| masterSlaveRuleConfig | MasterSlaveRuleConfiguration | Same as `MasterSlaveDataSourceFactory` |
| configMap (?)         | Map<String, Object>          | Same as `MasterSlaveDataSourceFactory` |
| props (?)             | Properties                   | Same as `ShardingDataSourceFactory`    |
| orchestrationConfig   | OrchestrationConfiguration   | Data orchestration rule configurations |

#### OrchestrationConfiguration

Data orchestration rule configuration objects.

| *Name*          | *Data Type*                 | *Explanation*                                                |
| --------------- | --------------------------- | ------------------------------------------------------------ |
| name            | String                      | Data orchestration example name                              |
| overwrite       | boolean                     | Local configurations overwrite registry center configurations or not; if they overwrite, each start takes reference of local configurations |
| regCenterConfig | RegistryCenterConfiguration | Registry center configurations                               |

#### RegistryCenterConfiguration

Be used to configure registry center.

| *Name*                           | *Data Type* | *Explanation*                                                |
| -------------------------------- | ----------- | ------------------------------------------------------------ |
| serverLists                      | String      | Connect to server lists in registry center, including IP address and port number; addresses are separated by commas, such as `host1:2181,host2:2181` |
| namespace (?)                    | String      | Name space of registry center                                |
| digest (?)                       | String      | Connect to authority tokens in registry center; default indicates no need for authority confirmation |
| operationTimeoutMilliseconds (?) | int         | The operation timeout millisecond number, default to be 500 milliseconds |
| maxRetries (?)                   | int         | The maximum retry count, default to be 3 times               |
| retryIntervalMilliseconds (?)    | int         | The retry interval millisecond number, default to be 500 milliseconds |
| timeToLiveSeconds (?)            | int         | The living time for temporary nodes, default to be 60 seconds |