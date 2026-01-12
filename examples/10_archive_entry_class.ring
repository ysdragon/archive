load "archive.ring"

# Example: Using ArchiveEntry class directly

# Create entry from scratch
entry = new ArchiveEntry(NULL)
entry.setPathname("myfile.txt")
entry.setSize(100)
entry.setFiletype(ARCHIVE_ENTRY_FILE)
entry.setPerm(0644)
entry.setMtime(clock())

? "Entry created:"
? "  Path: " + entry.pathname()
? "  Size: " + entry.size()
? "  Perm: " + entry.perm()
? "  Type: File = " + entry.isFile()
? ""

# Create directory entry
dirEntry = new ArchiveEntry(NULL)
dirEntry.setPathname("mydir/")
dirEntry.setFiletype(ARCHIVE_ENTRY_DIR)
dirEntry.setPerm(0755)

? "Directory entry:"
? "  Path: " + dirEntry.pathname()
? "  Is Dir: " + dirEntry.isDirectory()
? ""

# Create symlink entry
linkEntry = new ArchiveEntry(NULL)
linkEntry.setPathname("mylink")
linkEntry.setFiletype(ARCHIVE_ENTRY_SYMLINK)
linkEntry.setSymlink("target.txt")

? "Symlink entry:"
? "  Path: " + linkEntry.pathname()
? "  Target: " + linkEntry.symlink()
? "  Is Symlink: " + linkEntry.isSymlink()
? ""

# Clone an entry
cloned = entry.clone()
? "Cloned entry path: " + cloned.pathname()

# Clear and reuse
entry.clear()
entry.setPathname("reused.txt")
? "Reused entry path: " + entry.pathname()

entry.free()
dirEntry.free()
linkEntry.free()
cloned.free()

? "Done"
