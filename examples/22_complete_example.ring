load "archive.ring"

# Complete example: Building a simple backup utility

? "=== Simple Backup Utility ==="
? ""

# Create some sample files to backup
system("mkdir -p backup_test/docs backup_test/data")
write("backup_test/readme.txt", "Project README file")
write("backup_test/docs/manual.txt", "User manual content here")
write("backup_test/data/config.json", '{"setting": "value"}')

# 1. Create a compressed, encrypted backup
? "Creating encrypted backup..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase("backup2024")
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

# 3. Extract and verify a specific file
? ""
? "Verifying data/config.json:"
cContent = archive.readFile("backup.zip", "data/config.json")
? "  Content: " + cContent

# 4. Full restore
? ""
? "Restoring backup to 'restored/' folder..."
system("mkdir -p restored")
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
system("rm -rf backup_test restored")
remove("backup.zip")

? ""
? "=== Backup utility demo complete ==="
