load "archive.ring"

aEntries = archive_list("test_archive.tar.gz")

for entry in aEntries
    cPath = entry[1]
    nSize = entry[2]
    nType = entry[3]
    
    switch nType
    on ARCHIVE_ENTRY_FILE
        cType = "FILE"
    on ARCHIVE_ENTRY_DIR
        cType = "DIR "
    on ARCHIVE_ENTRY_SYMLINK
        cType = "LINK"
    other
        cType = "????"
    off
    
    ? "[" + cType + "] " + cPath + " (" + nSize + " bytes)"
next
