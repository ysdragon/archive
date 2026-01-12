load "archive.ring"

cContent = archive_read_file("test_archive.tar.gz", "hello.txt")
? "Content of hello.txt:"
? cContent
