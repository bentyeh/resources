#!/bin/bash
# Convert all Markdown note files to HTML using pandoc.
# - By default, only regenerates an existing HTML file if the Markdown file is newer.
# - Assumes pandoc is in PATH
# 
# Supported arguments (mutually exclusive)
# -c, --clean: remove existing HTML files and exit
# -f, --force: (re)generate all HTML files

# SETUP
set -e -o pipefail

# get directory of this script, which is located with the markdown files
directory=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# (If specified) CLEAN
toclean="$1"
if [ ! -z "$toclean" ] && ([ "$toclean" = "-c" ] || [ "$toclean" = "--clean" ]); then
    # need to check for existence of HTML files first, otherwise rm will complain
    # solution from https://unix.stackexchange.com/a/214066
    html_files=("${directory}"/*.html)
    [ -f ${html_files[0]} ] && rm "${directory}"/*.html
    html_files=("${directory}"/*/*.html)
    [ -f ${html_files[0]} ] && rm "${directory}"/*/*.html
    exit 0
fi

# CONVERT MARKDOWN TO HTML
force="$1"
if [ ! -z "$force" ]; then
    if [ ! "$force" = "-f" ] && [ ! "$force" = "--force" ]; then
        echo "Did not understand argument $force"
        exit 1
    fi
    force=true
else
    force=false
fi

for path in "${directory}"/*.md; do
    file="$(basename "$path")"
    filename="${file%.*}"
    output_path="${path%.*}.html"
    if [[ "$file" == "README.md" ]]; then
        if [ "$force" = true ] || [ ! -f "$output_path" ] || [ "$path" -nt "$output_path" ]; then
            echo "$filename"
            sed -e 's/\.md/.html/g' "$path" | \
            pandoc -s --mathjax \
                --toc --variable toc-title="Contents" --metadata title="$filename" \
                -f gfm -t html -o "$output_path"
        fi
    elif [[ ! $file =~ "LICENSE.md" ]]; then
        if [ "$force" = true ] || [ ! -f "$output_path" ] || [ "$path" -nt "$output_path" ]; then
            echo "$filename"
            pandoc -s --mathjax \
                --toc --variable toc-title="Contents" --metadata title="$filename" \
                -f gfm -t html -o "$output_path" "$path"
        fi
    fi
done

for path in "${directory}"/*/*.md; do
    file="$(basename "$path")"
    subdir="$(basename "$(dirname "$path")")"
    filename="${file%.*}"
    output_path="${path%.*}.html"
    if [ "$force" = true ] || [ ! -f "$output_path" ] || [ "$path" -nt "$output_path" ]; then
        echo "${subdir}/${filename}"
        pandoc -s --mathjax \
            --toc --variable toc-title="Contents" --metadata title="$filename" \
            -f gfm -t html -o "$output_path" "$path"
    fi
done
