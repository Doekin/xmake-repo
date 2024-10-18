package("zbar")
    set_homepage("https://github.com/mchehab/zbar")
    set_description("Library for reading bar codes from various sources")
    set_license("LGPL-2.1")

    add_urls("https://github.com/mchehab/zbar/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mchehab/zbar.git")
    add_versions("0.23.93", "212dfab527894b8bcbcc7cd1d43d63f5604a07473d31a5f02889e372614ebe28")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::zbar")
    elseif is_plat("linux") then
        add_extsources("pacman::zbar", "apt::libzbar-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::zbar")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if is_plat("macosx") then
        add_deps("libiconv", {system = true})
    else
        add_deps("libiconv")
    end

    on_install("!iphoneos and !windows", function (package)
        os.cp(path.join(package:scriptdir(), "port", "config.h"), "include/config.h")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                zbar_image_scanner_t *scanner ;
                scanner = zbar_image_scanner_create();
                zbar_image_scanner_set_config(scanner, 0, ZBAR_CFG_ENABLE, 1);
                zbar_image_scanner_destroy(scanner);
            }
        ]]}, {includes = "zbar.h"}))
    end)
