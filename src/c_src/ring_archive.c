/*
 * Ring Archive Extension
 * ----------------------
 * A Ring language extension for archive manipulation using libarchive.
 * Supports reading/writing tar, zip, 7z, rar, and many other formats.
 *
 * Author: Youssef Saeed (ysdragon)
 * License: MIT
 */

#include "ring.h"
#include <archive.h>
#include <archive_entry.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Define mode_t and S_IS* macros for Windows */
#ifdef _WIN32
#ifndef mode_t
typedef unsigned short mode_t;
#endif
#ifndef S_ISDIR
#define S_ISDIR(m) (((m) & 0170000) == 0040000)
#endif
#ifndef S_ISLNK
#define S_ISLNK(m) (((m) & 0170000) == 0120000)
#endif
#endif

/* ============================================================================
 * Constants - Archive Formats (Ring-specific, prefixed to avoid libarchive
 * conflicts)
 * ============================================================================
 */

#define RING_ARCHIVE_FORMAT_TAR 1
#define RING_ARCHIVE_FORMAT_ZIP 2
#define RING_ARCHIVE_FORMAT_7ZIP 3
#define RING_ARCHIVE_FORMAT_RAR 4
#define RING_ARCHIVE_FORMAT_CPIO 5
#define RING_ARCHIVE_FORMAT_ISO9660 6
#define RING_ARCHIVE_FORMAT_XAR 7
#define RING_ARCHIVE_FORMAT_CAB 8
#define RING_ARCHIVE_FORMAT_RAW 9

/* Compression types */
#define RING_COMPRESSION_NONE 0
#define RING_COMPRESSION_GZIP 1
#define RING_COMPRESSION_BZIP2 2
#define RING_COMPRESSION_XZ 3
#define RING_COMPRESSION_LZMA 4
#define RING_COMPRESSION_ZSTD 5
#define RING_COMPRESSION_LZ4 6

/* Entry types */
#define RING_ENTRY_FILE 1
#define RING_ENTRY_DIR 2
#define RING_ENTRY_SYMLINK 3
#define RING_ENTRY_HARDLINK 4

/* ============================================================================
 * Helper Functions
 * ============================================================================
 */

static void free_archive_read(void *pState, void *pPointer)
{
	struct archive *a = (struct archive *)pPointer;
	if (a)
	{
		archive_read_free(a);
	}
}

static void free_archive_write(void *pState, void *pPointer)
{
	struct archive *a = (struct archive *)pPointer;
	if (a)
	{
		archive_write_free(a);
	}
}

static void free_archive_entry(void *pState, void *pPointer)
{
	struct archive_entry *entry = (struct archive_entry *)pPointer;
	if (entry)
	{
		archive_entry_free(entry);
	}
}

/* ============================================================================
 * Ring Functions - Archive Reading
 * ============================================================================
 */

/*
 * archive_read_new() -> pArchive
 *
 * Create a new archive reader.
 */
RING_FUNC(ring_archive_read_new)
{
	struct archive *a = archive_read_new();
	if (!a)
	{
		RING_API_ERROR("Failed to create archive reader");
		return;
	}
	RING_API_RETMANAGEDCPOINTER(a, "archive_read", free_archive_read);
}

/*
 * archive_read_support_filter_all(pArchive) -> nResult
 *
 * Enable all decompression filters.
 */
RING_FUNC(ring_archive_read_support_filter_all)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}
	int result = archive_read_support_filter_all(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_support_format_all(pArchive) -> nResult
 *
 * Enable all archive format support.
 */
RING_FUNC(ring_archive_read_support_format_all)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}
	int result = archive_read_support_format_all(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_open_filename(pArchive, cFilename, nBlockSize) -> nResult
 *
 * Open an archive file for reading.
 */
RING_FUNC(ring_archive_read_open_filename)
{
	if (RING_API_PARACOUNT != 3)
	{
		RING_API_ERROR(RING_API_MISS3PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}
	if (!RING_API_ISNUMBER(3))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *filename = RING_API_GETSTRING(2);
	size_t block_size = (size_t)RING_API_GETNUMBER(3);

	int result = archive_read_open_filename(a, filename, block_size);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_open_memory(pArchive, cData) -> nResult
 *
 * Open an archive from memory buffer for reading.
 */
RING_FUNC(ring_archive_read_open_memory)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *data = RING_API_GETSTRING(2);
	size_t size = RING_API_GETSTRINGSIZE(2);

	int result = archive_read_open_memory(a, data, size);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_next_header(pArchive) -> pEntry or NULL
 *
 * Read next entry header. Returns entry pointer or NULL if no more entries.
 */
RING_FUNC(ring_archive_read_next_header)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	struct archive_entry *entry;
	int result = archive_read_next_header(a, &entry);

	if (result == ARCHIVE_OK || result == ARCHIVE_WARN)
	{
		/* Entry is owned by archive, don't free it separately */
		RING_API_RETCPOINTER(entry, "archive_entry");
	}
	else
	{
		RING_API_RETCPOINTER(NULL, "archive_entry");
	}
}

/*
 * archive_read_data(pArchive, nSize) -> cData
 *
 * Read data from current entry.
 */
RING_FUNC(ring_archive_read_data)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	size_t size = (size_t)RING_API_GETNUMBER(2);
	if (size == 0)
	{
		return;
	}

	VM *pVM = (VM *)pPointer;
	char *buffer = (char *)ring_state_malloc(pVM->pRingState, size);
	if (!buffer)
	{
		RING_API_ERROR("Failed to allocate read buffer");
		return;
	}

	la_ssize_t bytes_read = archive_read_data(a, buffer, size);
	if (bytes_read < 0)
	{
		ring_state_free(pVM->pRingState, buffer);
		return;
	}

	RING_API_RETSTRING2(buffer, bytes_read);
	ring_state_free(pVM->pRingState, buffer);
}

/*
 * archive_read_data_block(pArchive) -> aResult [cData, nOffset, nSize] or NULL
 *
 * Read data block from current entry. More efficient for large files.
 */
RING_FUNC(ring_archive_read_data_block)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const void *buff;
	size_t size;
	la_int64_t offset;

	int result = archive_read_data_block(a, &buff, &size, &offset);

	if (result == ARCHIVE_OK)
	{
		VM *pVM = (VM *)pPointer;
		List *pResultList = RING_API_NEWLIST;
		ring_list_addstring2_gc(pVM->pRingState, pResultList, (char *)buff, size);
		ring_list_adddouble_gc(pVM->pRingState, pResultList, (double)offset);
		ring_list_adddouble_gc(pVM->pRingState, pResultList, (double)size);
		RING_API_RETLIST(pResultList);
	}
}

