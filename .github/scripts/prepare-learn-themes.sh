#!/usr/bin/env bash
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

docs_root=$(cd "$1" && pwd)
theme_temp_dir=$(mktemp -d)
trap 'rm -rf "$theme_temp_dir"' EXIT

document_commit=e817f53d690d35f181c896e0e320cb40f797e88c
community_commit=59c4cbf18690feb0cd0a16ad0f1434249c9dd5f3
git init --quiet "$theme_temp_dir"
git -C "$theme_temp_dir" fetch --quiet --depth=1 \
  https://github.com/matcornic/hugo-theme-learn.git "$document_commit" "$community_commit"

for site in document community; do
  if [ ! -d "$docs_root/$site" ]; then
    continue
  fi
  commit=$document_commit
  if [ "$site" = community ]; then
    commit=$community_commit
  fi
  git -C "$theme_temp_dir" archive "$commit" > "$theme_temp_dir/$site.tar"
  mkdir -p "$docs_root/$site/themes/hugo-theme-learn"
  tar -xf "$theme_temp_dir/$site.tar" -C "$docs_root/$site/themes/hugo-theme-learn"
done
