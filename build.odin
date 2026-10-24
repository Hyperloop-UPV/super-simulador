#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package build

import "core:slice"
import "base:runtime"
import "base:intrinsics"

import "core:os"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:flags"
import "core:dynlib"
import "core:reflect"

import custom_log "src/logger"

import "usim"

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
  run: bool `usage:"Also run the simulator after building"`,
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
  append(&cmd,
    "odin", "build", "src",
    "-out:" + SIMULATOR_EXE,
    "-error-pos-style:unix",
    /* import mcu "mcu:stm32h723xx" */
    "-collection:mcu=mcu",
  )

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

do_linux_syscalls_codegen :: proc() -> bool
{
  when ODIN_OS == .Linux {
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
  }

  return true
}

write_string :: proc(f: ^os.File, s: string) {
  _, err := os.write_string(f, s)
  if err != nil {
    fmt.eprintfln("could not write codegen string '%s': %v", s, err)
    os.exit(1)
  }
}

C_print_any_elem_from_odin :: proc(f: ^os.File, type: ^reflect.Type_Info, name: string, known_type_names: []string, prefix := "USim_")
{
  switch v in reflect.type_info_base(type).variant {
    case runtime.Type_Info_Named: {
      // should not be a field in a struct
      assert(false)
    }
    case runtime.Type_Info_Parameters: {
      // should not be a field in a struct
      assert(false)
    }

    case runtime.Type_Info_Complex: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Quaternion: { fmt.assertf(false, "unsupported") } 
    case runtime.Type_Info_Any: { fmt.assertf(false, "unsupported") } 
    case runtime.Type_Info_Type_Id: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Enumerated_Array: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Union: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Map: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Simd_Vector: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Matrix: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Soa_Pointer: { fmt.assertf(false, "unsupported") }
    case runtime.Type_Info_Bit_Field: { fmt.assertf(false, "unsupported") }
    // NOTE: not sure about fixed capacity dynamic array, might be easy but I don't
    //       think I have debug info for it so I can't know the implementation without
    //       looking at the odin compiler source code
    case runtime.Type_Info_Fixed_Capacity_Dynamic_Array: { fmt.assertf(false, "unsupported") }

    case runtime.Type_Info_Integer: {
      type_name := "int" if v.signed else "unsigned int"
      s := fmt.tprintf("%s", type_name)
      write_string(f, s)
    }

    case runtime.Type_Info_Rune: {
      write_string(f, "uint32_t")
    }

    case runtime.Type_Info_Float: {
      write_string(f, "float")
    }

    case runtime.Type_Info_String: {
      // odin cstring and odin string (utf8 encoded)
      type_name := "const char*" if v.is_cstring else \
        "struct { const char* items; size_t count; }"
      write_string(f, type_name)
    }

    case runtime.Type_Info_Boolean: {
      write_string(f, "bool")
    }

    // prefer int *a from int * a
    case runtime.Type_Info_Pointer: {
      // e.g. "int*", "void*"
      if v.elem == nil {
        write_string(f, "void *")
        write_string(f, name)
        return
      } else {
        C_print_any_elem_from_odin(f, v.elem, "", known_type_names)
        write_string(f, "*")
        write_string(f, name)
        return
      }
    }
    case runtime.Type_Info_Multi_Pointer: {
      // multi pointer is the same for C as pointer
      if v.elem == nil {
        write_string(f, "void *")
        write_string(f, name)
        return
      } else {
        C_print_any_elem_from_odin(f, v.elem, "", known_type_names)
        write_string(f, "*")
        write_string(f, name)
        return
      }
    }

    case runtime.Type_Info_Procedure: {
      CDecl :: 3
      fmt.assertf(v.convention == runtime.Calling_Convention(CDecl),
        "Calling convention must be Cdecl (\"c\") to translate it into C function pointer",
      )
      fmt.assertf(!v.variadic, "varadic procedures are not supported")

      result_types: []^runtime.Type_Info
      if v.results != nil {
        results := v.results.variant.(runtime.Type_Info_Parameters)
        fmt.assertf(len(results.types) <= 1, "procedures with more than one return are not supported")
        result_types = results.types
      }
        
      if len(result_types) == 0 {
        write_string(f, "void (*")
      } else {
        C_print_any_elem_from_odin(f, result_types[0], "", known_type_names)
        write_string(f, "(*")
      }
      write_string(f, name)
      write_string(f, ")(")

      if v.params != nil {
        params := v.params.variant.(runtime.Type_Info_Parameters)
        for idx := 0; idx < len(params.types); idx += 1 {
          C_print_any_elem_from_odin(f, params.types[idx], params.names[idx], known_type_names)
          if idx != (len(params.types) - 1) {
            write_string(f, ", ")
          }
        }
        write_string(f, ")")
      }

      return
    }

    case runtime.Type_Info_Array: {
      C_print_any_elem_from_odin(f, v.elem, "", known_type_names)
      write_string(f, fmt.tprintf("[%d]", v.count))
    }

    case runtime.Type_Info_Dynamic_Array: {
      // [dynamic]type -> struct{ type* items; size_t count; size_t capacity; }
      write_string(f, "struct{ ")
      C_print_any_elem_from_odin(f, v.elem, "", known_type_names)
      write_string(f, "* items; size_t count; size_t capacity; }")
    }

    case runtime.Type_Info_Slice: {
      // []type -> struct{ const type* items; size_t count; }
      write_string(f, "struct{ const ")
      C_print_any_elem_from_odin(f, v.elem, "", known_type_names)
      write_string(f, "* items; size_t count; }")
    }

    case runtime.Type_Info_Struct: {
      named := type.variant.(runtime.Type_Info_Named)
      _, found := slice.linear_search(known_type_names, named.name)
      if found {
        write_string(f, prefix)
        write_string(f, named.name)
      } else {
        if .raw_union in v.flags {
          write_string(f, "union{ ")
        } else {
          write_string(f, "struct{ ")
        }
        for idx: i32 = 0; idx < v.field_count; idx += 1 {
          C_print_any_elem_from_odin(f, v.types[idx], v.names[idx], known_type_names)
          write_string(f, "; ")
        }
        write_string(f, "}")
      }
    }

    case runtime.Type_Info_Enum: {
      named := type.variant.(runtime.Type_Info_Named)
      write_string(f, prefix)
      write_string(f, named.name)
    }

    case runtime.Type_Info_Bit_Set: {
      // bit_set[Type; Underlying] -> Underlying
      C_print_any_elem_from_odin(f, v.underlying, "", known_type_names)
    }
  }

  write_string(f, " ")
  write_string(f, name)
}

