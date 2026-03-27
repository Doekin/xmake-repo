package("libtorrent-rasterbar")
    set_homepage("https://libtorrent.org")
    set_description("An efficient feature complete C++ bittorrent implementation")
    set_license("BSD-3-Clause")

    -- Use the release tarball instead of Git ref archive to include submodule dependencies
    add_urls("https://github.com/arvidn/libtorrent/releases/download/v$(version)/libtorrent-rasterbar-$(version).tar.gz")
    add_urls("https://github.com/arvidn/libtorrent.git", {alias = "git"})

    add_versions("2.0.11", "f0db58580f4f29ade6cc40fa4ba80e2c9a70c90265cd77332d3cdec37ecf1e6d")
    add_versions("git:2.0.11", "v2.0.11")

    add_configs("gnutls", {description = "Build using GnuTLS instead of OpenSSL", default = false, type = "boolean", readonly = true})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libtorrent-rasterbar")
    elseif is_plat("linux") then
        add_extsources("pacman::libtorrent-rasterbar", "apt::libtorrent-rasterbar-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libtorrent-rasterbar")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "mswsock")
    end

    add_deps("cmake")
    add_deps("boost", {configs = {asio = true, multiprecision = true}})

    on_load(function (package)
        if package:config("gnutls") then
            package:add("deps", "gnutls")
        else
            package:add("deps", "openssl3")
        end
    end)

    on_install("!wasm and !macosx and !iphoneos", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                lt::session s;
                lt::add_torrent_params p;
                p.save_path = ".";
                s.add_torrent(p);
            }
        ]]}, {includes = "libtorrent/session.hpp"}))
    end)
