Miscellaneous software tools

# Google Drive

## Web App (drive.google.com)

Searching for files by file type: `type:<MIME type>`
- For non-Google file types, the web app appears to support [Export MIME types](https://developers.google.com/drive/api/guides/ref-export-formats)
- For Google-proprietary file types, the Google Drive web app appears to support searching a different set of MIME types than the [Google Drive API](https://developers.google.com/drive/api/guides/mime-types) [[StackOverflow](https://webapps.stackexchange.com/questions/160544/how-to-find-google-proprietary-files-docs-slides-sheets-drawings-etc)]
  - Google Colaboratory notebooks: `application/vnd.google.colaboratory` or `application/vnd.google.colab`
  - Google Docs: `application/vnd.google-apps.kix`
  - Google Forms: `application/vnd.google-apps.freebird`
  - Google Slides: `application/vnd.google-apps.punch`
  - Google Sheets: `application/vnd.google-apps.ritz`
- Google Drive also supports searching both non-Google and Google file types together with certain keywords [[Google Drive Help](https://support.google.com/drive/answer/2375114)]
  > Search by the type of document: folder, document, spreadsheet, presentation, PDF, image, video, drawing, form, site, script, table, or jam file.
  - Of these, `form` (Google Forms), `site` (Google Sites), `script` (Google Apps Script), and `jam` (Google Jamboard) anecdotally appear to specifically search for the corresponding Google file type, while the others (such as `document`) aggregate both Google and non-Google file types.

## gdrive

[gdrive: Google Drive CLI Client](https://github.com/gdrive-org/gdrive)

Google Drive API: https://developers.google.com/drive/api/v3/reference
- Query syntax: https://developers.google.com/drive/api/v3/search-files

Search for folder in Google Drive: `gdrive list -q "mimeType = 'application/vnd.google-apps.folder' and name = '<folder name>'"`
- Prints out table: Id, Name, Type, Size, [Date] Created

Upload file/folder to Google Drive: `gdrive upload [--recursive] -p <folder_id> <file/folder>`

# 7-Zip

Documentation: https://7-zip.opensource.jp/chm/

FAQ [[7-Zip source](https://sourceforge.net/projects/sevenzip/files/7-Zip/23.01/7z2301-src.tar.xz/download)]
- variants of standalone 7z executables: 7zz supports all formats, 7za supports only 7z/xz/cab/zip/gzip/bzip2/tar, and 7zr supports only 7z.

Attributes, as show by the list command (e.g., `7z l <archive>`) [[7-Zip SourceForge Discussions](https://sourceforge.net/p/sevenzip/discussion/45797/thread/007e2626/); see also [py7zr documentation](https://py7zr.readthedocs.io/en/latest/archive_format.html#attribute)]
- A: archive
- H: hidden
- R: read-only
- S: system
- Anti-items
  - Files: attributes = n/a, size = 0
  - Directories: attributes = D, size = 0

Specifying directories and files: to archive *all* files and folders (recursively) from directory `mydir`, use `7zz a archive.7z './mydir/*'`
- Include the prefix `./` to exclude the `mydir/` prefix from filenames in the archive (i.e., files will be directly stored as `archive.7z/myfile` instead of `archive.7z/mydir/myfile`)
- Use quotes around `./mydir/*` to prevent shell expansion of `*`, which would only encompass non-hidden files (i.e., files that do not start with `.`). Passing the literal `*` to 7-Zip tells it to include all files within `mydir/`.
  - This is tested on macOS terminal and presumably applies to linux shells. Unclear how quoting and expansion works on Windows shells.

Compare files, and make changes to *source* as appropriate.
- Check for files not in source but still in archive: `7zz u <archive> -ms=off -u- -up1q1r0x0y0z0w0'!'only_archive.7z <src> > /dev/null; 7zz l only_archive.7z > only_archive.txt`
  - Note: The [documentation](https://7-zip.opensource.jp/chm/cmdline/switches/update.htm) is unclear about the distinction between the `p` (File exists in archive, but is not matched with wildcard) and `q` (File exists in archive, but doesn't exist on disk) states. If the file does not exist on disk, it naturally would not be matched by any wildcard. Hence, what is the purpose of the `q` state? I could not find a condition where the `q` state alone (combined with any action) would lead to a file being archived.
  - `-ms=off`: do not create [solid](https://7-zip.opensource.jp/chm4/cmdline/switches/method.htm#Solid) archives, which while achieving higher compression ratio, are less easily updated.
- Check for files in source but not in archive: `7zz u <archive> -ms=off -u- -up0q0r2x0y0z0w0'!'only_source.7z <src> > /dev/null; 7zz l only_source.7z > only_source.txt`
- Check for files in source older than archive: `7zz u <archive> -ms=off -u- -up0q0r0x1y0z0w0'!'source_older.7z <src> > /dev/null; 7zz l source_older.7z > source_older.txt`
- Check for files in source newer than archive: `7zz u <archive> -ms=off -u- -up0q0r0x0y2z0w0'!'source_newer.7z <src> > /dev/null; 7zz l source_newer.7z > source_newer.txt`
- Check for files with same timestamp but different sizes: `7zz u <archive> -ms=off -u- -up0q0r0x0y0z0w3'!'different_sizes.7z <src> > /dev/null; 7zz l different_sizes.7z > different_sizes.txt`

(Optional) Generate a differential archive: `7zz u <archive> -ms=off -u- -up3q3r2x1y2z0w2'!'diff.7z <src> > /dev/null; 7zz l diff.7z > diff.txt`

Update main archive (make changes to *archive*): `7zz u <archive> -ms=off -up0q0r2x1y2z1w3 <src>`

My exclude list: `'-xr0!*/.sync.ffs_db'  '-xr0!*/._*'  '-xr0!*/.DocumentRevisions-V100/'  '-xr0!*/.DS_Store'  '-xr0!*/.fseventsd/'  '-xr0!*/.Spotlight-V100/'  '-xr0!*/.TemporaryItems/'  '-xr0!*/.Trashes/'  '-xr0!*/thumbs.db'`

Note: Info-Zip (`zip`) also has similar updating features via its `--FS/--filesync` and `-DF/--difference-archive` options.

My full 7-zip command: `7zz a OneDrive.7z './OneDrive/*' -ms=off -mtc=on '-xr0!*.sync.ffs_db' '-xr0!*/._*' '-xr0!*/.DocumentRevisions-V100/' '-xr0!*/.DS_Store' '-xr0!*/.fseventsd/' '-xr0!*/.Spotlight-V100/' '-xr0!*/.TemporaryItems/' '-xr0!*/.Trashes/' '-xr0!*/thumbs.db' -sccUTF-8 -snl -p<password>`