/*
 * archive_read_data_skip(pArchive) -> nResult
 *
 * Skip data for current entry.
 */
RING_FUNC(ring_archive_read_data_skip)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_read_data_skip(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_close(pArchive) -> nResult
 *
 * Close archive reader.
 */
RING_FUNC(ring_archive_read_close)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_read_close(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_free(pArchive) -> nResult
 *
 * Free archive reader resources.
 */
RING_FUNC(ring_archive_read_free)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_read_free(a);
	RING_API_SETNULLPOINTER(1);
	RING_API_RETNUMBER((double)result);
}

/* ============================================================================
 * Ring Functions - Archive Writing
 * ============================================================================
 */

/*
 * archive_write_new() -> pArchive
 *
 * Create a new archive writer.
 */
RING_FUNC(ring_archive_write_new)
{
	struct archive *a = archive_write_new();
	if (!a)
	{
		RING_API_ERROR("Failed to create archive writer");
		return;
	}
	RING_API_RETMANAGEDCPOINTER(a, "archive_write", free_archive_write);
}

/*
 * archive_write_set_format(pArchive, nFormat) -> nResult
 *
 * Set archive format.
 */
RING_FUNC(ring_archive_write_set_format)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int format = (int)RING_API_GETNUMBER(2);
	int result = ARCHIVE_OK;

	switch (format)
	{
	case RING_ARCHIVE_FORMAT_TAR:
		result = archive_write_set_format_pax_restricted(a);
		break;
	case RING_ARCHIVE_FORMAT_ZIP:
		result = archive_write_set_format_zip(a);
		break;
	case RING_ARCHIVE_FORMAT_7ZIP:
		result = archive_write_set_format_7zip(a);
		break;
	case RING_ARCHIVE_FORMAT_CPIO:
		result = archive_write_set_format_cpio(a);
		break;
	case RING_ARCHIVE_FORMAT_ISO9660:
		result = archive_write_set_format_iso9660(a);
		break;
	case RING_ARCHIVE_FORMAT_XAR:
		result = archive_write_set_format_xar(a);
		break;
	case RING_ARCHIVE_FORMAT_RAW:
		result = archive_write_set_format_raw(a);
		break;
	default:
		result = archive_write_set_format_pax_restricted(a);
	}

	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_set_format_zip(pArchive) -> nResult
 *
 * Set ZIP format for archive.
 */
RING_FUNC(ring_archive_write_set_format_zip)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_set_format_zip(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_set_format_pax(pArchive) -> nResult
 *
 * Set PAX (POSIX tar) format.
 */
RING_FUNC(ring_archive_write_set_format_pax)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_set_format_pax_restricted(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_set_format_7zip(pArchive) -> nResult
 *
 * Set 7-Zip format.
 */
RING_FUNC(ring_archive_write_set_format_7zip)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_set_format_7zip(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter(pArchive, nFilter) -> nResult
 *
 * Add compression filter.
 */
RING_FUNC(ring_archive_write_add_filter)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int filter = (int)RING_API_GETNUMBER(2);
	int result = ARCHIVE_OK;

	switch (filter)
	{
	case RING_COMPRESSION_NONE:
		result = archive_write_add_filter_none(a);
		break;
	case RING_COMPRESSION_GZIP:
		result = archive_write_add_filter_gzip(a);
		break;
	case RING_COMPRESSION_BZIP2:
		result = archive_write_add_filter_bzip2(a);
		break;
	case RING_COMPRESSION_XZ:
		result = archive_write_add_filter_xz(a);
		break;
	case RING_COMPRESSION_LZMA:
		result = archive_write_add_filter_lzma(a);
		break;
	case RING_COMPRESSION_ZSTD:
		result = archive_write_add_filter_zstd(a);
		break;
	case RING_COMPRESSION_LZ4:
		result = archive_write_add_filter_lz4(a);
		break;
	default:
		result = archive_write_add_filter_none(a);
	}

	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_gzip(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_gzip)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_gzip(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_bzip2(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_bzip2)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_bzip2(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_xz(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_xz)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_xz(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_zstd(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_zstd)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_zstd(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_lz4(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_lz4)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_lz4(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_add_filter_none(pArchive) -> nResult
 */
RING_FUNC(ring_archive_write_add_filter_none)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_add_filter_none(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_open_filename(pArchive, cFilename) -> nResult
 *
 * Open file for writing archive.
 */
RING_FUNC(ring_archive_write_open_filename)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *filename = RING_API_GETSTRING(2);
	int result = archive_write_open_filename(a, filename);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_open_memory(pArchive) -> aResult [pBuffer, pUsed]
 *
 * Open memory buffer for writing archive.
 * Returns list with buffer pointer and used size pointer.
 */
RING_FUNC(ring_archive_write_open_memory)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	VM *pVM = (VM *)pPointer;

	/* Allocate buffer and size tracker */
	size_t buffer_size = 1024 * 1024; /* 1MB initial */
	void *buffer = ring_state_malloc(pVM->pRingState, buffer_size);
	size_t *used = (size_t *)ring_state_malloc(pVM->pRingState, sizeof(size_t));
	*used = 0;

	int result = archive_write_open_memory(a, buffer, buffer_size, used);

	if (result != ARCHIVE_OK)
	{
		ring_state_free(pVM->pRingState, buffer);
		ring_state_free(pVM->pRingState, used);
		RING_API_ERROR("Failed to open memory for writing");
		return;
	}

	List *pResultList = RING_API_NEWLIST;
	ring_list_addcpointer_gc(pVM->pRingState, pResultList, buffer, "buffer");
	ring_list_addcpointer_gc(pVM->pRingState, pResultList, used, "size_ptr");
	RING_API_RETLIST(pResultList);
}

/*
 * archive_write_header(pArchive, pEntry) -> nResult
 *
 * Write entry header.
 */
RING_FUNC(ring_archive_write_header)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISCPOINTER(2))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(2, "archive_entry");

	if (!a || !entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_header(a, entry);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_data(pArchive, cData) -> nBytesWritten
 *
 * Write data for current entry.
 */
RING_FUNC(ring_archive_write_data)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *data = RING_API_GETSTRING(2);
	size_t size = RING_API_GETSTRINGSIZE(2);

	la_ssize_t written = archive_write_data(a, data, size);
	RING_API_RETNUMBER((double)written);
}

/*
 * archive_write_finish_entry(pArchive) -> nResult
 *
 * Finish writing current entry.
 */
RING_FUNC(ring_archive_write_finish_entry)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_finish_entry(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_close(pArchive) -> nResult
 *
 * Close archive writer.
 */
RING_FUNC(ring_archive_write_close)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_close(a);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_write_free(pArchive) -> nResult
 *
 * Free archive writer resources.
 */
RING_FUNC(ring_archive_write_free)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int result = archive_write_free(a);
	RING_API_SETNULLPOINTER(1);
	RING_API_RETNUMBER((double)result);
}

RING_FUNC(ring_archive_write_set_passphrase)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *passphrase = RING_API_GETSTRING(2);
	int result = archive_write_set_passphrase(a, passphrase);
	RING_API_RETNUMBER((double)result);
}

RING_FUNC(ring_archive_write_set_options)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *options = RING_API_GETSTRING(2);
	int result = archive_write_set_options(a, options);
	RING_API_RETNUMBER((double)result);
}

/* ============================================================================
 * Ring Functions - Archive Entry
 * ============================================================================
 */

/*
 * archive_entry_new() -> pEntry
 *
 * Create a new archive entry.
 */
RING_FUNC(ring_archive_entry_new)
{
	struct archive_entry *entry = archive_entry_new();
	if (!entry)
	{
		RING_API_ERROR("Failed to create archive entry");
		return;
	}
	RING_API_RETMANAGEDCPOINTER(entry, "archive_entry", free_archive_entry);
}

/*
 * archive_entry_clear(pEntry) -> pEntry
 *
 * Clear an archive entry for reuse.
 */
RING_FUNC(ring_archive_entry_clear)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_clear(entry);
	RING_API_RETCPOINTER(entry, "archive_entry");
}

/*
 * archive_entry_clone(pEntry) -> pNewEntry
 *
 * Clone an archive entry.
 */
RING_FUNC(ring_archive_entry_clone)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	struct archive_entry *clone = archive_entry_clone(entry);
	if (!clone)
	{
		RING_API_ERROR("Failed to clone archive entry");
		return;
	}
	RING_API_RETMANAGEDCPOINTER(clone, "archive_entry", free_archive_entry);
}

/*
 * archive_entry_free(pEntry)
 *
 * Free an archive entry.
 */
RING_FUNC(ring_archive_entry_free)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (entry)
	{
		archive_entry_free(entry);
		RING_API_SETNULLPOINTER(1);
	}
}

/*
 * archive_entry_pathname(pEntry) -> cPathname
 *
 * Get entry pathname.
 */
RING_FUNC(ring_archive_entry_pathname)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *pathname = archive_entry_pathname(entry);
	RING_API_RETSTRING(pathname);
}

/*
 * archive_entry_set_pathname(pEntry, cPathname)
 *
 * Set entry pathname.
 */
RING_FUNC(ring_archive_entry_set_pathname)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_set_pathname(entry, RING_API_GETSTRING(2));
}

/*
 * archive_entry_size(pEntry) -> nSize
 *
 * Get entry size.
 */
RING_FUNC(ring_archive_entry_size)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	la_int64_t size = archive_entry_size(entry);
	RING_API_RETNUMBER((double)size);
}

