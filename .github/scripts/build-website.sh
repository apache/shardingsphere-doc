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

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo config user shardingsphere
git config --global user.email "dev@shardingsphere.apache.org"
git config --global user.name "shardingsphere"

count=0
export TZ="Asia/Shanghai"

#######################################
##        SHARDINGSPHERE/DOCS        ##
#######################################
set -e
echo "[1] ====>>>> process shardingsphere/docs"
companion_root=$PWD
ss_build_dir=$(mktemp -d)
trap 'rm -rf "$ss_build_dir"' EXIT

echo git clone https://github.com/apache/shardingsphere
git clone --filter=blob:none --no-single-branch https://github.com/apache/shardingsphere "$ss_build_dir/upstream"
cd "$ss_build_dir/upstream"
tags=$(git tag --sort=taggerdate)
new_tags=()
mkdir "$ss_build_dir/history"
# Validate the published versions before building or replacing any output.
python3 "$script_dir/prepare-site-config.py" versions "$companion_root" "$ss_build_dir/history" \
  > "$ss_build_dir/versions.json"

# Existing release HTML is immutable, including versions with older content layouts.
for tag in $tags; do
  if [[ ! "$tag" =~ ^[0-9]+\.[0-9]+ ]] || [ -d "$companion_root/document/$tag" ]; then
    continue
  fi
  git checkout --force "$tag"
  if [ -d docs/document/content ]; then
    echo "generate $tag document"
    env SHARDINGSPHERE_DOCS_SITES=document \
      SHARDINGSPHERE_DOCS_VERSION="$tag" SHARDINGSPHERE_DOCS_VERSIONS_ROOT="$companion_root" \
      SHARDINGSPHERE_DOCS_HISTORY_ROOT="$ss_build_dir/history" \
      bash "$script_dir/build-shardingsphere-docs.sh" "$PWD/docs" "$ss_build_dir/release"
    mv "$ss_build_dir/release/document/$tag" "$ss_build_dir/history/$tag"
    rm -rf "$ss_build_dir/release"
    new_tags+=("$tag")
  fi
done

python3 "$script_dir/prepare-site-config.py" versions "$companion_root" "$ss_build_dir/history" \
  > "$ss_build_dir/versions.json"

git checkout --force master
git log -1 -p docs > "$ss_build_dir/new_version_ss"
git -C "$companion_root" ls-tree -r HEAD -- \
  .github/scripts/build-shardingsphere-docs.sh .github/scripts/prepare-hextra-theme.sh \
  .github/scripts/prepare-site-config.py .github/scripts/build-website.sh \
  .github/website/shardingsphere .github/workflows/build-website.yml \
  > "$ss_build_dir/renderer_tree"
renderer_revision=$(git -C "$companion_root" hash-object "$ss_build_dir/renderer_tree")
versions_revision=$(git -C "$companion_root" hash-object "$ss_build_dir/versions.json")
printf '\nrenderer revision: %s\nversions revision: %s\n' \
  "$renderer_revision" "$versions_revision" >> "$ss_build_dir/new_version_ss"

if cmp -s "$companion_root/old_version_ss" "$ss_build_dir/new_version_ss"; then
  echo "shardingsphere docs sources, renderer and versions didn't change and nothing to do!"
else
  echo "check shardingsphere something new, launch a build..."
  env SHARDINGSPHERE_DOCS_VERSIONS_ROOT="$companion_root" \
    SHARDINGSPHERE_DOCS_HISTORY_ROOT="$ss_build_dir/history" \
    bash "$script_dir/build-shardingsphere-docs.sh" "$PWD/docs" "$ss_build_dir/current"
fi

# New release menus also need the current pages from this run, not the previous publication.
if [ -d "$ss_build_dir/current" ]; then
  ln -s "$ss_build_dir/current/document/current" "$ss_build_dir/history/current"
fi
for tag in "${new_tags[@]}"; do
  git checkout --force "$tag"
  env SHARDINGSPHERE_DOCS_SITES=document \
    SHARDINGSPHERE_DOCS_VERSION="$tag" SHARDINGSPHERE_DOCS_VERSIONS_ROOT="$companion_root" \
    SHARDINGSPHERE_DOCS_HISTORY_ROOT="$ss_build_dir/history" \
    bash "$script_dir/build-shardingsphere-docs.sh" "$PWD/docs" "$ss_build_dir/release"
  rm -rf "$ss_build_dir/history/$tag"
  mv "$ss_build_dir/release/document/$tag" "$ss_build_dir/history/$tag"
  rm -rf "$ss_build_dir/release"
done

# Published history also consumes these stable asset paths outside its own directories.
if [ -d "$ss_build_dir/current" ]; then
  legacy_assets=(document/current/{css,js,fonts,webfonts,img,images,mermaid} community/{css,js,fonts,images,image,mermaid} blog/img)
  for asset_dir in "${legacy_assets[@]}"; do
    if [ ! -d "$companion_root/$asset_dir" ]; then
      continue
    fi
    while IFS= read -r -d '' asset; do
      target="$ss_build_dir/current/${asset#"$companion_root/"}"
      if [ ! -e "$target" ]; then
        mkdir -p "$(dirname "$target")"
        cp -p "$asset" "$target"
      fi
    done < <(find "$companion_root/$asset_dir" -type f -print0)
  done
fi

# Publish only after all ShardingSphere builds have succeeded.
cd "$companion_root"
mkdir -p document
for tag in "${new_tags[@]}"; do
  mv "$ss_build_dir/history/$tag" "document/$tag"
  count=1
