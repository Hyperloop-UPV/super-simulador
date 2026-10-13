#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package build

import "core:os"
import "core:fmt"
import "core:log"
import "core:flags"
import "core:dynlib"

import custom_log "src/logger"

SIMULATOR_NAME :: "sim"

when ODIN_OS == .Windows {
  SIMULATOR_EXE :: SIMULATOR_NAME + ".exe"
} else {
  SIMULATOR_EXE :: SIMULATOR_NAME
}

OUTPUT_DIR :: #config(OUTPUT_DIR, "bin")

Build_Mode :: enum {
  debug,
  release,
  /* release with debug info */
  rel_debug,
}

Build_Options :: struct {
  mode: Build_Mode `args:"pos=0" usage:"Build mode, can be debug, release or rel-debug for release with debug info"`,
  disable_profiling: bool `usage:"Disable or enable profiling. Profiling is enabled by default"`,
}

run_command :: proc(cmd: []string, cwd := ".") -> (ok: bool)
{
  desc := os.Process_Desc{
    command = cmd,
    working_dir = cwd,
  }
  log.infof("Running %v", cmd)
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

build :: proc(opt: Build_Options) -> bool
{
  cmd: [dynamic; 256]string
  append(&cmd, "odin", "build", "src", "-out:" + SIMULATOR_EXE, "-error-pos-style:unix")

  if opt.mode == .debug || opt.mode == .rel_debug {
    append(&cmd, "-debug")
  }

  if opt.mode == .release || opt.mode == .rel_debug {
    append(&cmd, "-o:speed", "-no-type-assert", "-no-bounds-check")
  }

  run_command(cmd[:]) or_return
  clear(&cmd)

  append(&cmd, "gcc",
    "example/src/main.cpp",
    "example/src/system_stm32h7xx.c",
    "-DSTM32H723xx",
    "-DSIMULATOR_BUILD",
    "-shared",
    "-o", "board." + dynlib.LIBRARY_FILE_EXTENSION,
    "-Wall", "-Wextra",
    "-I", "example/inc",
    "-Wl,--gc-sections",
  )

  when ODIN_OS == .Windows {
    append(&cmd, "-Wl,--export-all-symbols")
  } else {
    append(&cmd, "-fPIC")
  }

  if opt.mode == .debug || opt.mode == .rel_debug {
    append(&cmd, "-ggdb")
  }

  if opt.mode == .release || opt.mode == .rel_debug {
    append(&cmd, "-O2")
  }

  run_command(cmd[:]) or_return
  clear(&cmd)

  return true
}

do_codegen :: proc() -> bool
{
  cmd := []string{
    "gcc",
    "ioctl_defs_linux.c",
    "-o", "../bin/codegen",
    "-Wall", "-Wextra",
    "-Werror",
  }

  run_command(cmd, cwd = "codegen") or_return

  cmd = []string{
    "bin/codegen",
  }

  run_command(cmd) or_return

  return true
}

main :: proc()
{
  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)

  opt: Build_Options
  flags.parse_or_exit(&opt, os.args, .Unix)

  os.mkdir(OUTPUT_DIR)

  if !do_codegen() {
    log.error("Codegen failed")
    os.exit(1)
  }

  if !build(opt) {
    log.error("Build failed")
    os.exit(1)
  }
}
