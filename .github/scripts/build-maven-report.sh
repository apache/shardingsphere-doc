#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SHARDINGSPHERE_DOC_PATH=$1

echo "current path is ${SHARDINGSPHERE_DOC_PATH}"
echo "1. start to clone shardingsphere"
git clone https://github.com/apache/shardingsphere
cd shardingsphere

echo "2. build project"
./mvnw clean install

echo "3. process maven site"
./mvnw site:site

echo "4. process maven stage"
./mvnw site:stage

echo "5. upload the maven report"
rm -rf ${SHARDINGSPHERE_DOC_PATH}/statistics/staging
mv target/staging  ${SHARDINGSPHERE_DOC_PATH}/statistics/
git config --global user.email "dev@shardingsphere.apache.org"
git config --global user.name "shardingsphere"
# git push
