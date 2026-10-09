#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:mem/virtual"
import "core:time"
import "core:thread"
import "core:dynlib"
// import "core:reflect"
import win "core:sys/windows"

//import platform "sim_platform"
import peripherals "sim_peripherals"

SIMULATOR_VERSION_MAJOR :: "0"
SIMULATOR_VERSION_MINOR :: "0"
SIMULATOR_VERSION_PATCH :: "0"
SIMULATOR_VERSION :: SIMULATOR_VERSION_MAJOR + "." + SIMULATOR_VERSION_MINOR + "." + SIMULATOR_VERSION_PATCH

PAGE_SIZE :: 4096

Simulator_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  simArray: [^]peripherals.Sim_Data,
}

sim_thread_proc :: proc(rawdata: rawptr)
{
  WRITE_WATCH_FLAG_RESET :: 0x01

  data := cast(^Simulator_Thread_Data)rawdata
  memory := data.memory

  pageCount: uint = memory.platform.pageCount
  pageSize: u32 = ---
  win.GetWriteWatch(
    WRITE_WATCH_FLAG_RESET,
    memory.base,
    memory.platform.totalMem,
    &memory.platform.writeWatchRequestMem[0],
    &pageCount,
    &pageSize,
  )

  for idx: uint = 0; idx < pageCount; idx += 1 {
    pageAddr: rawptr = memory.platform.writeWatchRequestMem[idx]
    pageOffset := uintptr(pageAddr) - uintptr(memory.base)
    // NOTE: This will get optimized to a right shift
    pageIdx := u32(pageOffset) / PAGE_SIZE

    memory.handlers[pageIdx](memory, data.simArray[pageIdx].this_ctx)
  }
}

main :: proc()
{
  sysInfo: win.SYSTEM_INFO = ---
  win.GetSystemInfo(&sysInfo)
  if sysInfo.dwPageSize != PAGE_SIZE {
    fmt.eprintfln("[ERROR] Page size is not 4096 Bytes")
    os.exit(1)
  }

  memTotalSize: u32 = 0
  totalPageCount: u32 = 0
  memory: peripherals.Memory

  // gather memory info
  for per in peripherals.Types {
    ti := type_info_of(per)
    pageCount := (u32(ti.size - 1) / sysInfo.dwPageSize) + 1
    totalPageCount += pageCount

    memTotalSize += u32(ti.size)
    //fmt.printfln("%v size: %v; page count: %v",
    //  ti.variant.(reflect.Type_Info_Named).name,
    //  ti.size, pageCount)
  }

  memory.platform.pageCount = uint(totalPageCount)
  memory.platform.totalMem = uint(totalPageCount * sysInfo.dwPageSize)

  MEM_WRITE_WATCH :: 0x00200000

  memory.base = win.VirtualAlloc(nil,
    memory.platform.totalMem,
    win.MEM_COMMIT | win.MEM_RESERVE | MEM_WRITE_WATCH,
    win.PAGE_READWRITE,
  )
  if memory.base == nil {
    fmt.eprintfln("[Win32] Could not allocate memory for peripherals: %v", win.GetLastError())
    os.exit(1)
  }

  fmt.printfln("Total size: %v", memTotalSize)
  fmt.printfln("Total page count: %v", totalPageCount)
  fmt.printfln("Total page size: %v", totalPageCount * sysInfo.dwPageSize)
  fmt.printfln("Peripheral count: %v", len(peripherals.Types))

  // setup allocator for peripheral internal memory.
  // 1 GB reserved but not committed size (virtual memory)
  // 1 MB committed size ('physical' memory)
  err := virtual.arena_init_static(&memory.arena)
  if err != nil {
    fmt.eprintln("Could not allocate virtual arena for peripheral memory")
    os.exit(1)
  }
  // virtual.arena_destroy() also deallocates everything that was allocated with it
  defer virtual.arena_destroy(&memory.arena)
  memory.arena_allocator = virtual.arena_allocator(&memory.arena)
  memory.arena_base = memory.arena.curr_block.base

  simArray := peripherals.SimArray

  BOARD_DYNLIB :: "board" + dynlib.LIBRARY_FILE_EXTENSION
  Board_API :: struct {
    init: proc "c"(mem: ^peripherals.Memory),
    update: proc "c"(),

    library: dynlib.Library,
  }

  board_api: Board_API = ---
  count, ok := dynlib.initialize_symbols(&board_api, BOARD_DYNLIB, "Board", "library")
  defer dynlib.unload_library(board_api.library)
  fmt.printfln("%v symbols loaded from " + BOARD_DYNLIB + ".", count)
  memory.library = board_api.library
  if !ok {
    fmt.eprintfln("Could not load symbols from " + BOARD_DYNLIB + ": %v", 
      dynlib.last_error())
    os.exit(1)
  }

  // setup peripherals
  mem_current := memory.base
  for periph, idx in peripherals.Types {
    ti := type_info_of(periph)
    pageCount := (u32(ti.size - 1) / sysInfo.dwPageSize) + 1

    memory.memories[idx] = mem_current
    mem_current = rawptr(uintptr(mem_current) + uintptr(pageCount * PAGE_SIZE))

    simArray[idx].this_ctx = simArray[idx].setup(&memory)

    for pageIdx: u32 = 0; pageIdx < pageCount; pageIdx += 1 {
      append(&memory.handlers, simArray[idx].handler)
      append(&memory.peripheral_contexts, simArray[idx].this_ctx)
    }
  }

  sim_thread_data := Simulator_Thread_Data {
    memory = &memory,
    simArray = &simArray[0],
  }

  sim_thread := thread.create_and_start_with_data(
    &sim_thread_data,
    sim_thread_proc,
    context,
  )

  step_time := 10 * time.Microsecond

  board_api.init(&memory)

  /* step easy version: 
   * the stepping is done by calling update() on the simulated board
   */

  for {
    for periph in simArray {
      periph.step(&memory, periph.this_ctx, step_time)
    }

    board_api.update()
  }

  thread.join(sim_thread)
}
