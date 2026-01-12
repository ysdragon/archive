aPackageInfo = [
	:name = "Archive",
	:description = "Archive manipulation library for Ring programming language.",
	:folder = "archive",
	:developer = "ysdragon",
	:email = "youssefelkholey@gmail.com",
	:license = "MIT License",
	:version = "1.0.0",
	:ringversion = "1.25",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "",
			:version = "",
			:providerusername = ""
		]
	],
	:files = 	[
		"lib.ring",
		"main.ring",
		"CMakeLists.txt",
		"examples/01_list_contents.ring",
		"examples/02_extract_archive.ring",
		"examples/03_create_archive.ring",
		"examples/04_read_specific_file.ring",
		"examples/05_list_with_details.ring",
		"examples/06_archive_helper_class.ring",
		"examples/07_oop_reader.ring",
		"examples/08_read_file_content.ring",
		"examples/09_oop_writer.ring",
		"examples/10_archive_entry_class.ring",
		"examples/11_add_from_disk.ring",
		"examples/12_different_formats.ring",
		"examples/13_more_formats.ring",
		"examples/14_symlinks.ring",
		"examples/15_encrypted_zip.ring",
		"examples/16_encryption_methods.ring",
		"examples/17_memory_archives.ring",
		"examples/18_raw_data_reading.ring",
		"examples/19_low_level_api.ring",
		"examples/20_error_handling.ring",
		"examples/21_error_handling_detailed.ring",
		"examples/22_complete_example.ring",
		"LICENSE",
		"README.md",
		"src/archive.ring",
		"src/archive.rh",
		"src/c_src/ring_archive.c",
		"src/utils/color.ring",
		"src/utils/install.ring",
		"src/utils/uninstall.ring"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[
		"lib/windows/i386/ring_archive.dll",
		"lib/windows/amd64/ring_archive.dll",
		"lib/windows/arm64/ring_archive.dll"
	],
	:linuxfiles = 	[
		"lib/linux/amd64/libring_archive.so",
		"lib/linux/arm64/libring_archive.so",
		"lib/linux/musl/amd64/libring_archive.so",
		"lib/linux/musl/arm64/libring_archive.so"
	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:macosfiles = 	[
		"lib/macos/amd64/libring_archive.dylib",
		"lib/macos/arm64/libring_archive.dylib"
	],
	:freebsdfiles = 	[
		"lib/freebsd/amd64/libring_archive.so"
	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = "",
    :remotefolder = "archive",
    :branch = "master",
    :providerusername = "ysdragon",
    :providerwebsite = "github.com"
]