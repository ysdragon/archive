load "archive.ring"

if archive_extract("test_archive.tar.gz", "./extracted")
    ? "Extraction successful"
else
    ? "Extraction failed"
ok
