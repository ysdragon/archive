load "archive.ring"

# Example: Reading raw data with archive_read_data

# Create a test archive first
write("data1.txt", "Raw data content 1")
write("data2.txt", "Raw data content 2")
archive_create("test_archive.tar.gz", ["data1.txt", "data2.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

pRead = archive_read_new()
archive_read_support_filter_all(pRead)
archive_read_support_format_all(pRead)
archive_read_open_filename(pRead, "test_archive.tar.gz", 10240)

? "Reading file contents with raw API:"
? ""

pEntry = archive_read_next_header(pRead)
while not isnull(pEntry)
    cPath = archive_entry_pathname(pEntry)
    nSize = archive_entry_size(pEntry)
    
    if archive_entry_is_file(pEntry)
        # Read file data in chunks
        cData = archive_read_data(pRead, nSize)
        ? "=== " + cPath + " (" + nSize + " bytes) ==="
        ? cData
        ? ""
    else
        archive_read_data_skip(pRead)
    ok
    
    pEntry = archive_read_next_header(pRead)
end

archive_read_close(pRead)
archive_read_free(pRead)

# Cleanup
remove("data1.txt")
remove("data2.txt")
remove("test_archive.tar.gz")

? "Done"
