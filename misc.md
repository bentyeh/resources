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