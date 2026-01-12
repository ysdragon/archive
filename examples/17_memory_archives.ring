load "archive.ring"

# Example: Working with archives in memory

# Part 1: Read archive from memory
? "=== Reading archive from memory ==="
cArchiveData = read("test_archive.tar.gz")
? "Loaded archive into memory: " + len(cArchiveData) + " bytes"
? ""

reader = new ArchiveReader(NULL)
reader.openMemory(cArchiveData)

? "Contents from memory:"
while reader.nextEntry()
    ? "  " + reader.entryPath()
end
reader.close()
reader.free()

? ""

# Part 2: Write archive to memory
? "=== Writing archive to memory ==="
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
aResult = writer.openMemory()

if isList(aResult)
    writer.addFile("hello.txt", "Hello from memory!")
    writer.addFile("data.txt", "Some data content")
    writer.close()
    ? "Archive created in memory successfully"
ok
writer.free()

? ""
? "Done"
