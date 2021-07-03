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

echo config user shardingsphere
git config --global user.email "dev@shardingsphere.apache.org"
git config --global user.name "shardingsphere"
export TZ="Asia/Shanghai";

#######################################
##        SHARDINGSPHERE/DOCS        ##
#######################################

cd document;

if [ -d preview ] ; then
    if [ ! -d current ] ; then
        mkdir current && cp -rf preview/* current/
        ls -rsed -i "s/\/document\/preview/\/document\/current/g"
    fi

    rm -rf _current &&
    mv current _current && \
    rm -rf current && \
    mkdir current && \
    cp -rf preview/* current/ && \
    find . -type f|xargs -i sed -i "s/\/document\/preview/\/document\/current/g" {} && \
    rm _current/ -rf || \
    ( rm -rf current && mv _current current )  # fall back to initial state
else
    mkdir preview && \
    cp -rf current/* preview/ && \
    find . -type f|xargs -i sed -i "s/\/document\/current/\/document\/preview/g" {} && \
    echo the directory preview/ is not found 
fi

git add .
git commit -m "update preview-document"
git push