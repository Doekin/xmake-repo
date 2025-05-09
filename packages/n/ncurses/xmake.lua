package("ncurses")
    set_homepage("https://invisible-island.net/ncurses/")
    set_description("A free software emulation of curses.")
    set_license("MIT")

    add_urls("https://ftpmirror.gnu.org/ncurses/ncurses-$(version).tar.gz",
             "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(version).tar.gz",
             "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz")

    add_versions("6.1", "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17")
    add_versions("6.2", "30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d")
    add_versions("6.3", "97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059")
    add_versions("6.4", "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159")
    add_versions("6.5", "136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6")

    add_patches(">=6.3", "patches/6.3/libs.patch", "dc4261b6642058a9df1c0945e2409b24f84673ddc3a665d8a15ed3580e51ee25")
    add_patches(">=6.3", "patches/6.3/pkgconfig.patch", "b8544a607dfbeffaba2b087f03b57ed1fa81286afca25df65f61b04b5f3b3738")

    add_configs("widec", {description = "Compile with wide-char/UTF-8 code.", default = true, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libncurses-dev")
    end

    on_load(function (package)
        if package:is_cross() then
            package:add("deps", "ncurses~host", {kind = "binary", private = true})
        end
        if package:config("widec") then
            package:add("links", "ncursesw", "formw", "panelw", "menuw")
            package:add("includedirs", "include/ncursesw", "include")
        else
            package:add("links", "ncurses", "form", "panel", "menu")
            package:add("includedirs", "include/ncurses", "include")
        end

        if not package:config("shared") then
            package:add("defines", "NCURSES_STATIC")
        end
    end)

    on_install("linux", "macosx", "bsd", "msys", "mingw", function (package)
        local configs = {
            "--without-manpages",
            "--enable-sigwinch",
            "--with-gpm=no",
            "--without-tests",
            "--without-ada",
        }
        if package:is_cross() then
            local tic = package:dep("ncurses"):installdir("bin", "tic" .. (is_host("windows") and ".exe" or ""))
            if os.isfile(tic) then
                table.insert(configs, "--with-tic-path=" .. path:unix(tic))
            end
        end
        local cxflags = {}
        if package:is_plat("msys", "mingw") then
            table.insert(cxflags, "-D__USE_MINGW_ACCESS")
            table.insert(configs, "--enable-term-driver")
        end

        table.insert(configs, "--with-debug=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "--with-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-widec=" .. (package:config("widec") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs, {arflags = {"-curvU"}, cxflags = cxflags})
        if package:config("widec") then
            os.trycp(package:installdir("include", "ncursesw", "**"), package:installdir("include", "ncurses"))
            local suffix = (not package:config("shared")) and ".a"
            suffix = suffix or (package:is_plat("msys", "mingw") and ".dll.a" or ".so")
            os.trycp(path.join(package:installdir("lib"), "libncursesw" .. suffix), path.join(package:installdir("lib"), "libncurses" .. suffix))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initscr", {includes = "curses.h"}))
    end)
