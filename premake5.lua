project "soloud"
	kind "StaticLib"
	language "C++"

	targetdir ("bin/" .. outputdir .. "/%{prj.name}")
	objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

	files
	{
		"include/**.h",
		"src/core/**.cpp",
		"src/audiosource/wav/**.h",
		"src/audiosource/wav/**.c",
		"src/audiosource/wav/**.cpp",
		"src/audiosource/speech/**.h",
		"src/audiosource/speech/**.cpp",
	}

	includedirs
	{
		"include",
	}

	filter "system:linux"
		pic "On"

		systemversion "latest"
		staticruntime "On"

		files
		{

		}

		defines
		{

		}

	filter "system:windows"
		systemversion "latest"
		staticruntime "On"

		files
		{
			
			--"src/backend/wasapi/**.cpp",
			"src/backend/winmm/**.cpp",
		}

		defines 
		{ 
			"_CRT_SECURE_NO_WARNINGS",
			--"WITH_WASAPI",
			"WITH_WINMM",
		}

	filter "configurations:Debug"
		runtime "Debug"
		symbols "on"

	filter "configurations:Release"
		runtime "Release"
		optimize "on"