/*
 * archive_entry_set_size(pEntry, nSize)
 *
 * Set entry size.
 */
RING_FUNC(ring_archive_entry_set_size)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_set_size(entry, (la_int64_t)RING_API_GETNUMBER(2));
}

/*
 * archive_entry_filetype(pEntry) -> nType
 *
 * Get entry file type.
 */
RING_FUNC(ring_archive_entry_filetype)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	mode_t type = archive_entry_filetype(entry);
	int ring_type = RING_ENTRY_FILE;

	if (S_ISDIR(type))
	{
		ring_type = RING_ENTRY_DIR;
	}
	else if (S_ISLNK(type))
	{
		ring_type = RING_ENTRY_SYMLINK;
	}

	RING_API_RETNUMBER((double)ring_type);
}

/*
 * archive_entry_set_filetype(pEntry, nType)
 *
 * Set entry file type.
 */
RING_FUNC(ring_archive_entry_set_filetype)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	int type = (int)RING_API_GETNUMBER(2);
	mode_t mode;

	switch (type)
	{
	case RING_ENTRY_DIR:
		mode = AE_IFDIR;
		break;
	case RING_ENTRY_SYMLINK:
		mode = AE_IFLNK;
		break;
	case RING_ENTRY_FILE:
	default:
		mode = AE_IFREG;
		break;
	}

	archive_entry_set_filetype(entry, mode);
}

