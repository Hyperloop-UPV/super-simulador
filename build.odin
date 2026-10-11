#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package build

import "core:os"
import "core:fmt"
import "core:log"
import "core:dynlib"

import custom_log "src/logger"

SIMULATOR_NAME :: "sim"

when ODIN_OS == .Windows {
  SIMULATOR_EXE :: SIMULATOR_NAME + ".exe"
} else {
  SIMULATOR_EXE :: SIMULATOR_NAME
}

run_command :: proc(cmd: ..string) -> (ok: bool)
{
  desc := os.Process_Desc{
    command = cmd[:],
  }
  log.infof("Running %v", cmd[:])
  state, stdout, stderr, err := os.process_exec(desc, context.temp_allocator)
  if err != nil {
    log.errorf("Could not start process %v: %v", cmd, err)
    return
  }

  if len(stdout) != 0 {
    fmt.print(string(stdout))
  }
  if len(stderr) != 0 {
    fmt.eprint(string(stderr))
  }

  if state.exit_code != 0 {
    log.errorf("%s exited with return code %d", cmd[0], state.exit_code)
  } else {
    ok = true
  }

  return
}

build_debug :: proc() -> bool
{
  run_command("odin", "build", "src", "-out:" + SIMULATOR_EXE, "-error-pos-style:unix",
    "-debug",
  ) or_return
  run_command(
    "gcc",
    "example/src/main.cpp",
    "example/src/system_stm32h7xx.c",
    "-DSTM32H723xx",
    "-DSIMULATOR_BUILD",
    "-shared",
    "-o", "board." + dynlib.LIBRARY_FILE_EXTENSION,
    "-Wall", "-Wextra",
    "-I", "example/inc",
    "-ggdb",
    "-Wl,--gc-sections",
    "-Wl,--export-all-symbols",
  ) or_return

  return true
}

build_release :: proc() -> bool
{
  run_command("odin", "build", "src", "-out:" + SIMULATOR_EXE, "-error-pos-style:unix",
    "-o:speed",
    "-no-type-assert",
    "-no-bounds-check",
    "-show-timings",
  ) or_return
  run_command(
    "gcc",
    "example/src/main.cpp",
    "example/src/system_stm32h7xx.c",
    "-DSTM32H723xx",
    "-DSIMULATOR_BUILD",
    "-shared",
    "-o", "board." + dynlib.LIBRARY_FILE_EXTENSION,
    "-Wall", "-Wextra",
    "-I", "example/inc",
    "-O2",
    "-Wl,--gc-sections",
    "-Wl,--export-all-symbols",
  )

  return true
}

main :: proc()
{
  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)

  if !build_debug() {
    log.error("Build failed")
  }
}
