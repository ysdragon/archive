load "archive.ring"

# Example: Different encryption methods for ZIP archives

cPassword = "mypassword123"

# 1. AES-256 (strongest, default)
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase(cPassword)
writer.setEncryption(ARCHIVE_ENCRYPTION_AES256)
writer.open("encrypted_aes256.zip")
writer.addFile("secret.txt", "AES-256 encrypted content")
writer.close()
writer.free()
? "Created encrypted_aes256.zip (AES-256)"

# 2. AES-128
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase(cPassword)
writer.setEncryption(ARCHIVE_ENCRYPTION_AES128)
writer.open("encrypted_aes128.zip")
writer.addFile("secret.txt", "AES-128 encrypted content")
writer.close()
writer.free()
? "Created encrypted_aes128.zip (AES-128)"

# 3. Traditional PKWARE (weak, but compatible with standard unzip)
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase(cPassword)
writer.setEncryption(ARCHIVE_ENCRYPTION_ZIPCRYPT)
writer.open("encrypted_zipcrypt.zip")
writer.addFile("secret.txt", "ZipCrypt encrypted content")
writer.close()
writer.free()
? "Created encrypted_zipcrypt.zip (Traditional PKWARE)"

# 4. Using setOptions() for manual encryption control
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.open("encrypted_manual.zip")
writer.setOptions("zip:encryption=aes256")
archive_write_set_passphrase(writer.pHandle, cPassword)
writer.addFile("secret.txt", "Manual encryption setup")
writer.close()
writer.free()
? "Created encrypted_manual.zip (using setOptions)"

? ""
? "Password for all archives: " + cPassword
? ""
? "Note: AES encrypted files require 7z or WinZip to extract."
? "      ZipCrypt files work with standard unzip command."

# Cleanup
remove("encrypted_aes256.zip")
remove("encrypted_aes128.zip")
remove("encrypted_zipcrypt.zip")
remove("encrypted_manual.zip")
