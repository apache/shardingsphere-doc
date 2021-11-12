function clone_repo {
    git clone https://github.com/apache/$1.git _$1
}

function prepare {
    git config --global user.name "shardingsphere"
    git config --global user.email "dev@shardingsphere.apache.org"
    python -m pip install --upgrade pip
    pip install sphinx
    sudo apt-get update -y 
    sudo apt-get install -y latexmk texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
    sudo apt-get install texlive-xetex latex-cjk-all
    sudo apt-get install pandoc
    #wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansSC.zip
    wget https://github.com/adobe-fonts/source-han-sans/releases/latest/download/SourceHanSansSC.zip
    wget https://github.com/adobe-fonts/source-han-serif/releases/download/2.000R/SourceHanSerifSC.zip
    #wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTF/SourceHanSerifSC_SB-H.zip
    #wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTF/SourceHanSerifSC_EL-M.zip
    unzip SourceHanSansSC.zip -d SourceHanSansSC
    unzip SourceHanSerifSC.zip -d SourceHanSerifSC
    #unzip SourceHanSerifSC_EL-M.zip -d SourceHanSerifSC_EL-M
    #unzip SourceHanSerifSC_SB-H.zip -d SourceHanSerifSC_SB-H
    #sudo mv SourceHanSansSC SourceHanSerifSC_EL-M SourceHanSerifSC_SB-H /usr/share/fonts/opentype/
    sudo mv SourceHanSansSC SourceHanSerifSC /usr/share/fonts/opentype/
    wget -O source-serif-pro.zip https://www.fontsquirrel.com/fonts/download/source-serif-pro
    unzip source-serif-pro -d source-serif-pro
    sudo mv source-serif-pro /usr/share/fonts/opentype/
    wget -O source-sans-pro.zip https://www.fontsquirrel.com/fonts/download/source-sans-pro
    unzip source-sans-pro -d source-sans-pro
    sudo mv source-sans-pro /usr/share/fonts/opentype/
    wget -O source-code-pro.zip https://www.fontsquirrel.com/fonts/download/source-code-pro
    unzip source-code-pro -d source-code-pro
    sudo mv source-code-pro /usr/share/fonts/opentype/
    sudo fc-cache -f -v
}

function generate_pdf {
    mv _$1/new_version_$1 ./old_version_$1
    if [[ "$1" == "shardingsphere" ]] ;then
        targetDir=" _$1/docs/document/content"
    else
        targetDir=" _$1/docs/content"
    fi
    localDir="source"
    cp .github/scripts/Makefile .
    for lang in en cn
    do
        mkdir $localDir
        cp -r ${targetDir}/* ${localDir}/
        cp .github/scripts/conf.py ${localDir}/
        cd $localDir
        if [[ "$1" == "shardingsphere" ]] ;then
            sed -i 's/Apache ShardingSphere ElasticJob document/Apache ShardingSphere document/g' conf.py
        else
            sed -i 's/Apache ShardingSphere document/Apache ShardingSphere ElasticJob document/g' conf.py
        fi
        if [[ "$lang" == "en" ]] ;then
            sed -i "s/language = 'zh_CN'/language = 'en_US'/" conf.py
            echo "printing English version PDF"
        else
            sed -i "s/language = 'en_US'/language = 'zh_CN'/" conf.py
            echo "printing Chinese version PDF"
        fi
        sed -i 's/##[ ][0-9]*./##/g' faq/*
        echo -e ".. toctree::\n   :maxdepth: 1\n   :titlesonly:\n" >> index.rst
        for f in `find . -type f -name "*${lang}.md"`
        do
            title=`grep -oP '^title = "\K[^"]*' $f`
            weight=`grep -oP '^weight = \K.*' $f`
            sed -i -n '/+++/,/+++/!p' $f
            fileName=${f##*/}
            path=${f%/*}
            lastpath=${path%/*}
            foldername=${path##*/}
            if [[ "${fileName}" == "_index.${lang}.md" ]]
            then
            echo -e "${weight}\t${foldername}/index" >> "${lastpath}/filelist.txt"
            echo "============================" >> "${path}/index.rst"
            echo $title >> "${path}/index.rst"
            echo "============================" >> "${path}/index.rst"
            echo -e ".. toctree::\n   :maxdepth: 1\n   :titlesonly:\n\n   _index.${lang}.md" >> "${path}/index.rst"
            else
            sed -i "1i # ${title}" $f
            echo -e "${weight}\t${fileName}" >> "${path}/filelist.txt"
            fi
        done

        for f in `find . -type f -name "*list.txt"`
        do
            path=${f%/*}
            sort -nk 1  $f | awk '{print $2}' | sed 's/^/   /g' >> "${path}/index.rst"
            rm $f
        done

        echo "generating ${lang} rst file "
        for f in `find . -type f -name "*${lang}.md"`
        do
            sed -i -n '/+++/,/+++/!p' $f
            sed -i /http.*svg/d $f
            if [[ "$1" == "shardingsphere" ]] ;then
                sed -i "s/(\/${lang}/(https:\/\/shardingsphere.apache.org\/document\/current\/${lang}/g" $f
            else
                sed -i "s/(\/${lang}/(https:\/\/shardingsphere.apache.org\/elasticjob\/current\/${lang}/g" $f
                sed -i /branch=master/d $f
            fi
            sed -i /http.*codacy/d $f
            pandoc $f -o "${f}.rst"
            rm $f
        done

        cd ..
        make latexpdf
        mkdir -p pdf
        cp _build/latex/*.pdf pdf/$1_docs_${lang}.pdf
        echo "shardingsphere_docs_${lang}.pdf"
        make clean
        rm -rf {_build,source}
    done
    rm -rf {_$1,Makefile}
    git pull
    git add -A
    dateStr=`date "+%Y-%m-%d %H:%M:%S %Z"`
    git commit -m  "Update PDF files at $dateStr."
    git push

}

function check_diff {
    if  [ ! -s old_version_$1 ]; then
    echo init > old_version_$1
    fi
    cd _$1
    git log -1 -p docs > new_version_$1
    cd ..
    if cmp --silent -- old_version_$1 _$1/new_version_$1
    then
        echo "$1 docs document sources didn't change and nothing to do!"
        rm -rf _$1
    else
        echo "generate $1 docs pdfs"
        generate_pdf "$1"
        rm -rf _$1
    fi
}

prepare

clone_repo "shardingsphere"
check_diff "shardingsphere"

clone_repo "shardingsphere-elasticjob"
check_diff "shardingsphere-elasticjob"
