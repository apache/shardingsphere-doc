+++
toc = true
title = "Data Masking"
weight = 6
+++

This chapter mainly introduces how to use the feather of Data Masking. On one hand User can use Data Masking and Sharding together, which will
create ShardingDataSource, On another hand, when user only adopt the feather of Data Masking, ShardingSphere will create EncryptDataSource.

## Not Use Spring

### Introduce Maven Dependency

```xml
<dependency>
    <groupId>org.apache.shardingsphere</groupId>
    <artifactId>sharding-jdbc-core</artifactId>
    <version>${sharding-sphere.version}</version>
</dependency>
```

### Rule Configuration Based on Java

```java
       // Configure actual data source
       BasicDataSource dataSource = new BasicDataSource();
       dataSource.setDriverClassName("com.mysql.jdbc.Driver");
       dataSource.setUrl("jdbc:mysql://127.0.0.1:3306/encrypt");
       dataSource.setUsername("root");
       dataSource.setPassword("");
       
       // Configure the encrypt rule
	   Properties properties = new Properties();
       properties.setProperty("aes.key.value", "123456");
       EncryptRuleConfiguration encryptRuleConfig = new EncryptRuleConfiguration();
       EncryptorRuleConfiguration aesEncryptorRuleConfiguration = new EncryptorRuleConfiguration("AES", "t_encrypt.pwd", properties);
       encryptRuleConfig.getEncryptorRuleConfigs().put("aes", aesEncryptorRuleConfiguration);

       // Get data source
       DataSource dataSource = EncryptDataSourceFactory.createDataSource(dataSource, encryptRuleConfig, new Properties());
```

### Rule Configuration Based on Yaml


```yaml
dataSource:  !!org.apache.commons.dbcp2.BasicDataSource
  driverClassName: com.mysql.jdbc.Driver
  jdbcUrl: jdbc:mysql://127.0.0.1:3306/encrypt?serverTimezone=UTC&useSSL=false
  username: root
  password:

encryptRule:
  encryptors:
    order_encryptor:
      type: aes
	  qualifiedColumns: t_encrypt.pwd
      props:
        aes.key.value: 123456
```

```java
    DataSource dataSource = YamlEncryptDataSourceFactory.createDataSource(yamlFile);
```

## Use Native JDBC

### Introduce Maven Dependency

```xml
<!-- for spring boot -->
<dependency>
    <groupId>org.apache.shardingsphere</groupId>
    <artifactId>sharding-jdbc-spring-boot-starter</artifactId>
    <version>${sharding-sphere.version}</version>
</dependency>

<!-- for spring namespace -->
<dependency>
    <groupId>org.apache.shardingsphere</groupId>
    <artifactId>sharding-jdbc-spring-namespace</artifactId>
    <version>${sharding-sphere.version}</version>
</dependency>
```

### Rule Configuration Based on Spring Boot

```properties
spring.shardingsphere.datasource.name=ds

spring.shardingsphere.datasource.ds.type=org.apache.commons.dbcp2.BasicDataSource
spring.shardingsphere.datasource.ds.driver-class-name=com.mysql.jdbc.Driver
spring.shardingsphere.datasource.ds.url=jdbc:mysql://127.0.0.1:3306/encrypt?serverTimezone=UTC&useSSL=false
spring.shardingsphere.datasource.ds.username=root
spring.shardingsphere.datasource.ds.password=
spring.shardingsphere.datasource.ds.max-total=100

spring.shardingsphere.encrypt.encryptors.encryptor_aes.type=aes
spring.shardingsphere.encrypt.encryptors.encryptor_aes.props.aes.key.value=123456
spring.shardingsphere.encrypt.encryptors.encryptor_aes.qualifiedColumns=t_encrypt.pwd

spring.shardingsphere.props.sql.show=true
spring.shardingsphere.props.query.with.cipher.comlum=true
```

#### Rule Configuration Based on Spring Boot + JNDI

If you plan to use Sharding-JDBC in Application Server(such as Tomcat) with `Spring boot + JNDI`, `spring.shardingsphere.datasource.${datasourceName}.jndiName` can be used as an alternative to series of configuration of datasource. 
For example:
```properties
spring.shardingsphere.datasource.name=ds

spring.shardingsphere.datasource.ds.jndi-name=java:comp/env/jdbc/ds

spring.shardingsphere.encrypt.encryptors.encryptor_aes.type=aes
spring.shardingsphere.encrypt.encryptors.encryptor_aes.props.aes.key.value=123456
spring.shardingsphere.encrypt.encryptors.encryptor_aes.qualifiedColumns=t_encrypt.pwd

spring.shardingsphere.props.sql.show=true
spring.shardingsphere.props.query.with.cipher.comlum=true
```

### Rule Configuration Based on Spring Name Space

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:encrypt="http://shardingsphere.apache.org/schema/shardingsphere/encrypt"
       xmlns:bean="http://www.springframework.org/schema/util"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
                        http://www.springframework.org/schema/beans/spring-beans.xsd
                        http://shardingsphere.apache.org/schema/shardingsphere/encrypt 
                        http://shardingsphere.apache.org/schema/shardingsphere/encrypt/encrypt.xsd 
                        http://www.springframework.org/schema/util 
                        http://www.springframework.org/schema/util/spring-util.xsd">
    <import resource="datasource/dataSource.xml" />
   
    <bean id="db" class="org.apache.commons.dbcp2.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://127.0.0.1:3306/encrypt?serverTimezone=UTC&useSSL=false" />
        <property name="username" value="root" />
        <property name="password" value="" />
        <property name="maxTotal" value="100" />
    </bean>
    
    <bean:properties id="props">
        <prop key="aes.key.value">123456</prop>
    </bean:properties>
    
    <encrypt:data-source id="encryptDataSource" data-source-name="db" >
        <sharding:encrypt-rules>
        	<encrypt:encryptor-rule id="encryptor_aes" type="AES" qualified-columns="t_encrypt.pwd" props-ref="props"/>
            <encrypt:encryptor-rule id="encryptor_md5" type="MD5" qualified-columns="t_encrypt.user_id"/>
        </sharding:encrypt-rules> 
        <encrypt:props>
            <prop key="sql.show">${sql_show}</prop>
            <prop key="query.with.cipher.column">true</prop>
        </encrypt:props>
    </encrypt:data-source>
</beans>
```

### Use DataSource in Spring

```java
@Resource
private DataSource dataSource;
```