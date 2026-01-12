load "archive.ring"

aEntries = archive_list("test_archive.tar.gz")

for entry in aEntries
    ? entry[1]
next
