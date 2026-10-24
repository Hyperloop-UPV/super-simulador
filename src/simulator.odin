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

/* thread data for a single board, global_should_quit is readonly */
Board_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  global_should_quit: ^bool,
  opt: Sim_Options,
  step_time: time.Duration,
  sim_thread_should_quit: ^b32,
  sim_thread: ^thread.Thread,
}

Thread_Data :: struct {
  sim: Simulator_Thread_Data,
  board: Board_Thread_Data,
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
  memory.writeWatchRequestMem = make([]rawptr,
    memory.pageCount * peripherals.PLATFORM_REQ_MULTIPLIER,
    memory.arena_allocator,
  )
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
load_board_api :: proc(dllpath: string) -> peripherals.Board_API
{
  //path := fmt.tprintf("%s." + dynlib.LIBRARY_FILE_EXTENSION, dllpath_no_ext)

  board_api: peripherals.Board_API
  count, ok := dynlib.initialize_symbols(&board_api, dllpath, "Board_", "library")
  log.infof("%v symbols loaded from %s", count, dllpath)
  if !ok {
    log.errorf("Could not load symbols from %s: %v",
      dllpath, dynlib.last_error())
    os.exit(1)
  }

  return board_api
}

create_board :: proc(dllpath: string) -> ^peripherals.Memory
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
  memory.board_api = load_board_api(dllpath)
  
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

/* thread procedure for a single board */
board_thread_proc :: proc(rawdata: rawptr)
{
  data := cast(^Board_Thread_Data)rawdata
  memory := data.memory
  opt := data.opt

  memory.board_api.init(memory)

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
        periph.step(memory, periph.this_ctx, data.step_time)
      }
    }

    spall._buffer_end() // "Peripheral update"

    memory.board_api.update()

    spall._buffer_end() // "Board iteration"

    it += 1
    if (opt.max_iterations != 0) && (it > opt.max_iterations) {
      break
    }
    if data.global_should_quit^ {
      // core simulator wants to quit for whatever reason
      break
    }

    time.sleep(10*time.Microsecond)
  }

  // wait until sim_thread quits 'voluntarily'
  data.sim_thread_should_quit^ = true
  thread.join(data.sim_thread)
}

/* Launch simulation on the already initialized board `memory.board_api`
 * global_should_quit is readonly
 */
launch_board :: proc(thread_data_backing: ^Thread_Data, memory: ^peripherals.Memory, global_should_quit: ^bool, opt: Sim_Options, step_time: time.Duration) -> (board_thread: ^thread.Thread)
{
  td := thread_data_backing
  td.sim = Simulator_Thread_Data {
    memory = memory,
    simArray = &memory.simArray[0],
  }

  td.board = Board_Thread_Data {
    memory = memory,
    global_should_quit = global_should_quit,
    opt = opt,
    step_time = step_time,
  }

  td.board.sim_thread_should_quit = &td.sim.shouldQuit
  td.board.sim_thread = thread.create_and_start_with_data(
    &td.sim,
    sim_thread_proc,
    context,
  )

  board_thread = thread.create_and_start_with_data(
    &td.board,
    board_thread_proc,
    context,
  )

  return
}

main :: proc()
{
  opt := cmdline_parse()
  defer cmdline_destroy(&opt)

  if !spall.init("trace.spall") {
    fmt.eprint("Could not init profiling")
    os.exit(1)
  }
  defer spall.deinit()

  spall._buffer_begin("Startup")

  context.logger = custom_log.create_logger(opt = {.Level, .Time, .Terminal_Color})
  defer custom_log.destroy_logger(context.logger)

  /* --------------------------------------------- */

  memories := make([]^peripherals.Memory, len(opt.board))
  defer {
    for m in memories {
      destroy_board(m)
    }
    delete(memories)
  }
  for board, board_idx in opt.board {
    memories[board_idx] = create_board(board)
  }

  log.infof("Total page count: %v", memories[0].pageCount * len(opt.board))
  log.infof("Total page size: %v", memories[0].totalMem * len(opt.board))
  log.infof("Peripheral count for each board: %v", mcu.PERIPHERAL_COUNT)
  log.infof("Total used memory: %v Bytes",
    (memories[0].arena.total_used + memories[0].totalMem) * len(opt.board),
  )

  spall._buffer_end() // "Startup"

  /* --------------------------------------------- */

  global_should_quit: bool
  step_time := 10 * time.Microsecond
  thread_data := make([]Thread_Data, len(opt.board))
  defer delete(thread_data)
  board_threads := make([]^thread.Thread, len(opt.board))
  defer delete(board_threads)

  for mem, idx in memories {
    board_threads[idx] = launch_board(&thread_data[idx], mem, &global_should_quit, opt, step_time)
  }

  /* --------------------------------------------- */

  if opt.max_time > 0 {
    time.sleep(opt.max_time)
    global_should_quit = true
    // wait until board_threads quit 'voluntarily'
    for th in board_threads {
      thread.join(th)
    }
  } else {
    // sleep until all board_threads finish
    for th in board_threads {
      thread.join(th)
    }
  }
}
