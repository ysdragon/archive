cmake_minimum_required(VERSION 3.16)
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
project(ring_archive LANGUAGES C)

# =============================================================================
# Global Setup
# =============================================================================
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# Ring Language Setup
set(RING_ROOT_DEFAULT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
if(DEFINED ENV{RING})
    set(RING_ROOT_DEFAULT "$ENV{RING}")
endif()
set(RING_ROOT "${RING_ROOT_DEFAULT}" CACHE PATH "Path to the Ring project root directory.")
message(STATUS "Using Ring from: ${RING_ROOT}")

if(NOT TARGET Ring::Ring)
    add_library(Ring::Ring UNKNOWN IMPORTED)
    find_path(RING_INCLUDE_DIR ring.h PATHS "${RING_ROOT}/language/include")
    find_library(RING_LIBRARY_PATH NAMES ring PATHS "${RING_ROOT}/lib")

    if(NOT RING_INCLUDE_DIR OR NOT RING_LIBRARY_PATH)
        message(FATAL_ERROR "Could not find Ring headers or library in ${RING_ROOT}. "
                            "Please set the RING_ROOT cache variable correctly.")
    endif()

    set_target_properties(Ring::Ring PROPERTIES
        IMPORTED_LOCATION "${RING_LIBRARY_PATH}"
        INTERFACE_INCLUDE_DIRECTORIES "${RING_INCLUDE_DIR}"
    )
endif()

set(RING_INCLUDE "${RING_ROOT}/language/include")
set(RING_LIB "${RING_ROOT}/lib")
set(RING_BIN "${RING_ROOT}/bin")

# =============================================================================
# Determine OS and Architecture
# =============================================================================
string(TOLOWER "${CMAKE_SYSTEM_NAME}" OS_DIR)
if(OS_DIR STREQUAL "darwin")
    set(OS_DIR "macos")
endif()

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" ARCH_DIR_RAW)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND DEFINED CMAKE_GENERATOR_PLATFORM)
    if(CMAKE_GENERATOR_PLATFORM STREQUAL "Win32")
        set(ARCH_DIR_RAW "i386")
    elseif(CMAKE_GENERATOR_PLATFORM STREQUAL "x64")
        set(ARCH_DIR_RAW "amd64")
    elseif(CMAKE_GENERATOR_PLATFORM STREQUAL "ARM64")
        set(ARCH_DIR_RAW "arm64")
    endif()
endif()

if(NOT DEFINED ARCH_DIR)
    if(ARCH_DIR_RAW MATCHES "x86_64|amd64")
        set(ARCH_DIR "amd64")
    elseif(ARCH_DIR_RAW MATCHES "aarch64|arm64")
        set(ARCH_DIR "arm64")
    elseif(ARCH_DIR_RAW MATCHES "riscv64")
        set(ARCH_DIR "riscv64")
    elseif(ARCH_DIR_RAW MATCHES "i386|i686|x86")
        set(ARCH_DIR "i386")
    else()
        set(ARCH_DIR "${ARCH_DIR_RAW}")
    endif()
endif()

# Detect musl libc
option(MUSL "Build for musl libc" OFF)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if(NOT MUSL)
        execute_process(
            COMMAND ldd --version
            OUTPUT_VARIABLE LDD_OUTPUT
            ERROR_VARIABLE LDD_OUTPUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(LDD_OUTPUT MATCHES "musl")
            set(MUSL ON)
            message(STATUS "Detected musl libc")
        endif()
    endif()
endif()

if(MUSL AND OS_DIR STREQUAL "linux")
    set(LIB_DEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/${OS_DIR}/musl/${ARCH_DIR}")
else()
    set(LIB_DEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/${OS_DIR}/${ARCH_DIR}")
endif()

# =============================================================================
# Submodule Paths
# =============================================================================
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/c_src")

# =============================================================================
# Build ZLIB (static only)
# =============================================================================
message(STATUS "Building ZLIB...")
set(ZLIB_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(ZLIB_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(ZLIB_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(ZLIB_BUILD_MINIZIP OFF CACHE BOOL "" FORCE)
set(ZLIB_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/zlib ${CMAKE_CURRENT_BINARY_DIR}/zlib)

# =============================================================================
# Build ZSTD (static only)
# =============================================================================
message(STATUS "Building ZSTD...")
set(ZSTD_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(ZSTD_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_CONTRIB OFF CACHE BOOL "" FORCE)
set(ZSTD_MULTITHREAD_SUPPORT OFF CACHE BOOL "" FORCE)
set(ZSTD_LEGACY_SUPPORT OFF CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/zstd/build/cmake ${CMAKE_CURRENT_BINARY_DIR}/zstd)

# =============================================================================
# Build XZ / LibLZMA (static only)
# =============================================================================
message(STATUS "Building LibLZMA...")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CREATE_XZ_SYMLINKS OFF CACHE BOOL "" FORCE)
set(CREATE_LZMA_SYMLINKS OFF CACHE BOOL "" FORCE)
set(XZ_NLS OFF CACHE BOOL "" FORCE)
set(XZ_TOOL_XZDEC OFF CACHE BOOL "" FORCE)
set(XZ_TOOL_LZMADEC OFF CACHE BOOL "" FORCE)
set(XZ_TOOL_LZMAINFO OFF CACHE BOOL "" FORCE)
set(XZ_TOOL_XZ OFF CACHE BOOL "" FORCE)
set(XZ_DOC OFF CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/xz ${CMAKE_CURRENT_BINARY_DIR}/xz)

# =============================================================================
# Build LZ4 (static only)
# =============================================================================
message(STATUS "Building LZ4...")
set(LZ4_BUILD_CLI OFF CACHE BOOL "" FORCE)
set(LZ4_BUILD_LEGACY_LZ4C OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_STATIC_LIBS ON CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/lz4/build/cmake ${CMAKE_CURRENT_BINARY_DIR}/lz4)

# =============================================================================
# Build BZip2 (no CMake, build manually)
# =============================================================================
message(STATUS "Building BZip2...")
add_library(bz2_static STATIC
    ${DEPS_DIR}/bzip2/blocksort.c
    ${DEPS_DIR}/bzip2/huffman.c
    ${DEPS_DIR}/bzip2/crctable.c
    ${DEPS_DIR}/bzip2/randtable.c
    ${DEPS_DIR}/bzip2/compress.c
    ${DEPS_DIR}/bzip2/decompress.c
    ${DEPS_DIR}/bzip2/bzlib.c
)
target_include_directories(bz2_static PUBLIC ${DEPS_DIR}/bzip2)
set_target_properties(bz2_static PROPERTIES POSITION_INDEPENDENT_CODE ON)

# =============================================================================
# Build Brotli (static only)
# =============================================================================
message(STATUS "Building Brotli...")
set(BROTLI_DISABLE_TESTS ON CACHE BOOL "" FORCE)
set(BROTLI_BUNDLED_MODE ON CACHE BOOL "" FORCE)
set(BROTLI_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/brotli ${CMAKE_CURRENT_BINARY_DIR}/brotli)

# =============================================================================
# Build mbedTLS (static only)
# =============================================================================
message(STATUS "Building mbedTLS...")
set(USE_STATIC_MBEDTLS_LIBRARY ON CACHE BOOL "" FORCE)
set(USE_SHARED_MBEDTLS_LIBRARY OFF CACHE BOOL "" FORCE)
set(ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(ENABLE_PROGRAMS OFF CACHE BOOL "" FORCE)
set(MBEDTLS_FATAL_WARNINGS OFF CACHE BOOL "" FORCE)
set(DISABLE_PACKAGE_CONFIG_AND_INSTALL ON CACHE BOOL "" FORCE)
add_subdirectory(${DEPS_DIR}/mbedtls ${CMAKE_CURRENT_BINARY_DIR}/mbedtls)

# =============================================================================
# Build LibArchive
# =============================================================================
message(STATUS "Building LibArchive...")

# Disable all CLI tools and tests
set(ENABLE_TEST OFF CACHE BOOL "" FORCE)
set(ENABLE_TAR OFF CACHE BOOL "" FORCE)
set(ENABLE_CPIO OFF CACHE BOOL "" FORCE)
set(ENABLE_CAT OFF CACHE BOOL "" FORCE)
set(ENABLE_UNZIP OFF CACHE BOOL "" FORCE)
set(ENABLE_ACL OFF CACHE BOOL "" FORCE)
set(ENABLE_XATTR OFF CACHE BOOL "" FORCE)
set(ENABLE_ICONV OFF CACHE BOOL "" FORCE)
set(ENABLE_COVERAGE OFF CACHE BOOL "" FORCE)
set(ENABLE_INSTALL OFF CACHE BOOL "" FORCE)

# Disable other crypto backends
set(ENABLE_OPENSSL OFF CACHE BOOL "" FORCE)
set(ENABLE_NETTLE OFF CACHE BOOL "" FORCE)
set(ENABLE_CNG OFF CACHE BOOL "" FORCE)

# Enable mbedTLS
set(ENABLE_MBEDTLS ON CACHE BOOL "" FORCE)
set(ENABLE_LIBXML2 OFF CACHE BOOL "" FORCE)
set(ENABLE_EXPAT OFF CACHE BOOL "" FORCE)
set(ENABLE_PCREPOSIX OFF CACHE BOOL "" FORCE)
set(ENABLE_PCRE2POSIX OFF CACHE BOOL "" FORCE)
set(ENABLE_CNG OFF CACHE BOOL "" FORCE)
set(ENABLE_LIBB2 OFF CACHE BOOL "" FORCE)
set(ENABLE_LZO OFF CACHE BOOL "" FORCE)

# Enable compression libraries we're providing
set(ENABLE_ZLIB ON CACHE BOOL "" FORCE)
set(ENABLE_BZip2 ON CACHE BOOL "" FORCE)
set(ENABLE_LZMA ON CACHE BOOL "" FORCE)
set(ENABLE_ZSTD ON CACHE BOOL "" FORCE)
set(ENABLE_LZ4 ON CACHE BOOL "" FORCE)

# Set paths to our built libraries
set(ZLIB_INCLUDE_DIR ${DEPS_DIR}/zlib ${CMAKE_CURRENT_BINARY_DIR}/zlib)
set(ZLIB_LIBRARY zlibstatic)
set(ZLIB_FOUND TRUE CACHE BOOL "" FORCE)

set(BZIP2_INCLUDE_DIR ${DEPS_DIR}/bzip2)
set(BZIP2_LIBRARIES bz2_static)
set(BZIP2_FOUND TRUE CACHE BOOL "" FORCE)

set(LIBLZMA_INCLUDE_DIR ${DEPS_DIR}/xz/src/liblzma/api CACHE PATH "" FORCE)
set(LIBLZMA_INCLUDE_DIRS ${DEPS_DIR}/xz/src/liblzma/api CACHE PATH "" FORCE)
set(LIBLZMA_LIBRARY liblzma CACHE STRING "" FORCE)
set(LIBLZMA_LIBRARIES liblzma CACHE STRING "" FORCE)
set(LIBLZMA_FOUND TRUE CACHE BOOL "" FORCE)
set(LIBLZMA_HAS_AUTO_DECODER TRUE CACHE BOOL "" FORCE)
set(LIBLZMA_HAS_EASY_ENCODER TRUE CACHE BOOL "" FORCE)
set(LIBLZMA_HAS_LZMA_PRESET TRUE CACHE BOOL "" FORCE)
set(HAVE_LIBLZMA 1 CACHE BOOL "" FORCE)
set(HAVE_LZMA_H 1 CACHE BOOL "" FORCE)
set(HAVE_LZMA_STREAM_ENCODER_MT 1 CACHE BOOL "" FORCE)

set(ZSTD_INCLUDE_DIR ${DEPS_DIR}/zstd/lib)
set(ZSTD_LIBRARY libzstd_static)
set(ZSTD_FOUND TRUE CACHE BOOL "" FORCE)

# Force ZSTD compression support (skip try_compile since libzstd not built yet)
set(HAVE_ZSTD_compressStream TRUE CACHE BOOL "" FORCE)
set(HAVE_ZSTD_minCLevel TRUE CACHE BOOL "" FORCE)
set(HAVE_LIBZSTD TRUE CACHE BOOL "" FORCE)

set(LZ4_INCLUDE_DIR ${DEPS_DIR}/lz4/lib)
set(LZ4_LIBRARY lz4_static)
set(LZ4_FOUND TRUE CACHE BOOL "" FORCE)

set(MBEDTLS_INCLUDE_DIRS ${DEPS_DIR}/mbedtls/include CACHE PATH "" FORCE)
set(MBEDTLS_LIBRARY mbedtls CACHE STRING "" FORCE)
set(MBEDX509_LIBRARY mbedx509 CACHE STRING "" FORCE)
set(MBEDCRYPTO_LIBRARY mbedcrypto CACHE STRING "" FORCE)
set(MBEDTLS_LIBRARIES mbedtls mbedcrypto mbedx509)
set(MBEDTLS_FOUND TRUE CACHE BOOL "" FORCE)
list(APPEND CMAKE_REQUIRED_INCLUDES ${MBEDTLS_INCLUDE_DIRS})

# Force mbedTLS crypto support (skip try_compile since mbedcrypto not built yet)
set(ARCHIVE_CRYPTO_MD5_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_RMD160_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA1_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA256_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA384_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA512_MBEDTLS TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_MD5 TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_RMD160 TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA1 TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA256 TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA384 TRUE CACHE BOOL "" FORCE)
set(ARCHIVE_CRYPTO_SHA512 TRUE CACHE BOOL "" FORCE)

add_subdirectory(${DEPS_DIR}/libarchive ${CMAKE_CURRENT_BINARY_DIR}/libarchive)

# =============================================================================
# Build Ring Archive Extension
# =============================================================================
add_library(ring_archive SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/src/c_src/ring_archive.c
)

target_include_directories(ring_archive PRIVATE
    ${RING_INCLUDE}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/c_src
    ${DEPS_DIR}/libarchive/libarchive
    ${CMAKE_CURRENT_BINARY_DIR}/libarchive
    ${DEPS_DIR}/zlib
    ${CMAKE_CURRENT_BINARY_DIR}/zlib
    ${DEPS_DIR}/bzip2
    ${DEPS_DIR}/xz/src/liblzma/api
    ${DEPS_DIR}/zstd/lib
    ${DEPS_DIR}/lz4/lib
)

# Link everything statically into the shared library
target_link_libraries(ring_archive PRIVATE
    Ring::Ring
    archive_static
    zlibstatic
    bz2_static
    liblzma
    libzstd_static
    lz4_static
    brotlidec
    brotlienc
    brotlicommon
    mbedtls
    mbedcrypto
    mbedx509
)

# Windows system libraries required by mbedTLS and libarchive
if(WIN32)
    target_compile_definitions(ring_archive PRIVATE LIBARCHIVE_STATIC)
    target_link_libraries(ring_archive PRIVATE
        ws2_32
        bcrypt
        advapi32
    )
endif()

target_compile_options(ring_archive PRIVATE
    $<$<CONFIG:Release,RelWithDebInfo,MinSizeRel>:
        $<$<C_COMPILER_ID:MSVC>:/O2>
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:-O3>
        -DNDEBUG
    >
)

# Set target properties
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(ring_archive PROPERTIES
        OUTPUT_NAME "ring_archive"
    )
else()
    set_target_properties(ring_archive PROPERTIES
        PREFIX "lib"
        OUTPUT_NAME "ring_archive"
    )
endif()

# Move built library to lib directory
add_custom_command(
    TARGET ring_archive
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LIB_DEST_DIR}
    COMMAND ${CMAKE_COMMAND} -E rename $<TARGET_FILE:ring_archive> ${LIB_DEST_DIR}/$<TARGET_FILE_NAME:ring_archive>
    COMMENT "Moving built library to ${LIB_DEST_DIR}"
    VERBATIM
)

# Copy to bin directory on Windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    add_custom_command(
        TARGET ring_archive
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RING_BIN}
        COMMAND ${CMAKE_COMMAND} -E copy ${LIB_DEST_DIR}/$<TARGET_FILE_NAME:ring_archive> ${RING_BIN}/$<TARGET_FILE_NAME:ring_archive>
        COMMENT "Copying built library to bin directory"
        VERBATIM
    )
endif()

install(TARGETS ring_archive
    LIBRARY DESTINATION "${RING_ROOT}/lib"
)

message(STATUS "Ring Archive Extension Configuration:")
message(STATUS "  - Ring Include Dir: ${RING_INCLUDE_DIR}")
message(STATUS "  - Ring Library Path: ${RING_LIBRARY_PATH}")
message(STATUS "  - Dependencies from: ${DEPS_DIR}")
