#!/bin/bash
set -e -o pipefail

# add pandoc to PATH
source "${HOME}/.bashrc"

# get directory of this script, which is located with the markdown files
directory=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for path in "${directory}"/*.md; do
    file="$(basename "$path")"
    filename="${file%.*}"
    if [[ "$file" == "README.md" ]]; then
        sed -e 's/\.md/.html/g' "$path" | \
        pandoc -s --mathjax \
            --toc --variable toc-title="Contents" --metadata title="$filename" \
            -f gfm -t html -o "${filename}.html"
    elif [[ ! $file =~ "LICENSE.md" ]]; then
        echo "$filename"
        pandoc -s --mathjax \
            --toc --variable toc-title="Contents" --metadata title="$filename" \
            -f gfm -t html -o "${filename}.html" "$path"
    fi
done

for path in "${directory}"/*/*.md; do
    file="$(basename "$path")"
    subdir="$(basename "$(dirname "$path")")"
    filename="${file%.*}"
    output_path="${path%.*}.html"
    echo "${subdir}/${filename}"
    pandoc -s --mathjax \
        --toc --variable toc-title="Contents" --metadata title="$filename" \
        -f gfm -t html -o "${output_path}" "$path"
done
