load "archive.ring"

write("file1.txt", "Content of file 1")
write("file2.txt", "Content of file 2")

archive_create("output.tar.gz", ["file1.txt", "file2.txt"], ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
? "Created output.tar.gz"

# Cleanup
remove("file1.txt")
remove("file2.txt")
remove("output.tar.gz")
