package("fltk")
    set_homepage("https://www.fltk.org")
    set_description("Fast Light Toolkit")

    add_urls("https://github.com/fltk/fltk/archive/refs/tags/release-$(version).tar.gz", {alias = "archive"})
    add_urls("https://github.com/fltk/fltk.git", {alias = "github"})

    add_versions("archive:1.4.3", "6a11c0bf91b7b193a87a1928c32a953f36d7dd4b65fef3e9d0c40a51882f97a6")
    add_versions("archive:1.3.9", "f30661851a61f1931eaaceb9ef4005584c85cb07fd7ffc38a645172b8e4eb3df")

    add_versions("github:1.4.3", "release-1.4.3")
    add_versions("github:1.3.9", "release-1.3.9")

    add_patches("1.3.9", "patches/1.3.9/cmake-fluid.patch", "06ee1e82a74651a0b4ba4b386e5e5436d8b95584330d02a8a2c53351210a9127")

    if is_plat("linux") then
        add_configs("pango", {description = "Use pango for font support (required if Wayland is enabled)", default = false, type = "boolean"})
        add_configs("xft", {description = "Use libXft for font support", default = false, type = "boolean"})
    end
    if is_plat("linux", "bsd", "cross") then
        add_configs("x11", {description = "Use X11", default = true, type = "boolean"})
        add_configs("wayland", {description = "Support the Wayland backend", default = true, type = "boolean"})
        add_configs("libdecor", {description = "Use libdecor's GTK plugin", default = false, type = "boolean"})
    end
    add_configs("fluid", {description = "Build fluid", default = false, type = "boolean"})
    add_configs("forms", {description = "Build forms", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "comctl32", "gdi32", "oleaut32", "ole32", "uuid", "shell32", "advapi32", "comdlg32", "winspool", "user32", "kernel32", "odbc32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa")
    elseif is_plat("android") then
        add_syslinks("android")
        add_syslinks("dl")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
        add_deps("fontconfig")
    end

    add_deps("cmake")
    add_deps("zlib", "libpng", "libjpeg-turbo")

    on_load(function (package)
        if package:is_plat("linux", "bsd", "cross") then
            if package:config("x11") then
                package:add("deps", "libx11", "libxext", "libxinerama", "libxcursor", "libxrender", "libxfixes")
            end
            if package:config("wayland") then
                package:add("deps", "wayland", "wayland-protocols", "dbus", "libxkbcommon", "libdecor")
                package:config_set("pango", true)
            end
        end
        if package:is_plat("linux") then
            if package:version() and package:version():eq("1.3.9") then
                assert(not package:config("fluid"), "package(fltk/1.3.9): Unsupported fluid on linux")
            end
            if package:config("pango") then
                package:add("deps", "pango")
            end
            if package:config("xft") then
                package:add("deps", "libxft")
            end
            if package:config("libdecor") and package:config("wayland") then
                package:add("deps", "libdecor")
            end
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "msys", function (package)
        for _, file in ipairs(os.files("**.cxx")) do
            io.replace(file, "<libpng/png.h>", "<png.h>", {plain = true})
        end

        local configs = {
            "-DFLTK_BUILD_TEST=OFF",
            "-DFLTK_BUILD_EXAMPLES=OFF",
            "-DOPTION_USE_SYSTEM_LIBPNG=ON",
            "-DOPTION_USE_SYSTEM_ZLIB=ON",
            "-DOPTION_USE_SYSTEM_LIBJPEG=ON",
            -- FLTK 1.4.x uses different CMake option names
            "-DFLTK_USE_SYSTEM_LIBPNG=ON",
            "-DFLTK_USE_SYSTEM_ZLIB=ON",
            "-DFLTK_USE_SYSTEM_LIBJPEG=ON",
            "-DFLTK_USE_SYSTEM_LIBDECOR=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOPTION_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_MSVC_RUNTIME_DLL=" .. (package:has_runtime("MD") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_BUILD_FLUID=" .. (package:config("fluid") and "ON" or "OFF"))
        table.insert(configs, "-DFLTK_BUILD_FORMS=" .. (package:config("forms") and "ON" or "OFF"))
        if package:is_plat("linux") then
            table.insert(configs, "-DOPTION_USE_PANGO=" .. (package:config("pango") and "ON" or "OFF"))
            table.insert(configs, "-DFLTK_USE_PANGO=" .. (package:config("pango") and "ON" or "OFF"))
            table.insert(configs, "-DOPTION_USE_XFT=" .. (package:config("xft") and "ON" or "OFF"))
            table.insert(configs, "-DFLTK_USE_XFT=" .. (package:config("xft") and "ON" or "OFF"))
        end
        if package:is_plat("linux", "bsd", "cross") then
            table.insert(configs, "-DFLTK_BACKEND_X11=" .. (package:config("x11") and "ON" or "OFF"))
            table.insert(configs, "-DFLTK_BACKEND_WAYLAND=" .. (package:config("wayland") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "FL/Fl.H"
            #include "FL/Fl_Window.H"
            void test() {
                Fl_Window *win = new Fl_Window(400, 300);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
