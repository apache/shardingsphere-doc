#!/usr/bin/env bash

set -eo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

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
    sudo apt-get install -y texlive-xetex latex-cjk-all
    sudo dpkg -i "$script_dir/../../pandoc-2.16.1-1-amd64.deb"
    mkdir -p "$pdf_temp_dir/fonts"
    (
        cd "$pdf_temp_dir/fonts"
        wget -nv -O SourceHanSansSC.zip https://github.com/adobe-fonts/source-han-sans/releases/download/2.005R/09_SourceHanSansSC.zip
        wget -nv -O SourceHanSerifSC.zip https://github.com/adobe-fonts/source-han-serif/releases/download/2.000R/SourceHanSerifSC.zip
        wget -nv -O source-serif-pro.zip https://github.com/adobe-fonts/source-serif/releases/download/3.001R/source-serif-pro-3.001R.zip
        wget -nv -O source-sans-pro.zip https://github.com/adobe-fonts/source-sans/releases/download/2.045R-ro/1.095R-it/source-sans-pro-2.045R-ro-1.095R-it.zip
        wget -nv -O source-code-pro.zip https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u/1.062R-i/1.026R-vf/OTF-source-code-pro-2.042R-u_1.062R-i.zip
        for font in SourceHanSansSC SourceHanSerifSC source-serif-pro source-sans-pro source-code-pro; do
            unzip -q "$font.zip" -d "$font"
            sudo mkdir -p "/usr/share/fonts/opentype/$font"
            # XeTeX needs desktop fonts; do not let Fontconfig select bundled web fonts.
            find "$font" -type f -name '*.otf' -exec sudo cp -t "/usr/share/fonts/opentype/$font" {} +
        done
    )
    sudo fc-cache -f -v
}

function generate_pdf {
    local pdf_dir="$pdf_temp_dir/$1"
    mkdir -p "$pdf_dir"
    if [[ "$1" == "shardingsphere" ]] ;then
        targetDir=" _$1/docs/document/content"
    else
        targetDir=" _$1/docs/content"
    fi
    localDir="source"
    cp .github/scripts/Makefile .
    currentDir=`pwd`
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
        sed -i 's/##[ ][0-9]*\./##/g' faq/*
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
            sed -i /http.*badge.*/d $f
            if [[ "$1" == "shardingsphere" ]] ;then
                sed -i "s/(\/${lang}/(https:\/\/shardingsphere.apache.org\/document\/current\/${lang}/g" $f
            else
                sed -i "s/(\/${lang}/(https:\/\/shardingsphere.apache.org\/elasticjob\/current\/${lang}/g" $f
                sed -i /branch=master/d $f
            fi
            sed -i /http.*codacy/d $f
            pandoc $f -fmarkdown-implicit_figures --lua-filter="${currentDir}/.github/scripts/remove-tab.lua" -o "${f}.rst"
            rm $f
        done

        cd ..
        make latexpdf
        cp _build/latex/*.pdf "$pdf_dir/${1}_docs_${lang}.pdf"
        test -s "$pdf_dir/${1}_docs_${lang}.pdf"
        if [[ "$(head -c 5 "$pdf_dir/${1}_docs_${lang}.pdf")" != '%PDF-' ]]; then
            echo "Invalid PDF: ${1}_docs_${lang}.pdf" >&2
            return 1
        fi
        make clean
        rm -rf {_build,source}
    done
    git pull --ff-only
    mkdir -p pdf
    cp "$pdf_dir/${1}_docs_en.pdf" "$pdf_dir/${1}_docs_cn.pdf" pdf/
    mv "_$1/new_version_$1" "old_version_$1"
    rm -rf {_$1,Makefile}
    git add -- "pdf/${1}_docs_en.pdf" "pdf/${1}_docs_cn.pdf" "old_version_${1}"
    dateStr=`date "+%Y-%m-%d %H:%M:%S %Z"`
    git commit --only -m "Update PDF files at $dateStr." -- "pdf/${1}_docs_en.pdf" "pdf/${1}_docs_cn.pdf" "old_version_${1}"
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

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    pdf_temp_dir=$(mktemp -d)
    trap 'rm -rf "$pdf_temp_dir"' EXIT
    prepare
    clone_repo "shardingsphere"
    check_diff "shardingsphere"
    clone_repo "shardingsphere-elasticjob"
    check_diff "shardingsphere-elasticjob"
fi
