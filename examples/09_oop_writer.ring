load "archive.ring"

writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
writer.open("myarchive.tar.gz")

writer.addFile("hello.txt", "Hello, World!")
writer.addFile("data.json", '{"name": "test"}')
writer.addDirectory("subdir/")
writer.addFile("subdir/nested.txt", "Nested content")

writer.close()
writer.free()

? "Created myarchive.tar.gz"

# Cleanup
remove("myarchive.tar.gz")
