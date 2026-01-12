load "archive.ring"

# Example: Different archive formats and compressions

write("sample.txt", "Sample content for testing different formats")

# TAR with BZIP2
? "Creating test.tar.bz2 (TAR + BZIP2)..."
archive_create("test.tar.bz2", ["sample.txt"], ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_BZIP2)

# TAR with LZ4
? "Creating test.tar.lz4 (TAR + LZ4)..."
archive_create("test.tar.lz4", ["sample.txt"], ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_LZ4)

# TAR with LZMA
? "Creating test.tar.lzma (TAR + LZMA)..."
archive_create("test.tar.lzma", ["sample.txt"], ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_LZMA)

# CPIO format
? "Creating test.cpio (CPIO + GZIP)..."
archive_create("test.cpio.gz", ["sample.txt"], ARCHIVE_FORMAT_CPIO, ARCHIVE_COMPRESSION_GZIP)

# Verify all created
? ""
? "Verifying archives:"
aArchives = ["test.tar.bz2", "test.tar.lz4", "test.tar.lzma", "test.cpio.gz"]
for cArchive in aArchives
    aContents = archive_list(cArchive)
    ? "  " + cArchive + ": " + len(aContents) + " file(s)"
next

# Cleanup
remove("sample.txt")

? ""
? "Done"
