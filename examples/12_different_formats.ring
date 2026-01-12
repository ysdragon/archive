load "archive.ring"

? "Creating test.tar.gz..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
writer.open("test.tar.gz")
writer.addFile("readme.txt", "gzip compressed")
writer.close()
writer.free()
? "Done"

? "Creating test.tar.xz..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_XZ)
writer.open("test.tar.xz")
writer.addFile("readme.txt", "xz compressed")
writer.close()
writer.free()
? "Done"

? "Creating test.tar.zst..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_ZSTD)
writer.open("test.tar.zst")
writer.addFile("readme.txt", "zstd compressed")
writer.close()
writer.free()
? "Done"

? "Creating test.zip..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.open("test.zip")
writer.addFile("readme.txt", "zip format")
writer.close()
writer.free()
? "Done"

? "Creating test.7z..."
writer = new ArchiveWriter(ARCHIVE_FORMAT_7ZIP, ARCHIVE_COMPRESSION_LZMA)
writer.open("test.7z")
writer.addFile("readme.txt", "7zip format")
writer.close()
writer.free()
? "Done"

? ""
? "Created: test.tar.gz, test.tar.xz, test.tar.zst, test.zip, test.7z"

# Cleanup
remove("test.tar.gz")
remove("test.tar.xz")
remove("test.tar.zst")
remove("test.zip")
remove("test.7z")
