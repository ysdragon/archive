load "archive.ring"

cPassword = "secretpassword"

writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase(cPassword)
writer.open("encrypted.zip")
writer.addFile("secret.txt", "This is secret content!")
writer.close()
writer.free()

? "Created encrypted.zip with password: " + cPassword
