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

set -e

SHARDINGSPHERE_DOC_PATH=$1

echo "current path is ${SHARDINGSPHERE_DOC_PATH}"
echo "1. start to clone shardingsphere"
git clone https://github.com/apache/shardingsphere
cd shardingsphere

echo "1.1 prepare the config for checkstyle"
sed -i 's/<property name="severity" value="error" \/>/<property name="severity" value="warning" \/>/g' src/resources/checkstyle.xml

echo "2. build project"
./mvnw clean install -DskipITs -DskipTests -Dcheckstyle.skip=true

echo "3. process maven site"
./mvnw site:site -Dmaven.resolver.validation=OFF

echo "4. process maven stage"
./mvnw site:stage

for report in index.html project-info.html project-reports.html xref/index.html rat-report.html checkstyle-aggregate.html cpd.html pmd.html taglist.html; do
  if [ ! -s "target/staging/${report}" ] || ! grep -qi '<html' "target/staging/${report}" || ! grep -qi '</html>' "target/staging/${report}"; then
    echo "Missing or incomplete Maven report: target/staging/${report}" >&2
    exit 1
  fi
done

echo "5. upload the maven report"
rm -rf "${SHARDINGSPHERE_DOC_PATH}/statistics/staging"
mv target/staging "${SHARDINGSPHERE_DOC_PATH}/statistics/"
git config --global user.email "dev@shardingsphere.apache.org"
git config --global user.name "shardingsphere"
cd "${SHARDINGSPHERE_DOC_PATH}"
git add -A -- statistics/staging
if git diff --cached --quiet -- statistics/staging; then
  echo "Maven reports are unchanged."
  exit 0
fi
export TZ="Asia/Shanghai"
dateStr=`date "+%Y-%m-%d %H:%M:%S %Z"`
git commit --only -m "Update shardingsphere maven report at $dateStr." -- statistics/staging
git push
