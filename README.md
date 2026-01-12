<div align="center">

# 📦 Archive

[license]: https://img.shields.io/github/license/ysdragon/archive?style=for-the-badge&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc
[language-ring]: https://img.shields.io/badge/language-Ring-2D54CB.svg?style=for-the-badge&labelColor=414868
[platform]: https://img.shields.io/badge/Platform-Windows%20|%20Linux%20|%20macOS%20|%20FreeBSD-8c73cc.svg?style=for-the-badge&labelColor=414868
[version]: https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fraw.githubusercontent.com%2Fysdragon%2Farchive%2Fmaster%2Fpackage.ring&search=%3Aversion\s*%3D\s*"([^"]%2B)"&replace=%241&style=for-the-badge&label=version&labelColor=414868&color=7664C6

[![][license]](LICENSE)
[![][language-ring]](https://ring-lang.github.io/)
[![][platform]](#)
[![][version]](#)

**Archive manipulation library for the Ring programming language**

*Built on [libarchive](https://libarchive.org/) - A multi-format archive and compression library*

---

</div>

## ✨ Features

-   📁 **Multiple Formats**: TAR, ZIP, 7-Zip, CPIO, ISO9660, RAR (read-only)
-   🗜️ **Multiple Compressions**: GZIP, BZIP2, XZ, LZMA, ZSTD, LZ4
-   🔐 **Encryption Support**: AES-256, AES-128, ZipCrypt for ZIP archives
-   🌍 **Cross-Platform**: Works on Windows, Linux, macOS, and FreeBSD
-   ⚡ **High-Level API**: Simple `archive_extract()`, `archive_create()`, `archive_list()`
-   🎯 **OOP Interface**: Clean `ArchiveReader`, `ArchiveWriter`, `Archive`, `ArchiveEntry` classes
-   📦 **Static Linking**: All dependencies built-in, no external libraries needed

## 📥 Installation

### Using RingPM

```bash
ringpm install archive from ysdragon
```

## 🚀 Quick Start

```ring
load "archive.ring"

# List archive contents
aFiles = archive_list("myarchive.tar.gz")
for aFile in aFiles
    ? aFile[1]  # filename
next

# Extract archive
archive_extract("myarchive.tar.gz", "output/")

# Create archive
archive_create("backup.tar.gz", ["file1.txt", "file2.txt"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_GZIP)
```

## 📖 Usage

### High-Level Functions

```ring
load "archive.ring"

# List contents (returns list of [pathname, size, type, mtime])
aFiles = archive_list("archive.zip")
for aFile in aFiles
    ? aFile[1] + " (" + aFile[2] + " bytes)"
next

# Extract to directory
archive_extract("archive.tar.gz", "output/")

# Create archive
archive_create("new.tar.xz", ["doc.txt", "data.json"], 
               ARCHIVE_FORMAT_TAR, ARCHIVE_COMPRESSION_XZ)

# Read specific file from archive
cContent = archive_read_file("archive.zip", "readme.txt")
? cContent
```

### OOP Interface - Reading

```ring
load "archive.ring"

reader = new ArchiveReader("myarchive.tar.gz")

while reader.nextEntry()
    ? "File: " + reader.entryPath()
    ? "Size: " + reader.entrySize()
    if reader.entryIsFile()
        ? "Content: " + reader.readAll()
    ok
end

reader.close()
reader.free()
```

### OOP Interface - Writing

```ring
load "archive.ring"

writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.open("output.zip")
writer.addFile("hello.txt", "Hello World!")
writer.addFile("data.json", '{"key": "value"}')
writer.addDirectory("subdir/")
writer.close()
writer.free()
```

### 🔐 Encrypted ZIP Archives

```ring
load "archive.ring"

# Writing encrypted archive
writer = new ArchiveWriter(ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
writer.setPassphrase("secretpassword")
writer.setEncryption(ARCHIVE_ENCRYPTION_AES256)  # or AES128, ZIPCRYPT
writer.open("secure.zip")
writer.addFile("secret.txt", "Confidential data")
writer.close()
writer.free()

# Reading encrypted archive
reader = new ArchiveReader(NULL)
reader.addPassphrase("secretpassword")
reader.open("secure.zip")
while reader.nextEntry()
    ? reader.entryPath() + ": " + reader.readAll()
end
reader.close()
reader.free()
```

### Archive Helper Class

```ring
load "archive.ring"

archive = new Archive

# Get library version
? archive.version()

# Simple operations
archive.extract("backup.tar.gz", "restored/")
aFiles = archive.list("backup.tar.gz")
cContent = archive.readFile("backup.tar.gz", "config.json")
archive.create("new.zip", ["file1.txt", "file2.txt"], 
               ARCHIVE_FORMAT_ZIP, ARCHIVE_COMPRESSION_NONE)
```

## 📚 API Reference

### High-Level Functions

| Function | Description |
|----------|-------------|
| `archive_list(cPath)` | List archive contents. Returns `[[path, size, type, mtime], ...]` |
| `archive_extract(cArchive, cDestPath)` | Extract archive to directory |
| `archive_create(cPath, aFiles, nFormat, nCompression)` | Create archive from file list |
| `archive_read_file(cArchive, cEntryPath)` | Read specific file from archive |

### Format Constants

| Constant | Description |
|----------|-------------|
| `ARCHIVE_FORMAT_TAR` | TAR format |
| `ARCHIVE_FORMAT_ZIP` | ZIP format |
| `ARCHIVE_FORMAT_7ZIP` | 7-Zip format |
| `ARCHIVE_FORMAT_CPIO` | CPIO format |
| `ARCHIVE_FORMAT_ISO9660` | ISO9660 format |
| `ARCHIVE_FORMAT_RAR` | RAR format (read-only) |
| `ARCHIVE_FORMAT_RAW` | Raw format |

### Compression Constants

| Constant | Description |
|----------|-------------|
| `ARCHIVE_COMPRESSION_NONE` | No compression |
| `ARCHIVE_COMPRESSION_GZIP` | GZIP compression |
| `ARCHIVE_COMPRESSION_BZIP2` | BZIP2 compression |
| `ARCHIVE_COMPRESSION_XZ` | XZ compression |
| `ARCHIVE_COMPRESSION_LZMA` | LZMA compression |
| `ARCHIVE_COMPRESSION_ZSTD` | ZSTD compression |
| `ARCHIVE_COMPRESSION_LZ4` | LZ4 compression |

### Encryption Constants

| Constant | Description |
|----------|-------------|
| `ARCHIVE_ENCRYPTION_AES256` | WinZip AES-256 (strongest) |
| `ARCHIVE_ENCRYPTION_AES128` | WinZip AES-128 |
| `ARCHIVE_ENCRYPTION_ZIPCRYPT` | Traditional PKWARE (compatible with unzip) |

### 🎯 OOP Classes

#### ArchiveReader Class

```ring
reader = new ArchiveReader(cFilename)
reader.open(cFilename)              # Open archive
reader.addPassphrase(cPassword)     # Add passphrase for encrypted archives (call before open)
reader.openMemory(cData)            # Open from memory
reader.nextEntry()                  # Move to next entry (returns true/false)
reader.entry()                      # Get current entry pointer
reader.entryPath()                  # Get current entry path
reader.entrySize()                  # Get current entry size
reader.entryIsFile()                # Check if file
reader.entryIsDir()                 # Check if directory
reader.entryIsSymlink()             # Check if symlink
reader.readAll()                    # Read all content
reader.readData(nSize)              # Read n bytes
reader.readDataBlock()              # Read data block (returns [data, offset, size])
reader.skipData()                   # Skip current entry
reader.close()                      # Close archive
reader.free()                       # Free resources
reader.errorString()                # Get error message
reader.errno()                      # Get error number
reader.formatName()                 # Get format name
reader.filterName()                 # Get filter/compression name
```

#### ArchiveWriter Class

```ring
writer = new ArchiveWriter(nFormat, nCompression)
writer.setFormat(nFormat)           # Set format
writer.setCompression(nCompression) # Set compression
writer.setPassphrase(cPassword)     # Set encryption password
writer.setEncryption(cMethod)       # Set encryption method
writer.setOptions(cOptions)         # Set libarchive options
writer.open(cFilename)              # Open for writing
writer.openMemory()                 # Open memory buffer for writing
writer.addFile(cPath, cData)        # Add file with content
writer.addDirectory(cPath)          # Add directory
writer.addSymlink(cPath, cTarget)   # Add symlink
writer.addFileFromDisk(cArchPath, cDiskPath) # Add file from disk
writer.close()                      # Close archive
writer.free()                       # Free resources
writer.errorString()                # Get error message
writer.errno()                      # Get error number
writer.filterName()                 # Get filter/compression name
```

#### ArchiveEntry Class

```ring
entry = new ArchiveEntry()
entry.setPathname(cPath)            # Set path
entry.setSize(nSize)                # Set size
entry.setFiletype(nType)            # Set type (FILE, DIR, SYMLINK)
entry.setPerm(nPerm)                # Set permissions
entry.setMtime(nTime)               # Set modification time
entry.setSymlink(cTarget)           # Set symlink target
entry.pathname()                    # Get path
entry.size()                        # Get size
entry.filetype()                    # Get type
entry.perm()                        # Get permissions
entry.mtime()                       # Get modification time
entry.symlink()                     # Get symlink target
entry.isFile()                      # Check if file
entry.isDirectory()                 # Check if directory
entry.isSymlink()                   # Check if symlink
entry.clone()                       # Clone entry
entry.clear()                       # Clear for reuse
entry.handle()                      # Get raw entry pointer
entry.free()                        # Free resources
```

## 📂 Examples

The `examples/` directory contains 22 examples covering all features:

| # | Example | Description |
|---|---------|-------------|
| 01-05 | 📋 Basics | List, extract, create, read files |
| 06-11 | 🎯 OOP Classes | Reader, Writer, Entry classes |
| 12-14 | 📁 Formats | Different formats and symlinks |
| 15-16 | 🔐 Encryption | Password-protected archives |
| 17-19 | ⚙️ Advanced | Memory archives, raw API |
| 20-22 | 🛡️ Error Handling | Error handling and complete example |

## 🛠️ Development

### Prerequisites

-   **CMake**: Version 3.16 or higher
-   **C Compiler**: GCC, Clang, or MSVC
-   **Ring Source Code**: Ring language source code
-   **Git**: For cloning submodules

### Build Steps

1.  **Clone the Repository:**
    ```sh
    git clone --recursive https://github.com/ysdragon/archive.git
    ```

2.  **Set the `RING` Environment Variable:**
    ```shell
    # Linux/macOS/FreeBSD
    export RING=/path/to/ring
    
    # Windows
    set RING=X:\path\to\ring
    ```

3.  **Build:**
    ```sh
    mkdir build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    cmake --build .
    ```

The compiled library will be in `lib/<os>/<arch>/`.

### Dependencies (included as submodules)

- libarchive (archive handling)
- zlib (GZIP)
- zstd (ZSTD)
- xz/liblzma (XZ/LZMA)
- lz4 (LZ4)
- bzip2 (BZIP2)
- brotli (Brotli)
- mbedtls (encryption)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 📜 Third-Party Licenses

This library includes the following third-party components:

| Library | License |
|---------|---------|
| [libarchive](https://libarchive.org/) | BSD-2-Clause |
| [zlib](https://zlib.net/) | zlib License |
| [zstd](https://github.com/facebook/zstd) | BSD-3-Clause |
| [xz/liblzma](https://tukaani.org/xz/) | 0BSD (BSD Zero Clause) |
| [lz4](https://lz4.github.io/lz4/) | BSD-2-Clause |
| [bzip2](https://sourceware.org/bzip2/) | bzip2 License (BSD-like) |
| [brotli](https://github.com/google/brotli) | MIT |
| [mbedTLS](https://github.com/Mbed-TLS/mbedtls) | Apache-2.0 OR GPL-2.0-or-later |
