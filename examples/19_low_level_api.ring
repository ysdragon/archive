load "archive.ring"

# Create a test archive first
write("api_test1.txt", "API test content 1")
write("api_test2.txt", "API test content 2")
archive_create("test_archive.tar.gz", ["api_test1.txt", "api_test2.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

# Part 1: Low-level C API usage
? "=== Low-level C API ==="
pRead = archive_read_new()
archive_read_support_filter_all(pRead)
archive_read_support_format_all(pRead)
archive_read_open_filename(pRead, "test_archive.tar.gz", 10240)

pEntry = archive_read_next_header(pRead)
while not isnull(pEntry)
    ? "Entry: " + archive_entry_pathname(pEntry)
    ? "  Size: " + archive_entry_size(pEntry)
    ? "  Perm: " + archive_entry_perm(pEntry)
    archive_read_data_skip(pRead)
    pEntry = archive_read_next_header(pRead)
end

archive_read_close(pRead)
archive_read_free(pRead)

? ""

# Part 2: Block-by-block reading with OOP
? "=== Block-by-block reading (OOP) ==="
reader = new ArchiveReader("test_archive.tar.gz")

while reader.nextEntry()
    if reader.entryIsFile() and reader.entrySize() > 0
        ? "Reading " + reader.entryPath() + " in blocks:"
        nTotal = 0
        aBlock = reader.readDataBlock()
        while isList(aBlock) and len(aBlock[1]) > 0
            nTotal += len(aBlock[1])
            ? "  Block: " + len(aBlock[1]) + " bytes at offset " + aBlock[2]
            aBlock = reader.readDataBlock()
        end
        ? "  Total read: " + nTotal + " bytes"
    ok
end

reader.close()
reader.free()

# Cleanup
remove("api_test1.txt")
remove("api_test2.txt")
remove("test_archive.tar.gz")

? ""
? "Done"
