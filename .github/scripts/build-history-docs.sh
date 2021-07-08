#!/bin/bash
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

set -e  # exit scripts when errors occurred

echo config user shardingsphere
git config --global user.email "dev@shardingsphere.apache.org"
git config --global user.name "shardingsphere"
export TZ="Asia/Shanghai";

script_path=$(cd `dirname $0`;pwd)
echo $script_path
root=`pwd`
echo Root: $root
git clone https://github.com.cnpmjs.org/apache/shardingsphere _shardingsphere 
cd _shardingsphere
git checkout master
# ---------------------------- build master doc ------------------------------------------#
cd docs/document
hugo --cleanDestinationDir
find ../document/public/ -name '*.html' -exec sed -i -e 's|[[:space:]]*<option id="\([a-zA-Z]\+\)" value="|<option id="\1" value="/document/master|g' {} \;
cd public/en
sed -i -e 's/cn/en/g' index.html
cd ../..

if [ -d $root/document/master ] ; then
    echo $root/document/master exists.
    rm -rf $root/document/master/* && cp -r $root/_shardingsphere/docs/document/public/*  $root/document/master/
else
    echo $root/document/master does not exist.
    mkdir $root/document/master
    cp -r $root/_shardingsphere/docs/document/public/*  $root/document/master/
fi

# ---------------------------- build master doc ------------------------------------------#


# ---------------------------- build legacy doc ------------------------------------------#
for v in {1..100}
do
    TAGS=`git tag --sort=committerdate -l $v'.*.*'|sed s/[[:space:]]//g`
    if [ ${#TAGS} -gt 0 ] ; then
        dir_name=$v".x"

        # remove useless tag
        for tag in `python3 $root/.github/scripts/filter_tag.py --tags ${TAGS[@]} --remove_tag 1`
        do
            echo rm old version release $tag
            rm $root/document/legacy/$dir_name/$tag -rf
        done

        for tag in `python3 $root/.github/scripts/filter_tag.py --tags ${TAGS[@]}`
        do
            cd $root/_shardingsphere
            git checkout $tag > /dev/null 2>&1
            if [ -d $root/document/legacy/$dir_name/$tag ] ; then
                echo /document/legacy/$dir_name/$tag already exists!
                continue
            fi
            if [ -d docs/document -a -f docs/document/config.toml ] ; then
                echo -e "\033[36mRelease $tag \033[0m: Documents are found." 

                cd docs
                cd document
                hugo --cleanDestinationDir
                find ../document/public/ -name '*.html' -exec sed -i -e 's|[[:space:]]*<option id="\([a-zA-Z]\+\)" value="|<option id="\1" value="/document/'$tag'|g' {} \;
                cd public/en
                sed -i -e 's/cn/en/g' index.html
                cd ../..
                cd ..

                if [ ! -d $root/document/legacy/$dir_name/default ] ; then
                    echo $root/document/legacy/$dir_name/default does not exist!
                    mkdir _default
                    mv $root/document/legacy/$dir_name/* _default
                    mkdir $root/document/legacy/$dir_name/default/
                    mv _default/* $root/document/legacy/$dir_name/default
                    rm _default -rf
                fi
                mkdir $root/document/legacy/$dir_name/$tag
                echo PWD `pwd`
                mv document/public/* $root/document/legacy/$dir_name/$tag/
            else
                echo -e "\033[34mWARNING\033[0m -\033[33m Release $tag\033[0m: Document is missing"
            
            fi
        done
    fi
done
# ---------------------------- build legacy doc ------------------------------------------#

# cd $root && rm _shardingsphere -rf
cd $root
git add .
git commit -m "update documents"
git push