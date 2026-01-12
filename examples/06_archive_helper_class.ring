load "archive.ring"

# Example: Using the Archive helper class for common operations

archive = new Archive

# Get library version
? "Library version: " + archive.version()
? ""

# Create some test files
write("doc1.txt", "Document 1 content")
write("doc2.txt", "Document 2 content")
write("doc3.txt", "Document 3 content")

# Create archive using helper
? "Creating documents.tar.gz..."
archive.create("documents.tar.gz", ["doc1.txt", "doc2.txt", "doc3.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)

# List contents (returns list of [pathname, size, type, mtime])
? ""
? "Archive contents:"
aFiles = archive.list("documents.tar.gz")
for aFile in aFiles
    ? "  " + aFile[1] + " (" + aFile[2] + " bytes)"
next

# Read specific file
? ""
? "Reading doc2.txt from archive:"
cContent = archive.readFile("documents.tar.gz", "doc2.txt")
? cContent

# Extract all
? ""
? "Extracting to 'extracted/' folder..."
system("mkdir -p extracted")
archive.extract("documents.tar.gz", "extracted/")

? "Extracted files:"
aExtracted = dir("extracted")
for aFile in aExtracted
    if aFile[2] = false  # not a directory
        ? "  " + aFile[1]
    ok
next

# Cleanup
remove("doc1.txt")
remove("doc2.txt")
remove("doc3.txt")
system("rm -rf extracted")

? ""
? "Done"