done
mv "$ss_build_dir/versions.json" versions.json
if [ -d "$ss_build_dir/current" ]; then
  rm -rf document/current community blog
  mv "$ss_build_dir/current/document/current" document/current
  mv "$ss_build_dir/current/community" community
  mv "$ss_build_dir/current/blog" blog
  mv "$ss_build_dir/new_version_ss" old_version_ss
  count=2
fi
rm -rf "$ss_build_dir"
trap - EXIT
set +e

#######################################
##  SHARDINGSPHERE-ELASTICJOB/DOCS   ##
#######################################
echo "[2] ====>>>> process shardingsphere-elasticjob/docs"
echo git clone https://github.com/apache/shardingsphere-elasticjob

git clone --filter=blob:none --no-single-branch https://github.com/apache/shardingsphere-elasticjob _elasticjob 

echo check diff
if  [ ! -s old_version_ej ]  ; then
    echo init > old_version_ej 
fi
cd _elasticjob
git log -1 -p docs > new_version_ej
diff ../old_version_ej new_version_ej > result_version
if  [ ! -s result_version ]  ; then
    echo "elasticjob docs sources didn't change and nothing to do!"
    cd ..
    rm -rf _elasticjob
else
    count=3
    echo "check elasticjob something new, launch a build..."
    cd ..
    rm -rf old_version_ej
    mv _elasticjob/new_version_ej ./old_version_ej
    
    mkdir ejdocs
    cp -rf _elasticjob/docs/* ./ejdocs
    rm -rf _elasticjob
    
    echo build hugo elasticjob documents
    set -e
    sh ./ejdocs/build.sh
    set +e
    mkdir ejtarget
    cp -rf ejdocs/public/* ./ejtarget
    rm -rf ejdocs
    
    echo replace old files
    # Overwrite HTLM files
    echo copy elasticjob/current to dest dir
    if [ ! -d "elasticjob/current"  ];then
      mkdir -p elasticjob/current
    else
      echo elasticjob/current  exist
      rm -rf elasticjob/current/*
    fi
    cp -fr ejtarget/* elasticjob/current
    
    rm -rf ejtarget
    #ls -al
fi

################################################
##        SHARDINGSPHERE-ON-CLOUD DOCS        ##
################################################
echo "[1] ====>>>> process shardingsphere-on-cloud/docs"
echo git clone https://github.com/apache/shardingsphere-on-cloud

git clone --filter=blob:none --no-single-branch https://github.com/apache/shardingsphere-on-cloud _oncloud 

# ------------------------- build history docs --------------------------------------
cd _oncloud
TAGS=(`git tag --sort=taggerdate | grep -E '^[[:digit:]]+.[[:digit:]]+.*+'`)
VALID_TAGS=()

# generate released document
if [ ${#TAGS} -gt 0 ] ; then
  for tag in ${TAGS[@]}
  do
    echo "generate $tag documnet"
    git checkout $tag
    if [ -d docs -a -f docs/build.sh ] ; then
      VALID_TAGS=(${VALID_TAGS[@]} $tag)
      if [ ! -d ../oncloud/$tag ] ; then
        count=1
        dir=$tag
        set -e
        env HUGO_BASEURL="https://shardingsphere.apache.org/oncloud/$dir/" \
          HUGO_PARAMS_EDITURL="" \
          bash docs/build.sh
        set +e
        find docs/target/current -name '*.html' -exec sed -i -e 's|<option id="\([a-zA-Z]\+\)" value="/current|<option id="\1" value="/'$dir'|g' {} \;
        mv docs/target/current/ ../oncloud/$dir
      fi
    fi
  done
fi


# -----------------------------------------------------------------------------------
echo check diff
if  [ ! -s ../old_version_oc ]  ; then
    echo init > ../old_version_oc
fi
git checkout main
git log -1 -p docs > new_version_oc
diff ../old_version_oc new_version_oc > result_version

if  [ ! -s result_version ]  ; then
    echo "shardingsphere-on-cloud docs sources didn't change and nothing to do!"
    cd ..
else
    count=2
    echo "check shardingsphere-on-cloud something new, launch a build..."
    cd ..
    rm -rf old_version_oc
    mv _oncloud/new_version_oc ./old_version_oc
    
    cp -rf _oncloud/docs ./
    mv docs ocdocs
    
    echo build hugo oncloud documents
    set -e
    sh ./ocdocs/build.sh
    set +e
    cp -rf ocdocs/target ./
    rm -rf ocdocs
    mv target octarget
    
    echo replace old files
    # Overwrite HTLM files
    echo copy document/current to dest dir
    if [ ! -d "oncloud/current"  ];then
      mkdir -p oncloud/current
    else
      echo current  exist
      rm -rf oncloud/current/*
    fi
    cp -fr octarget/current/* oncloud/current
    
    rm -rf octarget
fi
rm -rf _oncloud

if [ $count -eq 0 ];then
    echo "Both ShardingSphere&ElasticJob&OnCloud docs are not Changed, Skip&Return now."
elif [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]; then
    echo "Pull request build completed, skip publishing."
else
    echo git push new files
    git add .
    export TZ="Asia/Shanghai"
    dateStr=`date "+%Y-%m-%d %H:%M:%S %Z"`
    git commit -m  "Update shardingsphere documents at $dateStr."
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo "sync latest from origin/${branch_name} before pushing..."
    set -e
    git pull --rebase origin "${branch_name}"
    git push origin "${branch_name}"
fi
