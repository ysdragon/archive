/*
	archive.ring - OOP Wrapper for Ring Archive
*/

load "archive.rh"

class ArchiveReader

	pHandle = NULL
	pCurrentEntry = NULL

	func init cFilename
		pHandle = archive_read_new()
		archive_read_support_filter_all(pHandle)
		archive_read_support_format_all(pHandle)
		if cFilename != NULL
			open(cFilename)
		ok

	func open cFilename
		return archive_read_open_filename(pHandle, cFilename, 10240)

	func addPassphrase cPassword
		return archive_read_add_passphrase(pHandle, cPassword)

	func openMemory cData
		return archive_read_open_memory(pHandle, cData)

	func nextEntry
		pCurrentEntry = archive_read_next_header(pHandle)
		if isNull(pCurrentEntry)
			return false
		ok
		return true

	func entry
		return pCurrentEntry

	func entryPath
		if not isNull(pCurrentEntry)
			return archive_entry_pathname(pCurrentEntry)
		ok
		return NULL

	func entrySize
		if not isNull(pCurrentEntry)
			return archive_entry_size(pCurrentEntry)
		ok
		return false

	func entryIsDir
		if not isNull(pCurrentEntry)
			return archive_entry_is_directory(pCurrentEntry)
		ok
		return false

	func entryIsFile
		if not isNull(pCurrentEntry)
			return archive_entry_is_file(pCurrentEntry)
		ok
		return false

	func entryIsSymlink
		if not isNull(pCurrentEntry)
			return archive_entry_is_symlink(pCurrentEntry)
		ok
		return false

	func readData nSize
		return archive_read_data(pHandle, nSize)

	func readAll
		nSize = entrySize()
		if nSize > 0
			return readData(nSize)
		ok
		return NULL

	func skipData
		return archive_read_data_skip(pHandle)

	func close
		if not isNull(pHandle)
			archive_read_close(pHandle)
		ok

	func free
		if not isNull(pHandle)
			archive_read_free(pHandle)
			pHandle = NULL
		ok

	func errorString
		if not isNull(pHandle)
			return archive_error_string(pHandle)
		ok
		return NULL

	func formatName
		if not isNull(pHandle)
			return archive_format_name(pHandle)
		ok
		return NULL

	func filterName
		if not isNull(pHandle)
			return archive_filter_name(pHandle, 0)
		ok
		return NULL

	func errno
		if not isNull(pHandle)
			return archive_errno(pHandle)
		ok
		return false

	func readDataBlock
		if not isNull(pHandle)
			return archive_read_data_block(pHandle)
		ok
		return [NULL, 0, 0]


class ArchiveWriter

	pHandle = NULL
	pEntry = NULL
	nFormat = ARCHIVE_FORMAT_TAR
	nCompression = ARCHIVE_COMPRESSION_NONE
	cPassphrase = NULL
	cEncryption = "aes256"

	func init nFmt, nComp
		pHandle = archive_write_new()
		pEntry = archive_entry_new()
		if nFmt != NULL
			nFormat = nFmt
		ok
		if nComp != NULL
			nCompression = nComp
		ok

	func setFormat nFmt
		nFormat = nFmt
		return self

	func setCompression nComp
		nCompression = nComp
		return self

	func setPassphrase cPassword
		cPassphrase = cPassword
		return self

	func setEncryption cMethod
		# Options: "aes256", "aes128", "zipcrypt" (traditional)
		cEncryption = cMethod
		return self

	func open cFilename
		archive_write_set_format(pHandle, nFormat)
		archive_write_add_filter(pHandle, nCompression)
		if cPassphrase != NULL
			archive_write_set_options(pHandle, "zip:encryption=" + cEncryption)
			archive_write_set_passphrase(pHandle, cPassphrase)
		ok
		return archive_write_open_filename(pHandle, cFilename)

	func openMemory
		archive_write_set_format(pHandle, nFormat)
		archive_write_add_filter(pHandle, nCompression)
		if cPassphrase != NULL
			archive_write_set_options(pHandle, "zip:encryption=" + cEncryption)
			archive_write_set_passphrase(pHandle, cPassphrase)
		ok
		return archive_write_open_memory(pHandle)

	func addFile cPath, cData
		archive_entry_clear(pEntry)
		archive_entry_set_pathname(pEntry, cPath)
		archive_entry_set_size(pEntry, len(cData))
		archive_entry_set_filetype(pEntry, ARCHIVE_ENTRY_FILE)
		archive_entry_set_perm(pEntry, 0644)
		
		archive_write_header(pHandle, pEntry)
		archive_write_data(pHandle, cData)
		archive_write_finish_entry(pHandle)
		return self

	func addDirectory cPath
		archive_entry_clear(pEntry)
		archive_entry_set_pathname(pEntry, cPath)
		archive_entry_set_size(pEntry, 0)
		archive_entry_set_filetype(pEntry, ARCHIVE_ENTRY_DIR)
		archive_entry_set_perm(pEntry, 0755)
		
		archive_write_header(pHandle, pEntry)
		archive_write_finish_entry(pHandle)
		return self

	func addSymlink cPath, cTarget
		archive_entry_clear(pEntry)
		archive_entry_set_pathname(pEntry, cPath)
		archive_entry_set_size(pEntry, 0)
		archive_entry_set_filetype(pEntry, ARCHIVE_ENTRY_SYMLINK)
		archive_entry_set_symlink(pEntry, cTarget)
		archive_entry_set_perm(pEntry, 0777)
		
		archive_write_header(pHandle, pEntry)
		archive_write_finish_entry(pHandle)
		return self

	func addFileFromDisk cArchivePath, cDiskPath
		cData = read(cDiskPath)
		return addFile(cArchivePath, cData)

	func close
		if not isNull(pHandle)
			archive_write_close(pHandle)
		ok

	func free
		if not isNull(pEntry)
			archive_entry_free(pEntry)
			pEntry = NULL
		ok
		if not isNull(pHandle)
			archive_write_free(pHandle)
			pHandle = NULL
		ok

	func errorString
		if not isNull(pHandle)
			return archive_error_string(pHandle)
		ok
		return NULL

	func errno
		if not isNull(pHandle)
			return archive_errno(pHandle)
		ok
		return false

	func filterName
		if not isNull(pHandle)
			return archive_filter_name(pHandle, 0)
		ok
		return NULL

	func setOptions cOptions
		if not isNull(pHandle)
			return archive_write_set_options(pHandle, cOptions)
		ok
		return ARCHIVE_FAILED


