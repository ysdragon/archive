load "archive.ring"

reader = new ArchiveReader("test_archive.tar.gz")

# Show archive format and filter info
? "Format: " + reader.formatName()
? "Filter: " + reader.filterName()
? ""

while reader.nextEntry()
    ? "Path: " + reader.entryPath()
    ? "Size: " + reader.entrySize()
    if reader.entryIsDir()
        ? "Type: Directory"
    but reader.entryIsFile()
        ? "Type: File"
    but reader.entryIsSymlink()
        ? "Type: Symlink"
    ok
    ? ""
end

reader.close()
reader.free()

? "Done"
