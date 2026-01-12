load "archive.ring"

# Create a test archive first
write("test1.txt", "Test file 1 content")
write("test2.txt", "Test file 2 content")
archive_create("test_archive.tar.gz", ["test1.txt", "test2.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

reader = new ArchiveReader("test_archive.tar.gz")

# Show archive format and filter info
? "Format: " + reader.formatName()
? "Filter: " + reader.filterName()
? ""

while reader.nextEntry()
    ? "Path: " + reader.entryPath()
    ? "Size: " + reader.entrySize()
    if reader.entryIsDir()
        ? "Type: Directory"
    but reader.entryIsFile()
        ? "Type: File"
    but reader.entryIsSymlink()
        ? "Type: Symlink"
    ok
    ? ""
end

reader.close()
reader.free()

# Cleanup
remove("test1.txt")
remove("test2.txt")
remove("test_archive.tar.gz")

? "Done"
