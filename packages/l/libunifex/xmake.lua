package("libunifex")

    set_homepage("https://github.com/facebookexperimental/libunifex/")
    set_description("The 'libunifex' project is a prototype implementation of the C++ sender/receiver async programming model that is currently being considered for standardisation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebookexperimental/libunifex/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.4.0", "d5ce3b616e166da31e6b4284764a1feeba52aade868bcbffa94cfd86b402716e")

    on_install(function (package)
        local configs = {   "-DBUILD_TESTING=OFF",
                            "-DUNIFEX_BUILD_EXAMPLES=OFF",
                        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DALEMBIC_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace unifex;
            using namespace std::chrono;

            auto delay(milliseconds ms) {
                return schedule_after(current_scheduler, ms);
            }
        ]]}, {configs = {languages = "c++17"},includes = {"chrono", "unifex/on.hpp", "unifex/scheduler_concepts.hpp"}}))
    end)
