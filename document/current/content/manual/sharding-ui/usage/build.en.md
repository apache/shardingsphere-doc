+++
toc = true
title = "Build"
weight = 1
+++

## Build and Run

### Build and Run through maven

1. `git clone https://github.com/apache/incubator-shardingsphere.git`
1. Run `mvn clean install -Prelease`
1. Get the package in `/sharding-distribution/shardingsphere-ui-distribution/target/apache-shardingsphere-incubating-${latest.release.version}--sharding-ui-bin.tar.gz`.
1. After the decompression, run bin/start.sh


### Run frontend and backend separately

#### backend
1. Main class is `org.apache.shardingsphere.ui.Bootstrap`.

#### frontend
1. `cd sharding-ui-frontend/`。
1. run `npm install`。
1. run `npm run dev`。
1. visit `http://localhost:8080/`。


## Configuration

Configuration file of Sharding-UI is conf/application.properties in distribution package. It is constituted by two parts.

1. Listening port.
1. authentication.

```properties
server.port=8088

user.admin.username=admin
user.admin.password=admin
```

## Notices

1. If you run the frontend project locally after a build with maven, you may fail to run it due to inconsistent version of node. You can clean up `node_modules/` directory and run it again.