/*
 * archive_entry_perm(pEntry) -> nPerm
 *
 * Get entry permissions.
 */
RING_FUNC(ring_archive_entry_perm)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	RING_API_RETNUMBER((double)archive_entry_perm(entry));
}

/*
 * archive_entry_set_perm(pEntry, nPerm)
 *
 * Set entry permissions.
 */
RING_FUNC(ring_archive_entry_set_perm)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_set_perm(entry, (mode_t)RING_API_GETNUMBER(2));
}

/*
 * archive_entry_mtime(pEntry) -> nTime
 *
 * Get entry modification time.
 */
RING_FUNC(ring_archive_entry_mtime)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	RING_API_RETNUMBER((double)archive_entry_mtime(entry));
}

/*
 * archive_entry_set_mtime(pEntry, nTime, nNsec)
 *
 * Set entry modification time.
 */
RING_FUNC(ring_archive_entry_set_mtime)
{
	if (RING_API_PARACOUNT != 3)
	{
		RING_API_ERROR(RING_API_MISS3PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2) || !RING_API_ISNUMBER(3))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_set_mtime(entry, (time_t)RING_API_GETNUMBER(2), (long)RING_API_GETNUMBER(3));
}

/*
 * archive_entry_symlink(pEntry) -> cTarget
 *
 * Get symlink target.
 */
RING_FUNC(ring_archive_entry_symlink)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *symlink = archive_entry_symlink(entry);
	RING_API_RETSTRING(symlink);
}

/*
 * archive_entry_set_symlink(pEntry, cTarget)
 *
 * Set symlink target.
 */
RING_FUNC(ring_archive_entry_set_symlink)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	archive_entry_set_symlink(entry, RING_API_GETSTRING(2));
}

/*
 * archive_entry_is_directory(pEntry) -> lIsDir
 *
 * Check if entry is a directory.
 */
RING_FUNC(ring_archive_entry_is_directory)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	mode_t type = archive_entry_filetype(entry);
	RING_API_RETNUMBER(S_ISDIR(type) ? 1.0 : 0.0);
}

/*
 * archive_entry_is_file(pEntry) -> lIsFile
 *
 * Check if entry is a regular file.
 */
RING_FUNC(ring_archive_entry_is_file)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	mode_t type = archive_entry_filetype(entry);
	RING_API_RETNUMBER(S_ISREG(type) ? 1.0 : 0.0);
}

/*
 * archive_entry_is_symlink(pEntry) -> lIsSymlink
 *
 * Check if entry is a symbolic link.
 */
RING_FUNC(ring_archive_entry_is_symlink)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive_entry *entry = (struct archive_entry *)RING_API_GETCPOINTER(1, "archive_entry");
	if (!entry)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	mode_t type = archive_entry_filetype(entry);
	RING_API_RETNUMBER(S_ISLNK(type) ? 1.0 : 0.0);
}

/* ============================================================================
 * Ring Functions - Utility Functions
 * ============================================================================
 */

/*
 * archive_error_string(pArchive) -> cErrorMessage
 *
 * Get last error message.
 */
RING_FUNC(ring_archive_error_string)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	}
	if (!a)
	{
		return;
	}

	const char *err = archive_error_string(a);
	RING_API_RETSTRING(err);
}

/*
 * archive_errno(pArchive) -> nErrno
 *
 * Get last error number.
 */
RING_FUNC(ring_archive_errno)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	}
	if (!a)
	{
		RING_API_RETNUMBER(0);
		return;
	}

	RING_API_RETNUMBER((double)archive_errno(a));
}

/*
 * archive_version_string() -> cVersion
 *
 * Get libarchive version string.
 */
RING_FUNC(ring_archive_version_string)
{
	RING_API_RETSTRING(archive_version_string());
}

/*
 * archive_format_name(pArchive) -> cFormatName
 *
 * Get archive format name.
 */
