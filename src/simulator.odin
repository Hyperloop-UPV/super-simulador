#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:log"
import custom_log "logger"
import "core:time"
import "core:thread"
import "core:dynlib"
import "core:mem/virtual"
// import "core:reflect"

import platform "sim_platform"
import peripherals "sim_peripherals"

SIMULATOR_VERSION_MAJOR :: "0"
SIMULATOR_VERSION_MINOR :: "0"
SIMULATOR_VERSION_PATCH :: "0"
SIMULATOR_VERSION :: SIMULATOR_VERSION_MAJOR + "." + SIMULATOR_VERSION_MINOR + "." + SIMULATOR_VERSION_PATCH

EXPECTED_PAGE_SIZE :: 4096

Simulator_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  simArray: [^]peripherals.Sim_Data,
}

sim_thread_proc :: proc(rawdata: rawptr)
{
  data := cast(^Simulator_Thread_Data)rawdata
  memory := data.memory

  for {
    pageCount: uint = memory.platform.pageCount
    pageSize, ok := platform.get_written_pages(
      memory.base,
      &memory.platform.writeWatchRequestMem[0],
      &pageCount,
      memory.platform.totalMem,
    )

    if !ok {
      continue
    }

    for idx: uint = 0; idx < pageCount; idx += 1 {
      pageAddr: rawptr = memory.platform.writeWatchRequestMem[idx]
      pageOffset := uintptr(pageAddr) - uintptr(memory.base)
      // NOTE: This will get optimized to a right shift
      pageIdx := u32(pageOffset) / pageSize

      memory.handlers[pageIdx](memory, data.simArray[pageIdx].this_ctx)
    }
  }
}

gather_memory_info :: proc(memory: ^peripherals.Memory, pageSize: u32)
{
  totalPageCount: u32 = 0
  //memTotalSize: u32 = 0

  for per in peripherals.Types {
    ti := type_info_of(per)
    pageCount := (u32(ti.size - 1) / pageSize) + 1
    totalPageCount += pageCount

    //memTotalSize += u32(ti.size)
    //fmt.printfln("%v size: %v; page count: %v",
    //  ti.variant.(reflect.Type_Info_Named).name,
    //  ti.size, pageCount)
  }

  memory.platform.pageCount = uint(totalPageCount)
  memory.platform.totalMem = uint(totalPageCount * pageSize)  
}

init_memory :: #force_inline proc(memory: ^peripherals.Memory, pageSize: u32)
{
  gather_memory_info(memory, pageSize)
  memory.base = platform.init_memory(
    memory.platform.totalMem,
    pageSize,
  )
}

destroy_memory :: proc(memory: ^peripherals.Memory)
{
  platform.destroy_memory(memory.base)
  // virtual.arena_destroy() also deallocates everything that was allocated with it
  virtual.arena_destroy(&memory.arena)
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

create_board :: proc(dllpath_no_ext: string, pageSize: u32) -> ^peripherals.Memory
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

  init_memory(memory, pageSize)
  memory.board_api = load_board_api("board")
  
  simArrayConst := peripherals.SimArray
  memory.simArray = make([]peripherals.Sim_Data, len(simArrayConst))

  // setup peripherals
  mem_current := memory.base
  for periph, idx in peripherals.Types {
    ti := type_info_of(periph)
    pageCount := (u32(ti.size - 1) / pageSize) + 1

    memory.memories[idx] = mem_current
    mem_current = rawptr(uintptr(mem_current) + uintptr(pageCount * pageSize))

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
  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)
  
  pageSize := platform.get_page_size()
  if pageSize != EXPECTED_PAGE_SIZE {
    log.error("Page size is not 4096 Bytes")
    os.exit(1)
  }

  memory := create_board("board", pageSize)
  defer destroy_board(memory)

  log.infof("Total page count: %v", memory.platform.pageCount)
  log.infof("Total page size: %v", memory.platform.totalMem)
  log.infof("Peripheral count: %v", len(peripherals.Types))
  log.infof("Total used memory by board: %v Bytes", memory.arena.total_used)

  sim_thread_data := Simulator_Thread_Data {
    memory = memory,
    simArray = &memory.simArray[0],
  }

  sim_thread := thread.create_and_start_with_data(
    &sim_thread_data,
    sim_thread_proc,
    context,
  )

  /* --------------------------------------------- */

  step_time := 10 * time.Microsecond
  memory.board_api.init(memory)

  /* step easy version: 
   * the stepping is done by calling update() on the simulated board
   */

  for {
    for periph in memory.simArray {
      if periph.step != peripherals.Stub_step {
        //fmt.printfln("Peripheral %v step", periph)
        periph.step(memory, periph.this_ctx, step_time)
      }
    }

    memory.board_api.update()

    time.sleep(10*time.Microsecond)
  }

  thread.join(sim_thread)
}
