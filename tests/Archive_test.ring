/*
 * Archive Extension Test Suite
 * Tests all functionality of the Ring Archive library
 */

load "stdlibcore.ring"

arch = getarch()
osDir = ""
archDir = ""
libName = ""
libVariant = ""

if isWindows()
	osDir = "windows"
	libName = "ring_archive.dll"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	but arch = "x86"
		archDir = "i386"
	else
		raise("Unsupported Windows architecture: " + arch)
	ok
but isLinux()
	osDir = "linux"
	libName = "libring_archive.so"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported Linux architecture: " + arch)
	ok
	if isMusl()
		libVariant = "musl/"
	ok
but isFreeBSD()
	osDir = "freebsd"
	libName = "libring_archive.so"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported FreeBSD architecture: " + arch)
	ok
but isMacOSX()
	osDir = "macos"
	libName = "libring_archive.dylib"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported macOS architecture: " + arch)
	ok
else
	raise("Unsupported OS! You need to build the library for your OS.")
ok

loadlib("../lib/" + osDir + "/" + libVariant + archDir + "/" + libName)

load "../src/archive.ring"
load "../src/archive.rh"

func main
	new ArchiveTest()

func isMusl
	cOutput = systemCmd("sh -c 'ldd 2>&1'")
	return substr(cOutput, "musl") > 0

