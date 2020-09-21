git clone https://github.com/apache/shardingsphere.git _shardingsphere
echo check diff
if  [ ! -s old_version_pdf ]  ; then
    echo init > old_version_pdf
fi
cd _shardingsphere
git log -1 -p docs > new_version_pdf
diff ../old_version_pdf new_version_pdf > result_version
if  [ ! -s result_version ]  ; then
    echo "shardingsphere docs document sources didn't change and nothing to do!"
    cd ..
    rm -rf _shardingsphere
else
    count=1
    echo "check shardingsphere docs document something new, launch a build..."
    cd ..
    git config --global user.name CaymanHK 
    git config --global user.email 244124339@qq.com
    mv _shardingsphere/new_version_pdf ./old_version_pdf
    python -m pip install --upgrade pip
    pip install sphinx
    sudo apt-get update -y 
    sudo apt-get install -y latexmk texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
    sudo apt-get install texlive-xetex latex-cjk-all
    sudo apt-get install pandoc
    wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansSC.zip
    wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTF/SourceHanSerifSC_SB-H.zip
    wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTF/SourceHanSerifSC_EL-M.zip
    unzip SourceHanSansSC.zip
    unzip SourceHanSerifSC_EL-M.zip
    unzip SourceHanSerifSC_SB-H.zip
    sudo mv SourceHanSansSC SourceHanSerifSC_EL-M SourceHanSerifSC_SB-H /usr/share/fonts/opentype/
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
    #######################################
    ##  Making PDFs   ##
    #######################################
    targetDir=" _shardingsphere/docs/document/content"
    localDir="source"
    cp .github/scripts/Makefile .
    for lang in en cn
    do
        mkdir $localDir
        cp -r ${targetDir}/* ${localDir}/
        cp .github/scripts/conf.py ${localDir}/
        cd $localDir
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
            sed -i "s/(\/${lang}/(https:\/\/shardingsphere.apache.org\/document\/current\/${lang}/g" $f
            sed -i /http.*codacy/d $f
            pandoc $f -o "${f}.rst"
            rm $f
        done

        cd ..
        make latexpdf
        mkdir -p pdf
        cp _build/latex/*.pdf pdf/shardingsphere_docs_${lang}.pdf
        echo "shardingsphere_docs_${lang}.pdf"
        make clean
        rm -rf {_build,source}
    done
    rm -rf {_shardingsphere,Makefile}
    git pull
    git add -A
    dateStr=`date "+%Y-%m-%d %H:%M:%S %Z"`
    git commit -m  "Update PDF files at $dateStr."
    git push
fi