RING_FUNC(ring_archive_format_name)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	}
	if (!a)
	{
		return;
	}

	const char *name = archive_format_name(a);
	RING_API_RETSTRING(name);
}

/*
 * archive_filter_name(pArchive, nFilter) -> cFilterName
 *
 * Get filter name.
 */
RING_FUNC(ring_archive_filter_name)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISNUMBER(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		a = (struct archive *)RING_API_GETCPOINTER(1, "archive_write");
	}
	if (!a)
	{
		return;
	}

	const char *name = archive_filter_name(a, (int)RING_API_GETNUMBER(2));
	RING_API_RETSTRING(name);
}

/* ============================================================================
 * Ring Functions - High-Level Utilities
 * ============================================================================
 */

/*
 * archive_extract(cArchivePath, cDestPath) -> lSuccess
 *
 * Extract entire archive to destination directory.
 */
RING_FUNC(ring_archive_extract)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISSTRING(1) || !RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	const char *archive_path = RING_API_GETSTRING(1);
	const char *dest_path = RING_API_GETSTRING(2);

	struct archive *a = archive_read_new();
	struct archive *ext = archive_write_disk_new();
	struct archive_entry *entry;
	int flags = ARCHIVE_EXTRACT_TIME | ARCHIVE_EXTRACT_PERM | ARCHIVE_EXTRACT_FFLAGS;
	int result = ARCHIVE_OK;

	archive_read_support_filter_all(a);
	archive_read_support_format_all(a);
	archive_write_disk_set_options(ext, flags);
	archive_write_disk_set_standard_lookup(ext);

	if (archive_read_open_filename(a, archive_path, 10240) != ARCHIVE_OK)
	{
		archive_read_free(a);
		archive_write_free(ext);
		RING_API_RETNUMBER(0);
		return;
	}

	VM *pVM = (VM *)pPointer;
	size_t dest_len = strlen(dest_path);

	while ((result = archive_read_next_header(a, &entry)) == ARCHIVE_OK)
	{
		const char *current_path = archive_entry_pathname(entry);

		/* Construct full path */
		size_t new_path_len = dest_len + 1 + strlen(current_path) + 1;
		char *new_path = (char *)ring_state_malloc(pVM->pRingState, new_path_len);
		snprintf(new_path, new_path_len, "%s/%s", dest_path, current_path);
		archive_entry_set_pathname(entry, new_path);

		result = archive_write_header(ext, entry);
		if (result == ARCHIVE_OK)
		{
			const void *buff;
			size_t size;
			la_int64_t offset;

			while (archive_read_data_block(a, &buff, &size, &offset) == ARCHIVE_OK)
			{
				archive_write_data_block(ext, buff, size, offset);
			}
			archive_write_finish_entry(ext);
		}

		ring_state_free(pVM->pRingState, new_path);
	}

	archive_read_close(a);
	archive_read_free(a);
	archive_write_close(ext);
	archive_write_free(ext);

	RING_API_RETNUMBER(result == ARCHIVE_EOF ? 1 : 0);
}

/*
 * archive_list(cArchivePath) -> aEntries
 *
 * List all entries in an archive.
 * Returns list of [pathname, size, type, mtime]
 */
RING_FUNC(ring_archive_list)
{
	if (RING_API_PARACOUNT != 1)
	{
		RING_API_ERROR(RING_API_MISS1PARA);
		return;
	}
	if (!RING_API_ISSTRING(1))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	const char *archive_path = RING_API_GETSTRING(1);

	struct archive *a = archive_read_new();
	struct archive_entry *entry;

	archive_read_support_filter_all(a);
	archive_read_support_format_all(a);

	if (archive_read_open_filename(a, archive_path, 10240) != ARCHIVE_OK)
	{
		archive_read_free(a);
		RING_API_ERROR("Failed to open archive");
		return;
	}

	VM *pVM = (VM *)pPointer;
	List *pResultList = RING_API_NEWLIST;

	while (archive_read_next_header(a, &entry) == ARCHIVE_OK)
	{
		List *pEntryList = ring_list_newlist_gc(pVM->pRingState, pResultList);

		const char *pathname = archive_entry_pathname(entry);
		ring_list_addstring_gc(pVM->pRingState, pEntryList, pathname ? pathname : "");
		ring_list_adddouble_gc(pVM->pRingState, pEntryList, (double)archive_entry_size(entry));

		mode_t type = archive_entry_filetype(entry);
		int ring_type = RING_ENTRY_FILE;
		if (S_ISDIR(type))
			ring_type = RING_ENTRY_DIR;
		else if (S_ISLNK(type))
			ring_type = RING_ENTRY_SYMLINK;
		ring_list_adddouble_gc(pVM->pRingState, pEntryList, (double)ring_type);

		ring_list_adddouble_gc(pVM->pRingState, pEntryList, (double)archive_entry_mtime(entry));

		archive_read_data_skip(a);
	}

	archive_read_close(a);
	archive_read_free(a);

	RING_API_RETLIST(pResultList);
}

/*
 * archive_create(cArchivePath, aFiles, nFormat, nCompression) -> lSuccess
 *
 * Create an archive from list of files.
 */
