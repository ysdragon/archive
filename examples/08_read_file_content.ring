load "archive.ring"

# Create a test archive first
write("file1.txt", "Content of file 1")
write("file2.txt", "Content of file 2")
archive_create("test_archive.tar.gz", ["file1.txt", "file2.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

reader = new ArchiveReader("test_archive.tar.gz")

while reader.nextEntry()
    if reader.entryIsFile()
        ? "=== " + reader.entryPath() + " ==="
        ? reader.readAll()
        ? ""
    ok
end

reader.close()
reader.free()

# Cleanup
remove("file1.txt")
remove("file2.txt")
remove("test_archive.tar.gz")

? "Done"
