+++
toc = true
title = "XA事务"
weight = 1
+++


### 1. 添加Pom依赖

在你的项目中添加sharding-transaction-2pc-xa依赖，XA事务管理器会以SPI的方式被Sharding-JDBC所加载。

```xml
<dependency>
    <groupId>io.shardingsphere</groupId>
    <artifactId>sharding-transaction-2pc-xa</artifactId>
    <version>${latest.release.version}</version>
</dependency>
```

注意: 请将`${latest.release.version}`更改为实际的版本号。

### 2. 连接池配置

Sharding-Sphere支持将普通的数据库连接池，转换为支持XA事务的连接池。如果你所使用的连接池为HikariCP, Druid，DBCP2，则无需额外的配置。

其它连接池需要用户实现DataSourceMapConverter SPI接口进行扩展，可以参考io.shardingsphere.transaction.xa.convert.swap.HikariParameterSwapper的实现。若Sharding-Sphere无法找到合适的swapper，则会按默认的配置创建XA事务连接池。默认的属性如下：

|  *DataSourceParameter属性*       | *默认值* |
| ---------------------------------|---------------------|
| connectionTimeout                | `30 * 1000` millis  |
| idleTimeout                      | `60 * 1000` millis  |
| maintenanceInterval              | `30 * 1000` millis  |
| maxLifetime                      | `0`                 |
| maximumPoolSize                  | `50`                |
| minimumPoolSize                  | `1`                 |

### 3. 事务切换

Sharding-Sphere的事务类型存放在TransactionTypeHolder的threadLocal变量中，因此在ShardingConnection创建前修改此线程变量的值，可以达到自由切换分布式事务类型的效果。注意：ShardingConnection创建后，事务类型将不能进行修改。

* API切换方式
```java
TransactionTypeHolder.set(TransactionType.XA);
```
* @ShardingTransactional切换方式

    1.添加sharding-transaction-spring依赖包
    ```xml
      <dependency>
          <groupId>io.shardingsphere</groupId>
          <artifactId>sharding-transaction-spring </artifactId>
          <version>${latest.release.version}</version>
      </dependency>
    ```
    2.然后在需要事务支出的方法或类中加上此注解即可，例如：`@ShardingTransactional(type=TransactionType.XA)`
    

### 4. Atomikos参数配置(可选项)
SS 默认的XA事务管理器为Atomikos，如果你想定制化配置项，可以在你项目的classpath中添加jta.properties, 具体的配置规则请参考Atomikos官方 。
[jta.properties配置](https://www.atomikos.com/Documentation/JtaProperties)


### 5. JDBC完整Example
[SpringBootStarterTransactionExample](https://github.com/sharding-sphere/sharding-sphere-example/blob/dev/sharding-jdbc-example/spring-boot-nodep-example/spring-boot-nodep-mybatis-example/src/main/java/io/shardingsphere/example/spring/boot/mybatis/nodep/SpringBootStarterTransactionExample.java)