load "archive.ring"
load "stdlibcore.ring"

# Complete example: Building a simple backup utility

? "=== Simple Backup Utility ==="
? ""

# Create some sample files to backup
currentDir = currentDir()
makeDir("backup_test")
chdir("backup_test")
makeDir("docs")
makeDir("data")
write("readme.txt", "Project README file")
write("docs/manual.txt", "User manual content here")
write("data/config.json", '{"setting": "value"}')
chdir(currentDir)

cPassword = "backup2024"

# 1. Create a compressed, encrypted backup
? "Creating encrypted backup..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase(cPassword)
writer.setEncryption(ARCHIVE_ENCRYPTION_AES256)
writer.open("backup.zip")

# Add files with directory structure
writer.addFile("readme.txt", read("backup_test/readme.txt"))
writer.addDirectory("docs/")
writer.addFile("docs/manual.txt", read("backup_test/docs/manual.txt"))
writer.addDirectory("data/")
writer.addFile("data/config.json", read("backup_test/data/config.json"))

writer.close()
writer.free()
? "Created backup.zip (encrypted with AES-256)"

# 2. List and verify backup contents
? ""
? "Backup contents:"
archive = new Archive
aFiles = archive.list("backup.zip")
nTotalSize = 0
for aFile in aFiles
    cType = "FILE"
    if aFile[3] = ARCHIVE_ENTRY_DIR
        cType = "DIR "
    ok
    ? "  [" + cType + "] " + aFile[1] + " (" + aFile[2] + " bytes)"
    nTotalSize += aFile[2]
next
? "Total: " + len(aFiles) + " entries, " + nTotalSize + " bytes"

# 3. Extract and verify a specific file (using ArchiveReader with passphrase)
? ""
? "Verifying data/config.json:"
reader = new ArchiveReader(NULL)
reader.addPassphrase(cPassword)
reader.open("backup.zip")
while reader.nextEntry()
    if reader.entryPath() = "data/config.json"
        cContent = reader.readAll()
        ? "  Content: " + cContent
        exit
    ok
end
reader.close()
reader.free()

# 4. Full restore
? ""
? "Restoring backup to 'restored/' folder..."
makeDir("restored")
archive.extract("backup.zip", "restored/")
? "Restore complete!"

# Show restored files
? ""
? "Restored files:"
aRestored = dir("restored")
for aItem in aRestored
    if aItem[2] = false
        ? "  " + aItem[1]
    ok
next

# Cleanup
OSDeleteFolder("backup_test")
OSDeleteFolder("restored")
remove("backup.zip")

? ""
? "=== Backup utility demo complete ==="