RING_FUNC(ring_archive_create)
{
	if (RING_API_PARACOUNT != 4)
	{
		RING_API_ERROR(RING_API_BADPARACOUNT);
		return;
	}
	if (!RING_API_ISSTRING(1) || !RING_API_ISLIST(2) || !RING_API_ISNUMBER(3) || !RING_API_ISNUMBER(4))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	const char *archive_path = RING_API_GETSTRING(1);
	List *pFilesList = RING_API_GETLIST(2);
	int format = (int)RING_API_GETNUMBER(3);
	int compression = (int)RING_API_GETNUMBER(4);

	struct archive *a = archive_write_new();
	struct archive_entry *entry;
	VM *pVM = (VM *)pPointer;

	/* Set format */
	switch (format)
	{
	case RING_ARCHIVE_FORMAT_TAR:
		archive_write_set_format_pax_restricted(a);
		break;
	case RING_ARCHIVE_FORMAT_ZIP:
		archive_write_set_format_zip(a);
		break;
	case RING_ARCHIVE_FORMAT_7ZIP:
		archive_write_set_format_7zip(a);
		break;
	case RING_ARCHIVE_FORMAT_CPIO:
		archive_write_set_format_cpio(a);
		break;
	default:
		archive_write_set_format_pax_restricted(a);
	}

	/* Set compression */
	switch (compression)
	{
	case RING_COMPRESSION_NONE:
		archive_write_add_filter_none(a);
		break;
	case RING_COMPRESSION_GZIP:
		archive_write_add_filter_gzip(a);
		break;
	case RING_COMPRESSION_BZIP2:
		archive_write_add_filter_bzip2(a);
		break;
	case RING_COMPRESSION_XZ:
		archive_write_add_filter_xz(a);
		break;
	case RING_COMPRESSION_LZMA:
		archive_write_add_filter_lzma(a);
		break;
	case RING_COMPRESSION_ZSTD:
		archive_write_add_filter_zstd(a);
		break;
	case RING_COMPRESSION_LZ4:
		archive_write_add_filter_lz4(a);
		break;
	default:
		archive_write_add_filter_none(a);
	}

	if (archive_write_open_filename(a, archive_path) != ARCHIVE_OK)
	{
		archive_write_free(a);
		RING_API_RETNUMBER(0);
		return;
	}

	entry = archive_entry_new();
	int success = 1;

	int nSize = ring_list_getsize(pFilesList);
	for (int i = 1; i <= nSize; i++)
	{
		if (!ring_list_isstring(pFilesList, i))
			continue;

		const char *filepath = ring_list_getstring(pFilesList, i);

		FILE *f = fopen(filepath, "rb");
		if (!f)
			continue;

		/* Get file size */
		fseek(f, 0, SEEK_END);
		long fsize = ftell(f);
		fseek(f, 0, SEEK_SET);

		archive_entry_clear(entry);
		archive_entry_set_pathname(entry, filepath);
		archive_entry_set_size(entry, fsize);
		archive_entry_set_filetype(entry, AE_IFREG);
		archive_entry_set_perm(entry, 0644);

		archive_write_header(a, entry);

		/* Read and write file data */
		char buffer[8192];
		size_t bytes_read;
		while ((bytes_read = fread(buffer, 1, sizeof(buffer), f)) > 0)
		{
			archive_write_data(a, buffer, bytes_read);
		}

		fclose(f);
	}

	archive_entry_free(entry);
	archive_write_close(a);
	archive_write_free(a);

	RING_API_RETNUMBER(success);
}

/*
 * archive_read_add_passphrase(pArchive, cPassphrase) -> nResult
 *
 * Add a passphrase for reading encrypted archives.
 */
RING_FUNC(ring_archive_read_add_passphrase)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISCPOINTER(1))
	{
		RING_API_ERROR(RING_API_NOTPOINTER);
		return;
	}
	if (!RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	struct archive *a = (struct archive *)RING_API_GETCPOINTER(1, "archive_read");
	if (!a)
	{
		RING_API_ERROR(RING_API_NULLPOINTER);
		return;
	}

	const char *passphrase = RING_API_GETSTRING(2);
	int result = archive_read_add_passphrase(a, passphrase);
	RING_API_RETNUMBER((double)result);
}

/*
 * archive_read_file(cArchivePath, cEntryPath) -> cData
 *
 * Read a single file from an archive.
 */
RING_FUNC(ring_archive_read_file)
{
	if (RING_API_PARACOUNT != 2)
	{
		RING_API_ERROR(RING_API_MISS2PARA);
		return;
	}
	if (!RING_API_ISSTRING(1) || !RING_API_ISSTRING(2))
	{
		RING_API_ERROR(RING_API_BADPARATYPE);
		return;
	}

	const char *archive_path = RING_API_GETSTRING(1);
	const char *entry_path = RING_API_GETSTRING(2);

	struct archive *a = archive_read_new();
	struct archive_entry *entry;

	archive_read_support_filter_all(a);
	archive_read_support_format_all(a);

	if (archive_read_open_filename(a, archive_path, 10240) != ARCHIVE_OK)
	{
		archive_read_free(a);
		return;
	}

	VM *pVM = (VM *)pPointer;
	char *result_data = NULL;
	size_t result_size = 0;

	while (archive_read_next_header(a, &entry) == ARCHIVE_OK)
	{
		const char *pathname = archive_entry_pathname(entry);
		if (pathname && strcmp(pathname, entry_path) == 0)
		{
			la_int64_t size = archive_entry_size(entry);
			if (size > 0)
			{
				result_data = (char *)ring_state_malloc(pVM->pRingState, size);
				result_size = archive_read_data(a, result_data, size);
			}
			break;
		}
		archive_read_data_skip(a);
	}

	archive_read_close(a);
	archive_read_free(a);

	if (result_data)
	{
		RING_API_RETSTRING2(result_data, result_size);
		ring_state_free(pVM->pRingState, result_data);
	}
}

