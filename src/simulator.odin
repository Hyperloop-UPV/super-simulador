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

Board_API :: struct {
  init: proc "c"(mem: ^peripherals.Memory),
  update: proc "c"(),

  library: dynlib.Library,
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

init_arena :: proc(memory: ^peripherals.Memory)
{
  // setup allocator for peripheral internal memory.
  // 1 GB reserved but not committed size (virtual memory)
  // 1 MB committed size ('physical' memory)
  err := virtual.arena_init_static(&memory.arena)
  if err != nil {
    log.error("Could not allocate virtual arena for peripheral memory")
    os.exit(1)
  }
  memory.arena_allocator = virtual.arena_allocator(&memory.arena)
  memory.arena_base = memory.arena.curr_block.base
}

init_memory :: #force_inline proc(memory: ^peripherals.Memory, pageSize: u32)
{
  gather_memory_info(memory, pageSize)
  memory.base = platform.init_memory(
    memory.platform.totalMem,
    pageSize,
  )
  init_arena(memory)
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
load_board_api :: proc(dllpath_no_ext: string) -> Board_API
{
  path := fmt.tprintf("%s." + dynlib.LIBRARY_FILE_EXTENSION, dllpath_no_ext)

  board_api: Board_API
  count, ok := dynlib.initialize_symbols(&board_api, path, "Board_", "library")
  log.infof("%v symbols loaded from %s", count, path)
  if !ok {
    log.errorf("Could not load symbols from %s: %v",
      path, dynlib.last_error())
    os.exit(1)
  }

  return board_api
}

main :: proc()
{
  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)

  memory: peripherals.Memory

  pageSize := platform.get_page_size()
  if pageSize != EXPECTED_PAGE_SIZE {
    log.error("Page size is not 4096 Bytes")
    os.exit(1)
  }

  init_memory(&memory, pageSize)
  defer destroy_memory(&memory)

  simArray := peripherals.SimArray

  board_api := load_board_api("board")
  defer dynlib.unload_library(board_api.library)
  memory.library = board_api.library

  // setup peripherals
  mem_current := memory.base
  for periph, idx in peripherals.Types {
    ti := type_info_of(periph)
    pageCount := (u32(ti.size - 1) / pageSize) + 1

    memory.memories[idx] = mem_current
    mem_current = rawptr(uintptr(mem_current) + uintptr(pageCount * pageSize))

    simArray[idx].this_ctx = simArray[idx].setup(&memory)

    for pageIdx: u32 = 0; pageIdx < pageCount; pageIdx += 1 {
      append(&memory.handlers, simArray[idx].handler)
      append(&memory.peripheral_contexts, simArray[idx].this_ctx)
    }
  }

  cwd, _ := os.get_working_directory(context.temp_allocator)
  log.infof("running from %s", cwd)
  log.infof("Total page count: %v", memory.platform.pageCount)
  log.infof("Total page size: %v", memory.platform.totalMem)
  log.infof("Peripheral count: %v", len(peripherals.Types))

  sim_thread_data := Simulator_Thread_Data {
    memory = &memory,
    simArray = &simArray[0],
  }

  sim_thread := thread.create_and_start_with_data(
    &sim_thread_data,
    sim_thread_proc,
    context,
  )

  /* --------------------------------------------- */

  step_time := 10 * time.Microsecond
  board_api.init(&memory)

  /* step easy version: 
   * the stepping is done by calling update() on the simulated board
   */

  for {
    for periph in simArray {
      if periph.step != peripherals.Stub_step {
        //fmt.printfln("Peripheral %v step", periph)
        periph.step(&memory, periph.this_ctx, step_time)
      }
    }

    board_api.update()

    time.sleep(10*time.Microsecond)
  }

  thread.join(sim_thread)
}
