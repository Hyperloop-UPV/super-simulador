#define VL_BUILD_IMPLEMENTATION
#include "include/vl_build.h"

/*
in libs, only an sdl static library is expected
*/
bool build_imgui(vl_file_paths *libs)
{
  MkdirIfNotExist("vendor/imgui/obj");

  vl_cmd cmd = {0};
  vl_compile_ctx ctx = {
    .cc = CCompiler_GPlusPlus,
    .type = Compile_Object,
    .debug = true,
    .gcSections = true,
    .warnings = false,
    .sourceFiles = VL_GetDaStrSlice("vendor/imgui/*"),

    .includePaths = VL_GetDaStrSlice("include"),
    .libPaths = VL_GetDaStrSlice("lib"),
    .libs = *libs,
  };

  if(VL_NeedsRebuild("bin/imgui.o", "vendor/imgui/imgui.cpp")) {
    if(!VL_CCompile(&cmd, &ctx)) {
      VL_Log(VL_ERROR, "Could not build dear imgui libs");
      return false;
    }

    VL_MoveFile("imgui_draw.o", "bin/imgui_draw.o");
    VL_MoveFile("imgui_impl_sdl3.o", "bin/imgui_impl_sdl3.o");
    VL_MoveFile("imgui_impl_sdlrenderer3.o", "bin/imgui_impl_sdlrenderer3.o");
    VL_MoveFile("imgui_tables.o", "bin/imgui_tables.o");
    VL_MoveFile("imgui_widgets.o", "bin/imgui_widgets.o");
    VL_MoveFile("imgui.o", "bin/imgui.o");
    VL_MoveFile("implot_items.o", "bin/implot_items.o");
    VL_MoveFile("implot.o", "bin/implot.o");
  }

  return true;
}

int main(int argc, char **argv)
{
  //VL_GO_REBUILD_URSELF(argc, argv);

  MkdirIfNotExist("dynamic_libs");
  MkdirIfNotExist("bin");

  vl_cmd cmd = {0};
  vl_install_info info = {
    .mode = VL_INSTALL_MODE_RELEASE,
  };
  if(!Install_SDL3(&cmd, &info)) {
    VL_Log(VL_ERROR, "Could not install SDL3");
    return 1;
  }

  if(!build_imgui(&info.libs)) {
    return 1;
  }

  vl_compile_ctx ctx = {
    .cc = CCompiler_GPlusPlus,
    .type = Compile_DynamicLibrary,
    .debug = true,
    .gcSections = true,
    .warnings = true,

    .sourceFiles = VL_GetDaStrSlice(
      "src/main.cpp",
      "bin/*.o"
    ),
    .output = "usim-vis",
    .outputDir = "bin",

    .includePaths = VL_GetDaStrSlice("include"),
    .libs = info.libs,
    .libPaths = VL_GetDaStrSlice("lib"),
  };

  if(!VL_CCompile(&cmd, &ctx)) {
    VL_Log(VL_ERROR, "Could not compile main.c");
    return 1;
  }

  return 0;
}
