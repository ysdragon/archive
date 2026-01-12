load "archive.ring"

reader = new ArchiveReader("test_archive.tar.gz")

while reader.nextEntry()
    if reader.entryIsFile()
        ? "=== " + reader.entryPath() + " ==="
        ? reader.readAll()
        ? ""
    ok
end

reader.close()
reader.free()

? "Done"
