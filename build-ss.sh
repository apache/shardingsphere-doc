echo config user kimmking
git config --global user.email "kimmking@163.com"
git config --global user.name "kimmking"

echo git clone https://github.com/apache/shardingsphere
rm -rf docs
git clone https://github.com/apache/shardingsphere _shardingsphere 

echo check diff
if  [ ! -s old_version ]  ; then
    echo init > old_version 
fi
cd _shardingsphere
git log -1 -p docs > new_version
diff ../old_version new_version > result_version
if  [ ! -s result_version ]  ; then
    echo "docs sources didn't change and nothing to do!"
    exit 0
fi

cd ..
rm -rf old_version
mv _shardingsphere/new_version ./old_version

cp -rf _shardingsphere/docs ./
rm -rf _shardingsphere

echo build hugo documents
sh ./docs/build.sh
cp -rf docs/target ./
rm -rf docs

echo replace old files
# Overwrite HTLM files
echo copy document/current to dest dir
if [ ! -d "document/current"  ];then
  mkdir -p document/current
else
  echo document/current  exist
  rm -rf document/current/*
fi
cp -fr target/document/current/* document/current

echo copy community to dest dir
if [ ! -d "community"  ];then
  mkdir -p community
else
  echo community  exist
  rm -rf community/*
fi
cp -fr target/community/* community

echo copy blog to dest dir
if [ ! -d "blog"  ];then
  mkdir -p blog
else
  echo blog  exist
  rm -rf iblog/*
fi
cp -fr target/blog/* blog

rm -rf target

echo git push new files
git add .
git commit -m  "update shardingsphere documents at `date`"
git push
