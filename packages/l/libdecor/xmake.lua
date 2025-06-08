package("libdecor")
    set_homepage("https://gitlab.freedesktop.org/libdecor/libdecor")
    set_description("A client-side decorations library for Wayland client")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/libdecor/libdecor/-/archive/$(version)/libdecor-$(version).tar.gz",
             "https://gitlab.freedesktop.org/libdecor/libdecor.git")
    add_versions("0.2.3", "21a471e3f48088d3fd8ecc5999c45258a32198782c0157482f7ebe82de42f79c")

    add_configs("dbus", {description = "Use D-Bus to fetch cursor settings", default = false, type = "boolean"})
    add_configs("gtk", {description = "Build GTK plugin", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    add_deps("wayland", "wayland-protocols", "pango")

    on_load(function (package)
        if package:config("dbus") then
            package:add("deps", "dbus")
        end
        if package:config("gtk") then
            package:add("deps", "gtk3")
        end
    end)

    on_install("linux|native", function (package)
        local configs = {"-Ddemo=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Ddbus=" .. (package:config("dbus") and "enabled" or "disabled"))
        table.insert(configs, "-Dgtk=" .. (package:config("gtk") and "enabled" or "disabled"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdecor_new", {includes = "libdecor-0/libdecor.h"}))
    end)
