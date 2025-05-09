package("readline")
    set_homepage("https://tiswww.case.edu/php/chet/readline/rltop.html")
    set_description("Library for command-line editing")
    set_license("GPL-3.0-or-later")

    add_urls("https://ftpmirror.gnu.org/readline/readline-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/readline/readline-$(version).tar.gz")

    add_versions("8.2.13", "0e5be4d2937e8bd9b7cd60d46721ce79f88a33415dd68c2d738fb5924638f656")
    add_versions("8.2", "3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35")
    add_versions("8.1", "f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02")

    -- Patch adopted from MSYS2
    -- add_patches("8.2.13", "patches/8.2.13/0001-sigwinch.patch", "2b30dcb0804abb6e7e4f44cd119bddef94c1b1d7ebff43dda401e710eda2fd0f")
    -- add_patches("8.2.13", "patches/8.2.13/0002-event-hook.patch", "5a5ab63e87a025af39b3e5101b171d16bd5d227f350f036a32193496d12bcbe2")
    -- add_patches("8.2.13", "patches/8.2.13/0003-fd_set.patch", "6329d02c9e151951136a31cce036f952f95f80a63d60694539839b9c706857e9")
    -- add_patches("8.2.13", "patches/8.2.13/0004-locale.patch", "72ed438ae142ba9d5498652dfdf4fb517265bcf9a67199b7c5b35cc24fa25b9e")

    add_patches("8.2.13", "patches/8.2.13/mingw.patch", "3b5576e51471b248f5c89e0d4c01ac0bc443a239169fa19e25980f9a923f659a")

    -- add_deps("patch")
    add_deps("ncurses")

    on_install("linux", "macosx", "mingw", function (package)
        local configs = {"--with-curses"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        local cflags = {}
        if package:is_plat("mingw") then
            table.insert(cflags, "-DNEED_EXTERN_PC=1") -- Use extern PC variable from ncurses
            table.join2(cflags, {"-D__USE_MINGW_ALARM", "-D_POSIX"}) -- Make mingw-w64 provide a dummy alarm() function
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("readline", {includes = {"stdio.h", "readline/readline.h"}}))
    end)