/* ============================================================================
 * Ring Functions - Constants
 * ============================================================================
 */

RING_FUNC(ring_get_archive_format_tar)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_TAR);
}
RING_FUNC(ring_get_archive_format_zip)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_ZIP);
}
RING_FUNC(ring_get_archive_format_7zip)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_7ZIP);
}
RING_FUNC(ring_get_archive_format_rar)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_RAR);
}
RING_FUNC(ring_get_archive_format_cpio)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_CPIO);
}
RING_FUNC(ring_get_archive_format_iso9660)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_ISO9660);
}
RING_FUNC(ring_get_archive_format_raw)
{
	RING_API_RETNUMBER((double)RING_ARCHIVE_FORMAT_RAW);
}

RING_FUNC(ring_get_archive_compression_none)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_NONE);
}
RING_FUNC(ring_get_archive_compression_gzip)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_GZIP);
}
RING_FUNC(ring_get_archive_compression_bzip2)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_BZIP2);
}
RING_FUNC(ring_get_archive_compression_xz)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_XZ);
}
RING_FUNC(ring_get_archive_compression_lzma)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_LZMA);
}
RING_FUNC(ring_get_archive_compression_zstd)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_ZSTD);
}
RING_FUNC(ring_get_archive_compression_lz4)
{
	RING_API_RETNUMBER((double)RING_COMPRESSION_LZ4);
}

RING_FUNC(ring_get_archive_entry_file)
{
	RING_API_RETNUMBER((double)RING_ENTRY_FILE);
}
RING_FUNC(ring_get_archive_entry_dir)
{
	RING_API_RETNUMBER((double)RING_ENTRY_DIR);
}
RING_FUNC(ring_get_archive_entry_symlink)
{
	RING_API_RETNUMBER((double)RING_ENTRY_SYMLINK);
}

RING_FUNC(ring_get_archive_ok)
{
	RING_API_RETNUMBER((double)ARCHIVE_OK);
}
RING_FUNC(ring_get_archive_eof)
{
	RING_API_RETNUMBER((double)ARCHIVE_EOF);
}
RING_FUNC(ring_get_archive_retry)
{
	RING_API_RETNUMBER((double)ARCHIVE_RETRY);
}
RING_FUNC(ring_get_archive_warn)
{
	RING_API_RETNUMBER((double)ARCHIVE_WARN);
}
RING_FUNC(ring_get_archive_failed)
{
	RING_API_RETNUMBER((double)ARCHIVE_FAILED);
}
RING_FUNC(ring_get_archive_fatal)
{
	RING_API_RETNUMBER((double)ARCHIVE_FATAL);
}

/* ============================================================================
 * Library Initialization
 * ============================================================================
 */

