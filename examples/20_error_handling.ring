load "archive.ring"

reader = new ArchiveReader(NULL)
nResult = reader.open("nonexistent.tar.gz")

if nResult != ARCHIVE_OK
    ? "Error opening archive"
    ? "Error code: " + reader.errno()
    ? "Error details: " + reader.errorString()
ok

reader.free()