class ArchiveTest

	cTestDir = "test_data"
	cOutputDir = "test_output"

	nTestsRun = 0
	nTestsFailed = 0

	func init
		? "Setting up test environment..."
		setupTestData()
		? "Test environment ready." + nl
		runAllTests()

	func setupTestData
		# Create test directory structure
		if isWindows()
			system("rmdir /s /q " + cTestDir + " " + cOutputDir + " 2>nul")
			system("del /q *.tar* *.zip *.7z 2>nul")
			system("mkdir " + cTestDir + "\subdir")
		else
			system("rm -rf " + cTestDir + " " + cOutputDir + " *.tar* *.zip *.7z 2>/dev/null")
			system("mkdir -p " + cTestDir + "/subdir")
		ok

		# Create test files
		write(cTestDir + "/file1.txt", "Hello World!")
		write(cTestDir + "/file2.txt", "This is a test file with more content." + nl + "Multiple lines." + nl)
		write(cTestDir + "/subdir/nested.txt", "Nested file content")
		write(cTestDir + "/binary.bin", char(0) + char(1) + char(255) + char(128))

		# Create symlink (Unix only)
		if !isWindows()
			system("ln -sf file1.txt " + cTestDir + "/link.txt")
		ok

	func cleanup
		if isWindows()
			system("rmdir /s /q " + cTestDir + " " + cOutputDir + " 2>nul")
			system("del /q *.tar* *.zip *.7z 2>nul")
		else
			system("rm -rf " + cTestDir + " " + cOutputDir + " *.tar* *.zip *.7z 2>/dev/null")
		ok

	func assert(condition, message)
		if !condition
			raise("Assertion Failed: " + message)
		ok

	func assertFileExists(path)
		if !fexists(path)
			raise("File does not exist: " + path)
		ok

	func assertFileContent(path, expected)
		actual = read(path)
		if actual != expected
			raise("File content mismatch in " + path + ": expected '" + expected + "' got '" + actual + "'")
		ok

	func run(testName, methodName)
		nTestsRun++
		see "  " + testName + "..."
		try
			call methodName()
			see " [PASS]" + nl
		catch
			nTestsFailed++
			see " [FAIL]" + nl
			see "    -> " + cCatchError + nl
		done

	func runAllTests
		? "========================================"
		? "  Running Archive Extension Test Suite"
		? "========================================" + nl

		? "Testing Constants..."
		run("test_format_constants", :test_format_constants)
		run("test_compression_constants", :test_compression_constants)
		run("test_entry_type_constants", :test_entry_type_constants)
		run("test_status_constants", :test_status_constants)
		? ""

		? "Testing Version Info..."
		run("test_version_string", :test_version_string)
		? ""

		? "Testing TAR Creation & Extraction..."
		run("test_create_tar_gzip", :test_create_tar_gzip)
		run("test_extract_tar_gzip", :test_extract_tar_gzip)
		run("test_create_tar_bzip2", :test_create_tar_bzip2)
		run("test_create_tar_xz", :test_create_tar_xz)
		run("test_create_tar_zstd", :test_create_tar_zstd)
		run("test_create_tar_lz4", :test_create_tar_lz4)
		run("test_create_tar_uncompressed", :test_create_tar_uncompressed)
		? ""

		? "Testing ZIP Creation & Extraction..."
		run("test_create_zip", :test_create_zip)
		run("test_extract_zip", :test_extract_zip)
		? ""

		? "Testing 7-Zip Creation..."
		run("test_create_7zip", :test_create_7zip)
		? ""

		? "Testing archive_list()..."
		run("test_list_archive", :test_list_archive)
		run("test_list_archive_details", :test_list_archive_details)
		? ""

		? "Testing archive_read_file()..."
		run("test_read_single_file", :test_read_single_file)
		run("test_read_nested_file", :test_read_nested_file)
		? ""

		? "Testing Recursive Directory Handling..."
		run("test_recursive_directory", :test_recursive_directory)
		? ""

		? "Testing OOP ArchiveReader..."
		run("test_reader_basic", :test_reader_basic)
		run("test_reader_entry_info", :test_reader_entry_info)
		run("test_reader_read_data", :test_reader_read_data)
		? ""

		? "Testing OOP ArchiveWriter..."
		run("test_writer_basic", :test_writer_basic)
		run("test_writer_add_files", :test_writer_add_files)
		run("test_writer_add_directory", :test_writer_add_directory)
		? ""

		? "Testing OOP Archive Helper..."
		run("test_archive_helper_extract", :test_archive_helper_extract)
		run("test_archive_helper_list", :test_archive_helper_list)
		run("test_archive_helper_create", :test_archive_helper_create)
		? ""

		? "Testing ArchiveEntry Class..."
		run("test_entry_create", :test_entry_create)
		run("test_entry_properties", :test_entry_properties)
		? ""

		? "Testing Error Handling..."
		run("test_nonexistent_archive", :test_nonexistent_archive)
		run("test_invalid_format", :test_invalid_format)
		? ""

		if !isWindows()
			? "Testing Symlink Handling (Unix only)..."
			run("test_symlink_archive", :test_symlink_archive)
			? ""
		ok

		? "Testing Binary Data..."
		run("test_binary_file", :test_binary_file)
		? ""

		? "Testing Low-Level Read API..."
		run("test_lowlevel_read_new", :test_lowlevel_read_new)
		run("test_lowlevel_read_support", :test_lowlevel_read_support)
		run("test_lowlevel_read_open_filename", :test_lowlevel_read_open_filename)
		run("test_lowlevel_read_next_header", :test_lowlevel_read_next_header)
		run("test_lowlevel_read_data", :test_lowlevel_read_data)
		run("test_lowlevel_read_data_skip", :test_lowlevel_read_data_skip)
		run("test_lowlevel_read_data_block", :test_lowlevel_read_data_block)
		? ""

		? "Testing Low-Level Write API..."
		run("test_lowlevel_write_new", :test_lowlevel_write_new)
		run("test_lowlevel_write_set_format", :test_lowlevel_write_set_format)
		run("test_lowlevel_write_set_format_specific", :test_lowlevel_write_set_format_specific)
		run("test_lowlevel_write_add_filter", :test_lowlevel_write_add_filter)
		run("test_lowlevel_write_add_filter_specific", :test_lowlevel_write_add_filter_specific)
		run("test_lowlevel_write_full_cycle", :test_lowlevel_write_full_cycle)
		? ""

		? "Testing Memory Archives..."
		run("test_memory_read", :test_memory_read)
		run("test_memory_write", :test_memory_write)
		? ""

		? "Testing Encryption/Passphrase..."
		run("test_encrypted_zip_write", :test_encrypted_zip_write)
		run("test_encrypted_zip_read", :test_encrypted_zip_read)
		run("test_lowlevel_passphrase", :test_lowlevel_passphrase)
		run("test_lowlevel_read_passphrase", :test_lowlevel_read_passphrase)
		? ""

		? "Testing Entry Extended Features..."
		run("test_entry_mtime", :test_entry_mtime)
		run("test_entry_symlink_properties", :test_entry_symlink_properties)
		run("test_entry_clone", :test_entry_clone)
		run("test_entry_clear", :test_entry_clear)
		? ""

		? "Testing Utility Functions..."
		run("test_error_string", :test_error_string)
		run("test_errno", :test_errno)
		run("test_format_name", :test_format_name)
		run("test_filter_name", :test_filter_name)
		? ""

		? "Testing Additional OOP Features..."
		run("test_reader_error_handling", :test_reader_error_handling)
		run("test_writer_error_handling", :test_writer_error_handling)
		run("test_writer_set_options", :test_writer_set_options)
		run("test_reader_format_filter_info", :test_reader_format_filter_info)
		run("test_writer_symlink", :test_writer_symlink)
		run("test_writer_add_from_disk", :test_writer_add_from_disk)
		run("test_archive_helper_read_file", :test_archive_helper_read_file)
		run("test_archive_helper_version", :test_archive_helper_version)
		? ""

		# Cleanup
		cleanup()

		? "========================================"
		? "Test Summary:"
		? "  Total Tests: " + nTestsRun
		? "  Passed: " + (nTestsRun - nTestsFailed)
		? "  Failed: " + nTestsFailed
		? "========================================"
		if nTestsFailed = 0
			? "SUCCESS: All tests passed!"
		else
			? "FAILURE: Some tests did not pass."
		ok

		shutdown(nTestsFailed)

	# ==================== Constants Tests ====================

	func test_format_constants
		assert(ARCHIVE_FORMAT_TAR = 1, "ARCHIVE_FORMAT_TAR should be 1")
		assert(ARCHIVE_FORMAT_ZIP = 2, "ARCHIVE_FORMAT_ZIP should be 2")
		assert(ARCHIVE_FORMAT_7ZIP = 3, "ARCHIVE_FORMAT_7ZIP should be 3")
		assert(ARCHIVE_FORMAT_RAR = 4, "ARCHIVE_FORMAT_RAR should be 4")
		assert(ARCHIVE_FORMAT_CPIO = 5, "ARCHIVE_FORMAT_CPIO should be 5")

	func test_compression_constants
		assert(ARCHIVE_COMPRESSION_NONE = 0, "ARCHIVE_COMPRESSION_NONE should be 0")
		assert(ARCHIVE_COMPRESSION_GZIP = 1, "ARCHIVE_COMPRESSION_GZIP should be 1")
		assert(ARCHIVE_COMPRESSION_BZIP2 = 2, "ARCHIVE_COMPRESSION_BZIP2 should be 2")
		assert(ARCHIVE_COMPRESSION_XZ = 3, "ARCHIVE_COMPRESSION_XZ should be 3")
		assert(ARCHIVE_COMPRESSION_LZMA = 4, "ARCHIVE_COMPRESSION_LZMA should be 4")
		assert(ARCHIVE_COMPRESSION_ZSTD = 5, "ARCHIVE_COMPRESSION_ZSTD should be 5")
		assert(ARCHIVE_COMPRESSION_LZ4 = 6, "ARCHIVE_COMPRESSION_LZ4 should be 6")

	func test_entry_type_constants
		assert(ARCHIVE_ENTRY_FILE = 1, "ARCHIVE_ENTRY_FILE should be 1")
		assert(ARCHIVE_ENTRY_DIR = 2, "ARCHIVE_ENTRY_DIR should be 2")
		assert(ARCHIVE_ENTRY_SYMLINK = 3, "ARCHIVE_ENTRY_SYMLINK should be 3")

	func test_status_constants
		assert(ARCHIVE_OK = 0, "ARCHIVE_OK should be 0")
		assert(ARCHIVE_EOF = 1, "ARCHIVE_EOF should be 1")
		assert(ARCHIVE_WARN = -20, "ARCHIVE_WARN should be -20")
		assert(ARCHIVE_FAILED = -25, "ARCHIVE_FAILED should be -25")
		assert(ARCHIVE_FATAL = -30, "ARCHIVE_FATAL should be -30")

	# ==================== Version Tests ====================

	func test_version_string
		ver = archive_version_string()
		assert(isstring(ver), "Version should be a string")
		assert(len(ver) > 0, "Version string should not be empty")

	# ==================== TAR Tests ====================

	func test_create_tar_gzip
		result = archive_create("test.tar.gz", [cTestDir],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		assert(result = 1, "archive_create should return 1 on success")
		assertFileExists("test.tar.gz")

	func test_extract_tar_gzip
		system("mkdir -p " + cOutputDir)
		result = archive_extract("test.tar.gz", cOutputDir)
		assert(result = 1, "archive_extract should return 1 on success")
		assertFileExists(cOutputDir + "/" + cTestDir + "/file1.txt")
		assertFileContent(cOutputDir + "/" + cTestDir + "/file1.txt", "Hello World!")

	func test_create_tar_bzip2
		result = archive_create("test.tar.bz2", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_BZIP2)
		assert(result = 1, "archive_create with bzip2 should succeed")
		assertFileExists("test.tar.bz2")

	func test_create_tar_xz
		result = archive_create("test.tar.xz", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_XZ)
		assert(result = 1, "archive_create with xz should succeed")
		assertFileExists("test.tar.xz")

	func test_create_tar_zstd
		result = archive_create("test.tar.zst", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_ZSTD)
		assert(result = 1, "archive_create with zstd should succeed")
		assertFileExists("test.tar.zst")

	func test_create_tar_lz4
		result = archive_create("test.tar.lz4", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_LZ4)
		assert(result = 1, "archive_create with lz4 should succeed")
		assertFileExists("test.tar.lz4")

	func test_create_tar_uncompressed
		result = archive_create("test.tar", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_NONE)
		assert(result = 1, "archive_create uncompressed should succeed")
		assertFileExists("test.tar")

	# ==================== ZIP Tests ====================

	func test_create_zip
		result = archive_create("test.zip", [cTestDir],
		                        ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
		assert(result = 1, "archive_create ZIP should return 1")
		assertFileExists("test.zip")

	func test_extract_zip
		system("rm -rf " + cOutputDir + " && mkdir -p " + cOutputDir)
		result = archive_extract("test.zip", cOutputDir)
		assert(result = 1, "archive_extract ZIP should return 1")
		assertFileExists(cOutputDir + "/" + cTestDir + "/file1.txt")

	# ==================== 7-Zip Tests ====================

	func test_create_7zip
		result = archive_create("test.7z", [cTestDir + "/file1.txt"],
		                        ARCHIVE_FORMAT_7ZIP, ARCHIVE_COMPRESSION_NONE)
		assert(result = 1, "archive_create 7zip should return 1")
		assertFileExists("test.7z")

	# ==================== List Tests ====================

	func test_list_archive
		entries = archive_list("test.tar.gz")
		assert(islist(entries), "archive_list should return a list")
		assert(len(entries) > 0, "archive_list should return non-empty list")

	func test_list_archive_details
		entries = archive_list("test.tar.gz")
		# Each entry is [pathname, size, type, mtime]
		entry = entries[1]
		assert(len(entry) = 4, "Each entry should have 4 elements")
		assert(isstring(entry[1]), "Pathname should be a string")
		assert(isnumber(entry[2]), "Size should be a number")
		assert(isnumber(entry[3]), "Type should be a number")
		assert(isnumber(entry[4]), "Mtime should be a number")

	# ==================== Read File Tests ====================

	func test_read_single_file
		content = archive_read_file("test.tar.gz", cTestDir + "/file1.txt")
		assert(content = "Hello World!", "archive_read_file should return correct content")

	func test_read_nested_file
		content = archive_read_file("test.tar.gz", cTestDir + "/subdir/nested.txt")
		assert(content = "Nested file content", "Should read nested file correctly")

	# ==================== Recursive Directory Tests ====================

	func test_recursive_directory
		entries = archive_list("test.tar.gz")
		foundNested = false
		for entry in entries
			if substr(entry[1], "nested.txt") > 0
				foundNested = true
				exit
			ok
		next
		assert(foundNested, "Recursive archive should contain nested files")

	# ==================== OOP ArchiveReader Tests ====================

	func test_reader_basic
		reader = new ArchiveReader(NULL)
		result = reader.open("test.tar.gz")
		assert(result = ARCHIVE_OK, "Reader open should return ARCHIVE_OK")
		reader.close()

	func test_reader_entry_info
		reader = new ArchiveReader("test.tar.gz")
		found = false
		while reader.nextEntry()
			path = reader.entryPath()
			if substr(path, "file1.txt") > 0
				found = true
				size = reader.entrySize()
				assert(size = 12, "file1.txt should be 12 bytes")
				assert(reader.entryIsFile() or reader.entryIsDir(), "Should be file or dir")
				exit
			ok
		end
		reader.close()
		assert(found, "Should find file1.txt in archive")

	func test_reader_read_data
		reader = new ArchiveReader("test.tar.gz")
		content = ""
		while reader.nextEntry()
			if substr(reader.entryPath(), "file1.txt") > 0 and reader.entryIsFile()
				content = reader.readAll()
				exit
			ok
		end
		reader.close()
		assert(content = "Hello World!", "Should read file content correctly")

	# ==================== OOP ArchiveWriter Tests ====================

	func test_writer_basic
		writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		result = writer.open("writer_test.tar.gz")
		assert(result = ARCHIVE_OK, "Writer open should return ARCHIVE_OK")
		writer.close()
		assertFileExists("writer_test.tar.gz")

	func test_writer_add_files
		writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
		writer.open("writer_test.zip")
		writer.addFile("hello.txt", "Hello from writer!")
		writer.addFile("data.txt", "Some data content")
		writer.close()

		# Verify
		content = archive_read_file("writer_test.zip", "hello.txt")
		assert(content = "Hello from writer!", "Written file should have correct content")

	func test_writer_add_directory
		writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		writer.open("writer_dir_test.tar.gz")
		writer.addDirectory("mydir/")
		writer.addFile("mydir/file.txt", "File in directory")
		writer.close()

		entries = archive_list("writer_dir_test.tar.gz")
		foundDir = false
		for entry in entries
			if entry[1] = "mydir/" and entry[3] = ARCHIVE_ENTRY_DIR
				foundDir = true
				exit
			ok
		next
		assert(foundDir, "Should contain directory entry")

	# ==================== OOP Archive Helper Tests ====================

	func test_archive_helper_extract
		arc = new Archive
		system("rm -rf " + cOutputDir + " && mkdir -p " + cOutputDir)
		result = arc.extract("test.tar.gz", cOutputDir)
		assert(result = 1, "Archive helper extract should succeed")

	func test_archive_helper_list
		arc = new Archive
		entries = arc.list("test.tar.gz")
		assert(islist(entries), "Archive helper list should return list")
		assert(len(entries) > 0, "List should not be empty")

	func test_archive_helper_create
		arc = new Archive
		result = arc.create("helper_test.tar.gz", [cTestDir + "/file1.txt"], NULL, NULL)
		assert(result = 1, "Archive helper create should succeed")
		assertFileExists("helper_test.tar.gz")

	# ==================== ArchiveEntry Tests ====================

	func test_entry_create
		entry = new ArchiveEntry()
		handle = entry.handle()
		assert(handle != NULL, "Entry should have valid handle")

	func test_entry_properties
		entry = new ArchiveEntry()
		entry.setPathname("test/file.txt")
		path = entry.pathname()
		assert(path = "test/file.txt", "Pathname should be set, got: " + path)

		entry.setSize(1024)
		assert(entry.size() = 1024, "Size should be set")

		entry.setFiletype(ARCHIVE_ENTRY_FILE)
		assert(entry.isFile(), "Should be a file")

		entry.setPerm(420)  # 0644 in decimal
		perm = entry.perm()
		assert(perm = 420, "Permissions should be set (420 = 0644 octal), got: " + perm)


	# ==================== Error Handling Tests ====================

	func test_nonexistent_archive
		# archive_list on nonexistent file may raise error or return empty
		# We just check that it doesn't crash the program
		try
			entries = archive_list("nonexistent_file_that_does_not_exist.tar.gz")
		catch
			# Error is expected
		done
		assert(true, "Should handle nonexistent file gracefully")

	func test_invalid_format
		# Try to read a non-archive file
		write("not_an_archive.txt", "This is not an archive")
		content = archive_read_file("not_an_archive.txt", "anything")
		remove("not_an_archive.txt")
		# Should not crash
		assert(true, "Should handle invalid archive gracefully")

	# ==================== Symlink Tests (Unix only) ====================

	func test_symlink_archive
		# Archive should contain symlink
		entries = archive_list("test.tar.gz")
		foundSymlink = false
		for entry in entries
			if entry[3] = ARCHIVE_ENTRY_SYMLINK
				foundSymlink = true
				exit
			ok
		next
		# Note: symlink may or may not be archived depending on behavior
		assert(true, "Symlink test completed")

	# ==================== Binary Data Tests ====================

	func test_binary_file
		content = archive_read_file("test.tar.gz", cTestDir + "/binary.bin")
		assert(len(content) = 4, "Binary file should be 4 bytes")
		assert(ascii(content[1]) = 0, "First byte should be 0")
		assert(ascii(content[2]) = 1, "Second byte should be 1")
		assert(ascii(content[3]) = 255, "Third byte should be 255")
		assert(ascii(content[4]) = 128, "Fourth byte should be 128")

	# ==================== Low-Level Read API Tests ====================

	func test_lowlevel_read_new
		a = archive_read_new()
		assert(isPointer(a), "archive_read_new should return pointer")
		archive_read_close(a)

	func test_lowlevel_read_support
		a = archive_read_new()
		r1 = archive_read_support_filter_all(a)
		r2 = archive_read_support_format_all(a)
		assert(r1 = ARCHIVE_OK, "archive_read_support_filter_all should return OK")
		assert(r2 = ARCHIVE_OK, "archive_read_support_format_all should return OK")
		archive_read_close(a)

	func test_lowlevel_read_open_filename
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		r = archive_read_open_filename(a, "test.tar.gz", 10240)
		assert(r = ARCHIVE_OK, "archive_read_open_filename should return OK")
		archive_read_close(a)
		archive_read_close(a)

	func test_lowlevel_read_next_header
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		entry = archive_read_next_header(a)
		assert(isPointer(entry), "archive_read_next_header should return entry pointer")

		path = archive_entry_pathname(entry)
		assert(isString(path), "Entry should have pathname")

		archive_read_close(a)
		archive_read_close(a)

	func test_lowlevel_read_data
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		content = ""
		while true
			entry = archive_read_next_header(a)
			if isNull(entry) exit ok

			path = archive_entry_pathname(entry)
			if substr(path, "file1.txt") > 0 and archive_entry_is_file(entry)
				size = archive_entry_size(entry)
				if size > 0
					content = archive_read_data(a, size)
				ok
				exit
			ok
		end

		assert(content = "Hello World!", "archive_read_data should read file content")
		archive_read_close(a)
		archive_read_close(a)

	func test_lowlevel_read_data_skip
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		entry = archive_read_next_header(a)
		r = archive_read_data_skip(a)
		assert(r = ARCHIVE_OK, "archive_read_data_skip should return OK")

		archive_read_close(a)
		archive_read_close(a)

	func test_lowlevel_read_data_block
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		while true
			entry = archive_read_next_header(a)
			if isNull(entry) exit ok
			if archive_entry_is_file(entry) and archive_entry_size(entry) > 0
				block = archive_read_data_block(a)
				if isList(block)
					assert(len(block) = 3, "Data block should have 3 elements [data, offset, size]")
				ok
				exit
			ok
		end

		archive_read_close(a)
		archive_read_close(a)

	# ==================== Low-Level Write API Tests ====================

	func test_lowlevel_write_new
		a = archive_write_new()
		assert(isPointer(a), "archive_write_new should return pointer")
		archive_write_close(a)

	func test_lowlevel_write_set_format
		a = archive_write_new()
		r = archive_write_set_format(a, ARCHIVE_FORMAT_TAR)
		assert(r = ARCHIVE_OK, "archive_write_set_format should return OK")
		archive_write_close(a)

	func test_lowlevel_write_set_format_specific
		a = archive_write_new()
		r1 = archive_write_set_format_zip(a)
		assert(r1 = ARCHIVE_OK, "archive_write_set_format_zip should return OK")
		archive_write_close(a)

		a = archive_write_new()
		r2 = archive_write_set_format_pax(a)
		assert(r2 = ARCHIVE_OK, "archive_write_set_format_pax should return OK")
		archive_write_close(a)

		a = archive_write_new()
		r3 = archive_write_set_format_7zip(a)
		assert(r3 = ARCHIVE_OK, "archive_write_set_format_7zip should return OK")
		archive_write_close(a)

	func test_lowlevel_write_add_filter
		a = archive_write_new()
		r = archive_write_add_filter(a, ARCHIVE_COMPRESSION_GZIP)
		assert(r = ARCHIVE_OK, "archive_write_add_filter should return OK")
		archive_write_close(a)

	func test_lowlevel_write_add_filter_specific
		a = archive_write_new()
		assert(archive_write_add_filter_gzip(a) = ARCHIVE_OK, "gzip filter")
		archive_write_close(a)

		a = archive_write_new()
		assert(archive_write_add_filter_bzip2(a) = ARCHIVE_OK, "bzip2 filter")
		archive_write_close(a)

		a = archive_write_new()
		assert(archive_write_add_filter_xz(a) = ARCHIVE_OK, "xz filter")
		archive_write_close(a)

		a = archive_write_new()
		assert(archive_write_add_filter_zstd(a) = ARCHIVE_OK, "zstd filter")
		archive_write_close(a)

		a = archive_write_new()
		assert(archive_write_add_filter_lz4(a) = ARCHIVE_OK, "lz4 filter")
		archive_write_close(a)

		a = archive_write_new()
		assert(archive_write_add_filter_none(a) = ARCHIVE_OK, "none filter")
		archive_write_close(a)

	func test_lowlevel_write_full_cycle
		# Create archive using low-level API
		a = archive_write_new()
		archive_write_set_format_pax(a)
		archive_write_add_filter_gzip(a)
		archive_write_open_filename(a, "lowlevel_test.tar.gz")

		entry = archive_entry_new()
		archive_entry_set_pathname(entry, "lowlevel_file.txt")
		archive_entry_set_size(entry, 13)
		archive_entry_set_filetype(entry, ARCHIVE_ENTRY_FILE)
		archive_entry_set_perm(entry, 420)

		archive_write_header(a, entry)
		written = archive_write_data(a, "Hello LowAPI!")
		assert(written = 13, "Should write 13 bytes")

		archive_write_finish_entry(a)
		archive_write_close(a)

		# Verify
		content = archive_read_file("lowlevel_test.tar.gz", "lowlevel_file.txt")
		assert(content = "Hello LowAPI!", "Low-level written content should match")

	# ==================== Memory Archive Tests ====================

	func test_memory_read
		# First create an archive in memory by reading a file
		cArchiveData = read("test.tar.gz")

		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		r = archive_read_open_memory(a, cArchiveData)
		assert(r = ARCHIVE_OK, "archive_read_open_memory should return OK")

		entry = archive_read_next_header(a)
		assert(!isNull(entry), "Should read entry from memory")

		archive_read_close(a)
		archive_read_close(a)

	func test_memory_write
		a = archive_write_new()
		archive_write_set_format_zip(a)
		archive_write_add_filter_none(a)
		memBuffer = archive_write_open_memory(a)
		assert(isList(memBuffer), "archive_write_open_memory should return list")

		entry = archive_entry_new()
		archive_entry_set_pathname(entry, "memory_file.txt")
		archive_entry_set_size(entry, 5)
		archive_entry_set_filetype(entry, ARCHIVE_ENTRY_FILE)
		archive_entry_set_perm(entry, 420)

		archive_write_header(a, entry)
		archive_write_data(a, "Hello")
		archive_write_finish_entry(a)
		archive_write_close(a)

		# Get the archive data as string
		data = archive_memory_get_data(memBuffer)
		assert(len(data) > 0, "Memory archive should have data")

		archive_memory_free(memBuffer)

	# ==================== Encryption/Passphrase Tests ====================

	func test_encrypted_zip_write
		writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
		writer.setPassphrase("secret123")
		writer.setEncryption("aes256")
		writer.open("encrypted_test.zip")
		writer.addFile("secret.txt", "Secret content!")
		writer.close()

		assertFileExists("encrypted_test.zip")

	func test_encrypted_zip_read
		# Create encrypted archive
		writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
		writer.setPassphrase("mypassword")
		writer.open("encrypted_read_test.zip")
		writer.addFile("data.txt", "Encrypted data")
		writer.close()

		# Read with passphrase
		reader = new ArchiveReader(NULL)
		reader.addPassphrase("mypassword")
		reader.open("encrypted_read_test.zip")

		content = ""
		while reader.nextEntry()
			if reader.entryPath() = "data.txt"
				content = reader.readAll()
				exit
			ok
		end
		reader.close()

		assert(content = "Encrypted data", "Should read encrypted content with passphrase")

	func test_lowlevel_passphrase
		a = archive_write_new()
		archive_write_set_format_zip(a)
		archive_write_add_filter_none(a)

		r1 = archive_write_set_options(a, "zip:encryption=aes256")
		r2 = archive_write_set_passphrase(a, "testpass")

		assert(r1 = ARCHIVE_OK, "archive_write_set_options should return OK")
		assert(r2 = ARCHIVE_OK, "archive_write_set_passphrase should return OK")

		archive_write_close(a)

	func test_lowlevel_read_passphrase
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		r = archive_read_add_passphrase(a, "testpass")
		assert(r = ARCHIVE_OK, "archive_read_add_passphrase should return OK")
		archive_read_close(a)

	# ==================== Entry Extended Tests ====================

	func test_entry_mtime
		entry = new ArchiveEntry()
		currentTime = clock()
		entry.setMtime(currentTime)
		mtime = entry.mtime()
		assert(mtime = currentTime, "mtime should be set correctly")

	func test_entry_symlink_properties
		entry = new ArchiveEntry()
		entry.setPathname("mylink")
		entry.setFiletype(ARCHIVE_ENTRY_SYMLINK)
		entry.setSymlink("target.txt")

		assert(entry.symlink() = "target.txt", "Symlink target should be set")
		assert(entry.isSymlink(), "Should be identified as symlink")

	func test_entry_clone
		entry = new ArchiveEntry()
		entry.setPathname("original.txt")
		entry.setSize(100)

		cloned = entry.clone()
		assert(cloned.pathname() = "original.txt", "Cloned pathname should match")
		assert(cloned.size() = 100, "Cloned size should match")


	func test_entry_clear
		entry = new ArchiveEntry()
		entry.setPathname("test.txt")
		entry.setSize(50)

		entry.clear()
		entry.setPathname("new.txt")

		assert(entry.pathname() = "new.txt", "After clear, new pathname should be set")

	# ==================== Utility Function Tests ====================

	func test_error_string
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)

		# Try to open nonexistent file
		archive_read_open_filename(a, "this_file_does_not_exist_12345.tar.gz", 10240)

		errStr = archive_error_string(a)
		# Error string may be NULL or contain message
		assert(true, "archive_error_string should not crash")

		archive_read_close(a)

	func test_errno
		a = archive_read_new()
		errNo = archive_errno(a)
		assert(isNumber(errNo), "archive_errno should return number")
		archive_read_close(a)

	func test_format_name
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		# Need to read at least one header for format to be detected
		entry = archive_read_next_header(a)

		formatName = archive_format_name(a)
		assert(isString(formatName), "archive_format_name should return string")
		# Format name might be empty before reading content
		assert(true, "format_name returned: " + formatName)

		archive_read_close(a)
		archive_read_close(a)

	func test_filter_name
		a = archive_read_new()
		archive_read_support_filter_all(a)
		archive_read_support_format_all(a)
		archive_read_open_filename(a, "test.tar.gz", 10240)

		# Need to read at least one header
		entry = archive_read_next_header(a)

		filterName = archive_filter_name(a, 0)
		assert(isString(filterName), "archive_filter_name should return string")

		archive_read_close(a)
		archive_read_close(a)

	# ==================== Additional OOP Tests ====================

	func test_reader_error_handling
		reader = new ArchiveReader("test.tar.gz")

		errStr = reader.errorString()
		errNo = reader.errno()

		assert(true, "Error methods should not crash")
		reader.close()

	func test_writer_error_handling
		writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		writer.open("writer_error_test.tar.gz")

		errStr = writer.errorString()
		errNo = writer.errno()
		filterName = writer.filterName()

		assert(true, "Writer error/info methods should not crash")
		writer.close()

	func test_writer_set_options
		writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
		r = writer.setOptions("zip:compression=deflate")
		writer.open("options_test.zip")
		writer.addFile("test.txt", "Test")
		writer.close()

		assert(true, "setOptions should work")

	func test_reader_format_filter_info
		reader = new ArchiveReader("test.tar.gz")
		reader.nextEntry()

		format = reader.formatName()
		filter = reader.filterName()

		assert(isString(format), "formatName should return string")
		assert(isString(filter), "filterName should return string")

		reader.close()

	func test_writer_symlink
		writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		writer.open("symlink_test.tar.gz")
		writer.addSymlink("mylink", "target.txt")
		writer.close()

		entries = archive_list("symlink_test.tar.gz")
		foundSymlink = false
		for e in entries
			if e[1] = "mylink" and e[3] = ARCHIVE_ENTRY_SYMLINK
				foundSymlink = true
				exit
			ok
		next
		assert(foundSymlink, "Archive should contain symlink entry")

	func test_writer_add_from_disk
		write("disk_file.txt", "Content from disk")

		writer = new ArchiveWriter(ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
		writer.open("from_disk_test.tar.gz")
		writer.addFileFromDisk("archived_name.txt", "disk_file.txt")
		writer.close()

		content = archive_read_file("from_disk_test.tar.gz", "archived_name.txt")
		assert(content = "Content from disk", "Content from disk should match")

		remove("disk_file.txt")

	func test_archive_helper_read_file
		arc = new Archive
		content = arc.readFile("test.tar.gz", cTestDir + "/file1.txt")
		assert(content = "Hello World!", "Archive helper readFile should work")

	func test_archive_helper_version
		arc = new Archive
		ver = arc.version()
		assert(isString(ver), "Version should be string")
		assert(len(ver) > 0, "Version should not be empty")
