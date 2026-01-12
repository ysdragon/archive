load "archive.ring"

# Example: Detailed error handling with errno and error_string

? "=== Test 1: Opening non-existent file ==="
pRead = archive_read_new()
archive_read_support_filter_all(pRead)
archive_read_support_format_all(pRead)
nResult = archive_read_open_filename(pRead, "nonexistent_file.tar.gz", 10240)

if nResult != ARCHIVE_OK
    ? "Error code: " + nResult
    ? "Errno: " + archive_errno(pRead)
    ? "Error string: " + archive_error_string(pRead)
ok
archive_read_free(pRead)

? ""
? "=== Test 2: Using OOP error handling ==="
reader = new ArchiveReader(NULL)
nResult = reader.open("another_missing.zip")

if nResult != ARCHIVE_OK
    ? "Failed to open archive"
    ? "Errno: " + reader.errno()
    ? "Error: " + reader.errorString()
ok
reader.free()

? ""
? "=== Test 3: Format detection info (OOP) ==="

# Create a test archive for this test
write("error_test.txt", "Error handling test")
archive_create("test_archive.tar.gz", ["error_test.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

reader = new ArchiveReader("test_archive.tar.gz")
reader.nextEntry()

? "Format name: " + reader.formatName()
? "Filter name: " + reader.filterName()

reader.close()
reader.free()

# Cleanup
remove("error_test.txt")
remove("test_archive.tar.gz")

? ""
? "Done"