C_struct_from_odin_struct :: proc(f: ^os.File, t: reflect.Type_Info_Struct, known_type_names: []string, indentation := 2, indent_width := 2, prefix := "USim_")
{
  indent_buf: [32]u8
  mem.set(&indent_buf, ' ', len(indent_buf))
  indent := string(indent_buf[:indentation])

  for idx: i32 = 0; idx < t.field_count; idx += 1 {
    type := t.types[idx]
    name := t.names[idx]

    write_string(f, indent)
    found: bool = false
    if reflect.is_struct(type) {
      named := type.variant.(runtime.Type_Info_Named)
      _, found = slice.linear_search(known_type_names, named.name)
      if found {
        write_string(f, prefix)
        write_string(f, named.name)
        write_string(f, " ")
        write_string(f, name)
        write_string(f, ";\n")
        continue
      }
    }

    C_print_any_elem_from_odin(f, type, name, known_type_names, prefix)
    write_string(f, ";\n")
  }
}

do_usim_codegen :: proc() -> bool
{
  output_lib := "usim/usim.h"
  f, err := os.open(output_lib, {.Write, .Trunc, .Create})
  fmt.assertf(err == nil, "could not open '%s' file for writing: %v", output_lib, err)
  defer os.close(f)

  known_structs := []string{
    "Event",
    "API",
  }

  write_string(f,
    "#ifndef USIM_H\n" +
    "#define USIM_H\n" +
    "\n",
  )

  write_string(f,
    "/* THIS IS AN AUTOGENERATED FILE, DO NOT MODIFY */\n\n",
  )

  write_string(f, "typedef enum USim_Event_Kind {\n")
  for kind in reflect.enum_fields_zipped(usim.Event_Kind) {
    line := fmt.tprintfln("  %s = %v", kind.name, i64(kind.value))
    write_string(f, line)
  }
  write_string(f, "} USim_Event_Kind;\n\n")

  write_string(f, "typedef struct USim_Event {\n")
  event_struct_named := type_info_of(usim.Event).variant.(runtime.Type_Info_Named)
  event_struct := event_struct_named.base.variant.(runtime.Type_Info_Struct)
  C_struct_from_odin_struct(f, event_struct, known_structs, prefix = "USim_")
  write_string(f, "} USim_Event;\n\n")

  write_string(f, "typedef struct USim_API {\n")
  api_struct_named := type_info_of(usim.API).variant.(runtime.Type_Info_Named)
  api_struct := api_struct_named.base.variant.(runtime.Type_Info_Struct)
  C_struct_from_odin_struct(f, api_struct, known_structs, prefix = "USim_")
  write_string(f, "} USim_API;\n\n")

  write_string(f, "#endif // USIM_H\n")

  return true
}

do_codegen :: proc() -> bool
{
  do_linux_syscalls_codegen() or_return
  do_usim_codegen() or_return

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

  if opt.run {
    ok := run_command({
      "sim",
      "--board", "board." + dynlib.LIBRARY_FILE_EXTENSION,
      "--max-iterations", "1000_000",
    })
    if !ok {
      os.exit(1)
    }
  }
}
