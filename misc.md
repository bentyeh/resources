Miscellaneous software tools

# Google Drive

Searching for Google Colaboratory notebooks: "type:application/vnd.google.colaboratory" || "type:application/vnd.google.colab"

## gdrive

[gdrive: Google Drive CLI Client](https://github.com/gdrive-org/gdrive)

Google Drive API: https://developers.google.com/drive/api/v3/reference
- Query syntax: https://developers.google.com/drive/api/v3/search-files

Search for folder in Google Drive: `gdrive list -q "mimeType = 'application/vnd.google-apps.folder' and name = '<folder name>'"`
- Prints out table: Id, Name, Type, Size, [Date] Created

Upload file/folder to Google Drive: `gdrive upload [--recursive] -p <folder_id> <file/folder>`