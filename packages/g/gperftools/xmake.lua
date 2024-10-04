package("gperftools")

    set_homepage("https://github.com/gperftools/gperftools")
    set_description("gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gperftools/gperftools/archive/refs/tags/gperftools-$(version).tar.gz")
    add_versions("2.16", "737be182b4e42f5c7f595da2a7aa59ce0489a73d336d0d16847f2aa52d5221b4")
    add_versions("2.15", "3918ff2e21bb3dbb5a801e1daf55fb20421906f7c42fbb482bede7bdc15dfd2e")
    add_versions("2.14", "ab456a74af2f57a3ee6c20462f73022d11f7ffc22e470fc06dec39692c0ee5f3")
    add_versions("2.13", "fd43adbe0419cb0eaaa3e439845cc89fe7d42c22eff7fd2d6b7e87ae2acbce1d")
    add_versions("2.12", "1cc42af8c0ec117695ecfa49ef518d9eaf7b215a2657b51f655daa2dc07101ce")
    add_versions("2.11", "b0d32b3d82da0ddac2a347412b50f97efddeae66dfbceb49455b7262fb965434")
    add_versions("2.10", "b0dcfe3aca1a8355955f4b415ede43530e3bb91953b6ffdd75c45891070fe0f1")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = is_plat("windows")})
    if is_plat("linux") then
        add_configs("unwind", {description = "Enable libunwind support.", default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_load("linux", function (package)
        if package:config("unwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-Dgperftools_build_benchmark=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DGPERFTOOLS_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("linux") then
            table.insert(configs, "-Dgperftools_enable_libunwind=" .. (package:config("unwind") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tc_version", {includes = "gperftools/tcmalloc.h"}))
    end)
