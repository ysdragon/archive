load "archive.ring"

write("realfile.txt", "This is a real file on disk")

writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
writer.open("from_disk.tar.gz")
writer.addFileFromDisk("archived_file.txt", "realfile.txt")
writer.close()
writer.free()

? "Created from_disk.tar.gz with realfile.txt inside"

# Cleanup
remove("realfile.txt")
remove("from_disk.tar.gz")
