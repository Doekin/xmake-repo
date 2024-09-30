package("npcap_sdk")
    set_homepage("https://npcap.com/")
    set_description("Npcap is the Nmap Project's packet capture (and sending) library for Microsoft Windows.")

    set_urls("https://npcap.com/dist/npcap-sdk-$(version).zip")
    add_versions("1.13", "dad1f2bf1b02b787be08ca4862f99e39a876c1f274bac4ac0cedc9bbc58f94fd")
    add_versions("1.12", "24c4862723f61d28048a24e10eb31d2269b2152a5762410dd1caffc041871337")

    on_load("mingw", function (package)
        if package:version():eq("1.13") then
            package:add("defines", "_Post_invalid_=")
        end
    end)

    on_install("windows", "mingw", function (package)
        os.cp("Include/*", package:installdir("include"))
        if package:is_arch("arm64") then
            os.cp("Lib/ARM64/*", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.cp("Lib/*.lib", package:installdir("lib"))
        else
            os.cp("Lib/x64/*.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PacketGetVersion", {includes = "Packet32.h"}))
    end)
