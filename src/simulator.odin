#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:time"
import "core:thread"
import "core:dynlib"
import "core:mem/virtual"
import "core:reflect"

import custom_log "logger"
import spall "spall_wrapper"
import platform "sim_platform"
import peripherals "sim_peripherals"
import mcu "mcu:stm32h723xx"

SIMULATOR_VERSION_MAJOR :: "0"
SIMULATOR_VERSION_MINOR :: "0"
SIMULATOR_VERSION_PATCH :: "0"
SIMULATOR_VERSION :: SIMULATOR_VERSION_MAJOR + "." + SIMULATOR_VERSION_MINOR + "." + SIMULATOR_VERSION_PATCH

EXPECTED_PAGE_SIZE :: 4096

Simulator_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  simArray: [^]peripherals.Sim_Data,
  shouldQuit: b32,
}

sim_thread_proc :: proc(rawdata: rawptr)
{
  data := cast(^Simulator_Thread_Data)rawdata
  memory := data.memory

  if !spall.init_thread() {
    log.errorf("Could not init profiling in %s", #procedure)
    os.exit(1)
  }
  defer spall.deinit_thread()

  ITERATION_TIME :: 40*time.Microsecond

  for {
    start := time.now()
    spall._buffer_begin("Peripheral page write watch")

    if data.shouldQuit {
      break
    }

    pageCount: uint = memory.pageCount
    ok := platform.get_written_pages(
      memory.base,
      &memory.writeWatchRequestMem[0],
      &pageCount,
      memory.totalMem,
    )

    if !ok {
      continue
    }

    if pageCount > 0 {
      spall.SCOPED_EVENT("Peripheral handle page writes")
      
      for idx: uint = 0; idx < pageCount; idx += 1 {
        pageAddr: rawptr = memory.writeWatchRequestMem[idx]
        pageOffset := uintptr(pageAddr) - uintptr(memory.base)
        // NOTE: This will get optimized to a right shift
        pageIdx := u32(pageOffset) / u32(mem.PAGE_SIZE)

        memory.handlers[pageIdx](memory, data.simArray[pageIdx].this_ctx)
      }
    }

    spall._buffer_end()

    diff := time.diff(start, time.now())
    if diff < ITERATION_TIME {
      time.sleep(ITERATION_TIME - diff)
    }
  }
}

gather_memory_info :: proc(memory: ^peripherals.Memory)
{
  totalPageCount: u32 = 0

  types := reflect.struct_field_types(mcu.Raw_Memory)
  for type_info in types {
    ptr := type_info.variant.(reflect.Type_Info_Pointer)
    ptr_type := ptr.elem

    pageCount := (u32(ptr_type.size - 1) / u32(mem.PAGE_SIZE)) + 1
    totalPageCount += pageCount
  }

  memory.pageCount = uint(totalPageCount)
  memory.totalMem = uint(int(totalPageCount) * mem.PAGE_SIZE)  
}

init_memory :: #force_inline proc(memory: ^peripherals.Memory)
{
  gather_memory_info(memory)
  memory.base = platform.init_memory(memory.totalMem)
}

destroy_memory :: proc(memory: ^peripherals.Memory)
{
  platform.destroy_memory(memory.base)
  // virtual.arena_destroy() also deallocates everything that was allocated with it
  arena := memory.arena
  virtual.arena_destroy(&arena)
}

/*
Params:
 - `dllpath_no_ext`: dynamic library file path without extension (the extension will be appended)
*/
load_board_api :: proc(dllpath_no_ext: string) -> peripherals.Board_API
{
  path := fmt.tprintf("%s." + dynlib.LIBRARY_FILE_EXTENSION, dllpath_no_ext)

  board_api: peripherals.Board_API
  count, ok := dynlib.initialize_symbols(&board_api, path, "Board_", "library")
  log.infof("%v symbols loaded from %s", count, path)
  if !ok {
    log.errorf("Could not load symbols from %s: %v",
      path, dynlib.last_error())
    os.exit(1)
  }

  return board_api
}

create_board :: proc(dllpath_no_ext: string) -> ^peripherals.Memory
{
  // setup allocator for peripheral internal memory.
  // 1 GB reserved but not committed size (virtual memory)
  // 1 MB committed size ('physical' memory)
  arena: virtual.Arena
  err := virtual.arena_init_static(&arena)
  if err != nil {
    log.error("Could not allocate virtual arena for board memory")
    os.exit(1)
  }

  memory, _ := virtual.new(&arena, peripherals.Memory)
  memory.arena = arena
  memory.arena_allocator = virtual.arena_allocator(&memory.arena)
  memory.arena_base = memory.arena.curr_block.base

  init_memory(memory)
  memory.board_api = load_board_api("board")
  
  simArrayConst := peripherals.SimArray
  memory.simArray = make([]peripherals.Sim_Data, len(simArrayConst))

  // setup peripherals
  types := reflect.struct_field_types(mcu.Raw_Memory)
  mem_current := memory.base
  for type_info, idx in types {
    ptr := type_info.variant.(reflect.Type_Info_Pointer)
    ptr_type := ptr.elem

    pageCount := (u32(ptr_type.size - 1) / u32(mem.PAGE_SIZE)) + 1

    memory.base_addresses[idx] = mem_current
    mem_current = rawptr(uintptr(mem_current) + uintptr(pageCount * u32(mem.PAGE_SIZE)))

    memory.simArray[idx] = simArrayConst[idx]
    memory.simArray[idx].this_ctx = memory.simArray[idx].setup(memory)

    for pageIdx: u32 = 0; pageIdx < pageCount; pageIdx += 1 {
      append(&memory.handlers, memory.simArray[idx].handler)
      append(&memory.peripheral_contexts, memory.simArray[idx].this_ctx)
    }
  }

  return memory
}

destroy_board :: proc(memory: ^peripherals.Memory)
{
  dynlib.unload_library(memory.board_api.library)

  /* NOTE: This has to be last because `memory` is part of the arena */
  destroy_memory(memory)
}

main :: proc()
{
  if !spall.init("trace.spall") {
    fmt.eprint("Could not init profiling")
    os.exit(1)
  }
  defer spall.deinit()

  spall._buffer_begin("Startup")

  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)

  memory := create_board("board")
  defer destroy_board(memory)

  log.infof("Total page count: %v", memory.pageCount)
  log.infof("Total page size: %v", memory.totalMem)
  log.infof("Peripheral count: %v", mcu.PERIPHERAL_COUNT)
  log.infof("Total used memory by board: %v Bytes",
    memory.arena.total_used + memory.totalMem)

  sim_thread_data := Simulator_Thread_Data {
    memory = memory,
    simArray = &memory.simArray[0],
  }

  spall._buffer_end() // "Startup"

  sim_thread := thread.create_and_start_with_data(
    &sim_thread_data,
    sim_thread_proc,
    context,
  )

  /* --------------------------------------------- */

  step_time := 10 * time.Microsecond
  memory.board_api.init(memory)

  MAX_ITERATIONS :: 1_000_000

  /* step easy version: 
   * the stepping is done by calling update() on the simulated board
   */

  it := 0
  for {
    spall._buffer_begin("Board iteration")
    spall._buffer_begin("Peripheral update")

    for periph in memory.simArray {
      if periph.step != peripherals.Stub_step {
        //fmt.printfln("Peripheral %v step", periph)
        periph.step(memory, periph.this_ctx, step_time)
      }
    }

    spall._buffer_end() // "Peripheral update"

    memory.board_api.update()

    spall._buffer_end() // "Board iteration"

    time.sleep(10*time.Microsecond)

    when MAX_ITERATIONS != 0 {
      it += 1
      if it >= MAX_ITERATIONS {
        break
      }
    }
  }

  // wait until sim_thread quits 'voluntarily'
  sim_thread_data.shouldQuit = true
  thread.join(sim_thread)
}