RING_LIBINIT
{
	/* Archive Reading */
	RING_API_REGISTER("archive_read_new", ring_archive_read_new);
	RING_API_REGISTER("archive_read_support_filter_all", ring_archive_read_support_filter_all);
	RING_API_REGISTER("archive_read_support_format_all", ring_archive_read_support_format_all);
	RING_API_REGISTER("archive_read_open_filename", ring_archive_read_open_filename);
	RING_API_REGISTER("archive_read_open_memory", ring_archive_read_open_memory);
	RING_API_REGISTER("archive_read_next_header", ring_archive_read_next_header);
	RING_API_REGISTER("archive_read_data", ring_archive_read_data);
	RING_API_REGISTER("archive_read_data_block", ring_archive_read_data_block);
	RING_API_REGISTER("archive_read_data_skip", ring_archive_read_data_skip);
	RING_API_REGISTER("archive_read_close", ring_archive_read_close);
	RING_API_REGISTER("archive_read_free", ring_archive_read_free);

	/* Archive Writing */
	RING_API_REGISTER("archive_write_new", ring_archive_write_new);
	RING_API_REGISTER("archive_write_set_format", ring_archive_write_set_format);
	RING_API_REGISTER("archive_write_set_format_zip", ring_archive_write_set_format_zip);
	RING_API_REGISTER("archive_write_set_format_pax", ring_archive_write_set_format_pax);
	RING_API_REGISTER("archive_write_set_format_7zip", ring_archive_write_set_format_7zip);
	RING_API_REGISTER("archive_write_add_filter", ring_archive_write_add_filter);
	RING_API_REGISTER("archive_write_add_filter_gzip", ring_archive_write_add_filter_gzip);
	RING_API_REGISTER("archive_write_add_filter_bzip2", ring_archive_write_add_filter_bzip2);
	RING_API_REGISTER("archive_write_add_filter_xz", ring_archive_write_add_filter_xz);
	RING_API_REGISTER("archive_write_add_filter_zstd", ring_archive_write_add_filter_zstd);
	RING_API_REGISTER("archive_write_add_filter_lz4", ring_archive_write_add_filter_lz4);
	RING_API_REGISTER("archive_write_add_filter_none", ring_archive_write_add_filter_none);
	RING_API_REGISTER("archive_write_open_filename", ring_archive_write_open_filename);
	RING_API_REGISTER("archive_write_open_memory", ring_archive_write_open_memory);
	RING_API_REGISTER("archive_write_header", ring_archive_write_header);
	RING_API_REGISTER("archive_write_data", ring_archive_write_data);
	RING_API_REGISTER("archive_write_finish_entry", ring_archive_write_finish_entry);
	RING_API_REGISTER("archive_write_close", ring_archive_write_close);
	RING_API_REGISTER("archive_write_free", ring_archive_write_free);
	RING_API_REGISTER("archive_write_set_passphrase", ring_archive_write_set_passphrase);
	RING_API_REGISTER("archive_write_set_options", ring_archive_write_set_options);

	/* Archive Entry */
	RING_API_REGISTER("archive_entry_new", ring_archive_entry_new);
	RING_API_REGISTER("archive_entry_clear", ring_archive_entry_clear);
	RING_API_REGISTER("archive_entry_clone", ring_archive_entry_clone);
	RING_API_REGISTER("archive_entry_free", ring_archive_entry_free);
	RING_API_REGISTER("archive_entry_pathname", ring_archive_entry_pathname);
	RING_API_REGISTER("archive_entry_set_pathname", ring_archive_entry_set_pathname);
	RING_API_REGISTER("archive_entry_size", ring_archive_entry_size);
	RING_API_REGISTER("archive_entry_set_size", ring_archive_entry_set_size);
	RING_API_REGISTER("archive_entry_filetype", ring_archive_entry_filetype);
	RING_API_REGISTER("archive_entry_set_filetype", ring_archive_entry_set_filetype);
	RING_API_REGISTER("archive_entry_perm", ring_archive_entry_perm);
	RING_API_REGISTER("archive_entry_set_perm", ring_archive_entry_set_perm);
	RING_API_REGISTER("archive_entry_mtime", ring_archive_entry_mtime);
	RING_API_REGISTER("archive_entry_set_mtime", ring_archive_entry_set_mtime);
	RING_API_REGISTER("archive_entry_symlink", ring_archive_entry_symlink);
	RING_API_REGISTER("archive_entry_set_symlink", ring_archive_entry_set_symlink);
	RING_API_REGISTER("archive_entry_is_directory", ring_archive_entry_is_directory);
	RING_API_REGISTER("archive_entry_is_file", ring_archive_entry_is_file);
	RING_API_REGISTER("archive_entry_is_symlink", ring_archive_entry_is_symlink);

	/* Utility Functions */
	RING_API_REGISTER("archive_error_string", ring_archive_error_string);
	RING_API_REGISTER("archive_errno", ring_archive_errno);
	RING_API_REGISTER("archive_version_string", ring_archive_version_string);
	RING_API_REGISTER("archive_format_name", ring_archive_format_name);
	RING_API_REGISTER("archive_filter_name", ring_archive_filter_name);

	/* High-Level Utilities */
	RING_API_REGISTER("archive_extract", ring_archive_extract);
	RING_API_REGISTER("archive_list", ring_archive_list);
	RING_API_REGISTER("archive_create", ring_archive_create);
	RING_API_REGISTER("archive_read_file", ring_archive_read_file);
	RING_API_REGISTER("archive_read_add_passphrase", ring_archive_read_add_passphrase);

	/* Format Constants */
	RING_API_REGISTER("get_archive_format_tar", ring_get_archive_format_tar);
	RING_API_REGISTER("get_archive_format_zip", ring_get_archive_format_zip);
	RING_API_REGISTER("get_archive_format_7zip", ring_get_archive_format_7zip);
	RING_API_REGISTER("get_archive_format_rar", ring_get_archive_format_rar);
	RING_API_REGISTER("get_archive_format_cpio", ring_get_archive_format_cpio);
	RING_API_REGISTER("get_archive_format_iso9660", ring_get_archive_format_iso9660);
	RING_API_REGISTER("get_archive_format_raw", ring_get_archive_format_raw);

	/* Compression Constants */
	RING_API_REGISTER("get_archive_compression_none", ring_get_archive_compression_none);
	RING_API_REGISTER("get_archive_compression_gzip", ring_get_archive_compression_gzip);
	RING_API_REGISTER("get_archive_compression_bzip2", ring_get_archive_compression_bzip2);
	RING_API_REGISTER("get_archive_compression_xz", ring_get_archive_compression_xz);
	RING_API_REGISTER("get_archive_compression_lzma", ring_get_archive_compression_lzma);
	RING_API_REGISTER("get_archive_compression_zstd", ring_get_archive_compression_zstd);
	RING_API_REGISTER("get_archive_compression_lz4", ring_get_archive_compression_lz4);

	/* Entry Type Constants */
	RING_API_REGISTER("get_archive_entry_file", ring_get_archive_entry_file);
	RING_API_REGISTER("get_archive_entry_dir", ring_get_archive_entry_dir);
	RING_API_REGISTER("get_archive_entry_symlink", ring_get_archive_entry_symlink);

	/* Status Constants */
	RING_API_REGISTER("get_archive_ok", ring_get_archive_ok);
	RING_API_REGISTER("get_archive_eof", ring_get_archive_eof);
	RING_API_REGISTER("get_archive_retry", ring_get_archive_retry);
	RING_API_REGISTER("get_archive_warn", ring_get_archive_warn);
	RING_API_REGISTER("get_archive_failed", ring_get_archive_failed);
	RING_API_REGISTER("get_archive_fatal", ring_get_archive_fatal);
}