class Archive

	func extract cArchivePath, cDestPath
		return archive_extract(cArchivePath, cDestPath)

	func list cArchivePath
		return archive_list(cArchivePath)

	func create cArchivePath, aFiles, nFormat, nCompression
		if nFormat = NULL
			nFormat = ARCHIVE_FORMAT_TAR
		ok
		if nCompression = NULL
			nCompression = ARCHIVE_COMPRESSION_GZIP
		ok
		return archive_create(cArchivePath, aFiles, nFormat, nCompression)

	func readFile cArchivePath, cEntryPath
		return archive_read_file(cArchivePath, cEntryPath)

	func version
		return archive_version_string()


class ArchiveEntry

	pEntry = NULL
	lOwned = true

	func init
		pEntry = archive_entry_new()
		lOwned = true

	func wrap pExisting
		if not isNull(pEntry) and lOwned
			archive_entry_free(pEntry)
		ok
		pEntry = pExisting
		lOwned = false
		return self

	func clear
		if not isNull(pEntry)
			archive_entry_clear(pEntry)
		ok
		return self

	func clone
		if not isNull(pEntry)
			oEntry = new ArchiveEntry()
			oEntry.wrap(archive_entry_clone(pEntry))
			return oEntry
		ok
		return NULL

	func pathname
		if not isNull(pEntry)
			return archive_entry_pathname(pEntry)
		ok
		return NULL

	func setPathname cPath
		if not isNull(pEntry)
			archive_entry_set_pathname(pEntry, cPath)
		ok
		return self

	func size
		if not isNull(pEntry)
			return archive_entry_size(pEntry)
		ok
		return false

	func setSize nSize
		if not isNull(pEntry)
			archive_entry_set_size(pEntry, nSize)
		ok
		return self

	func filetype
		if not isNull(pEntry)
			return archive_entry_filetype(pEntry)
		ok
		return ARCHIVE_ENTRY_FILE

	func setFiletype nType
		if not isNull(pEntry)
			archive_entry_set_filetype(pEntry, nType)
		ok
		return self

	func perm
		if not isNull(pEntry)
			return archive_entry_perm(pEntry)
		ok
		return false

	func setPerm nPerm
		if not isNull(pEntry)
			archive_entry_set_perm(pEntry, nPerm)
		ok
		return self

	func mtime
		if not isNull(pEntry)
			return archive_entry_mtime(pEntry)
		ok
		return false

	func setMtime nTime
		if not isNull(pEntry)
			archive_entry_set_mtime(pEntry, nTime, 0)
		ok
		return self

	func symlink
		if not isNull(pEntry)
			return archive_entry_symlink(pEntry)
		ok
		return NULL

	func setSymlink cTarget
		if not isNull(pEntry)
			archive_entry_set_symlink(pEntry, cTarget)
		ok
		return self

	func isDirectory
		if not isNull(pEntry)
			return archive_entry_is_directory(pEntry)
		ok
		return false

	func isFile
		if not isNull(pEntry)
			return archive_entry_is_file(pEntry)
		ok
		return false

	func isSymlink
		if not isNull(pEntry)
			return archive_entry_is_symlink(pEntry)
		ok
		return false

	func handle
		return pEntry

	func free
		if not isNull(pEntry) and lOwned
			archive_entry_free(pEntry)
			pEntry = NULL
		ok
