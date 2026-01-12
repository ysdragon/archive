load "archive.ring"

# Create a test archive first
write("hello.txt", "Hello from the archive!")
archive_create("test_archive.tar.gz", ["hello.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

cContent = archive_read_file("test_archive.tar.gz", "hello.txt")
? "Content of hello.txt:"
? cContent

# Cleanup
remove("hello.txt")
remove("test_archive.tar.gz")
