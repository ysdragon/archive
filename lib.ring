if isWindows()
	loadlib("ring_archive.dll")
but isLinux() or isFreeBSD()
	loadlib("libring_archive.so")
but isMacOSX()
	loadlib("libring_archive.dylib")
else
	raise("Unsupported OS! You need to build the library for your OS.")
ok

load "src/archive.ring"
