#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "base:runtime"

import "core:os"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:time"
import "core:thread"
import "core:dynlib"
import "core:reflect"
import "core:sync/chan"
import "core:mem/virtual"

import custom_log "logger"
import spall "spall_wrapper"
import platform "sim_platform"
import peripherals "sim_peripherals"

import mcu "mcu:stm32h723xx"
import "../usim"

SIMULATOR_VERSION_MAJOR :: "0"
SIMULATOR_VERSION_MINOR :: "0"
SIMULATOR_VERSION_PATCH :: "0"
SIMULATOR_VERSION :: SIMULATOR_VERSION_MAJOR + "." + SIMULATOR_VERSION_MINOR + "." + SIMULATOR_VERSION_PATCH

EXPECTED_PAGE_SIZE :: 4096

/* --------------------------------------------- */

Simulator_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  simArray: [^]peripherals.Sim_Data,
  shouldQuit: b32,
}

/* thread data for a single board, global_should_quit is readonly */
Board_Thread_Data :: struct {
  memory: ^peripherals.Memory,
  global_should_quit: ^bool,
  max_iterations: int,
  step_time: time.Duration,
  sim_thread_should_quit: ^b32,
  sim_thread: ^thread.Thread,
}

FW_Thread_Data :: struct {
  sim: Simulator_Thread_Data,
  board: Board_Thread_Data,
}

USim_Thread_Data :: struct {
  attached_memories: []^peripherals.Memory,
  board_names: []cstring,
  usim_dll: string,
  usim_api: usim.API,
  global_should_quit: ^bool,
  channel: chan.Chan(usim.Event, .Recv),
  usim_id: usim.Id,
}

/* --------------------------------------------- */

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

/* --------------------------------------------- */

load_symbol_or_err :: proc(lib: dynlib.Library, dllpath, symbol: string, fn: ^rawptr)
{
  ptr, found := dynlib.symbol_address(lib, symbol)
  if !found {
    log.errorf("Could not load symbol '%s' from %s: %v",
      symbol, dllpath, dynlib.last_error())
    os.exit(1)
  }
  fn^ = ptr
}

/*
Params:
 - `dllpath`: dynamic library file path with extension
*/
load_board_api :: proc(dllpath: string) -> peripherals.Board_API
{
  board_api: peripherals.Board_API
  did_load: bool
  board_api.library, did_load = dynlib.load_library(dllpath)
  if !did_load {
    log.errorf("Could not load library from %s: %v",
      dllpath, dynlib.last_error())
    os.exit(1)
  }

  load_symbol_or_err(board_api.library, dllpath, "Board_init", cast(^rawptr)&board_api.init)
  load_symbol_or_err(board_api.library, dllpath, "Board_update", cast(^rawptr)&board_api.update)

  log.infof("loaded symbols correctly from %s", dllpath)
  return board_api
}

load_usim_api :: proc(dllpath: string) -> usim.API
{
  usim_api: usim.API
  did_load: bool
  usim_api._library, did_load = dynlib.load_library(dllpath)
  if !did_load {
    log.errorf("Could not load library from %s: %v",
      dllpath, dynlib.last_error())
    os.exit(1)
  }

  load_symbol_or_err(usim_api._library, dllpath, "USim_init", cast(^rawptr)&usim_api._init)
  load_symbol_or_err(usim_api._library, dllpath, "USim_update", cast(^rawptr)&usim_api._update)
  load_symbol_or_err(usim_api._library, dllpath, "USim_deinit", cast(^rawptr)&usim_api._deinit)

  log.infof("loaded symbols correctly from %s", dllpath)
  return usim_api
}

/* --------------------------------------------- */

USim_event_subscribe :: proc "c"(rawmem: rawptr, kind: usim.Event_Kind, id: usim.Id) -> bool
{
  memory := cast(^peripherals.Memory)rawmem
  context = memory.odin_ctx

  subscribers := memory.subscribed_events[kind]
  subscribers |= 1 << u64(id)
  memory.subscribed_events[kind] = subscribers

  return true
}

USim_poll_event :: proc "c"(channel: usim.Recv_Channel, event: ^usim.Event) -> bool
{
  status: chan.Timeout_Status
  ch := chan.Chan(usim.Event, .Recv) {
    impl = cast(^chan.Raw_Chan)channel.impl,
  }

  event^, status = chan.recv_with_timeout(ch, time.Duration(0))
  return status == .Ok
}

USim_wait_event :: proc "c"(channel: usim.Recv_Channel, event: ^usim.Event) -> bool
{
  ok: bool
  ch := chan.Chan(usim.Event, .Recv) {
    impl = cast(^chan.Raw_Chan)channel.impl,
  }

  event^, ok = chan.recv(ch)
  return ok
}

USim_add_event_watch :: proc "c"(rawmem: rawptr, kind: usim.Event_Kind, id: usim.Id, callback: usim.Event_Watch_Callback_Proc, ctx: rawptr) -> bool
{
  memory := cast(^peripherals.Memory)rawmem
  context = memory.odin_ctx

  watch, found := memory.event_watch[kind]

  new_watch: []peripherals.USim_Event_Watch_Data
  if found {
    new_watch = make([]peripherals.USim_Event_Watch_Data, len(watch))
    mem.copy(&new_watch[0], &watch[0], len(watch) * size_of(peripherals.USim_Event_Watch_Data))
    delete(watch)
  } else {
    new_watch = make([]peripherals.USim_Event_Watch_Data, 1)
  }

  new_watch[len(new_watch)-1].callback = callback
  new_watch[len(new_watch)-1].ctx = ctx

  memory.event_watch[kind] = new_watch

  return true
}

/* --------------------------------------------- */

create_board :: proc(dllpath: string, channels: []chan.Chan(usim.Event, .Both)) -> ^peripherals.Memory
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

  memory.odin_ctx = context

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

    if memory.simArray[idx].setup != peripherals.Stub_setup {
      memory.simArray[idx].this_ctx = memory.simArray[idx].setup(memory)
    }

    for pageIdx: u32 = 0; pageIdx < pageCount; pageIdx += 1 {
      append(&memory.handlers, memory.simArray[idx].handler)
      append(&memory.peripheral_contexts, memory.simArray[idx].this_ctx)
    }
  }

  // setup event queue channels
  memory.channels = make([]chan.Chan(usim.Event, .Send), len(channels))
  for c, idx in channels {
    memory.channels[idx] = chan.as_send(c)
  }
  reserve(&memory.subscribed_events, usim.Event_Kind.Count)
  reserve(&memory.event_watch, usim.Event_Kind.Count)

  return memory
}

destroy_board :: proc(memory: ^peripherals.Memory)
{
  dynlib.unload_library(memory.board_api.library)

  delete(memory.channels)
  // delete dynamically created USim_Event_Watch_Data slices
  for _, value in memory.event_watch {
    delete(value)
  }
  delete(memory.event_watch)
  delete(memory.subscribed_events)

  /* NOTE: This has to be last because `memory` is part of the arena */
  destroy_memory(memory)
}

/* --------------------------------------------- */

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
      spall._buffer_end()
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
      spall._buffer_end()
      continue
    }

    if pageCount > 0 {
      spall._buffer_begin("Peripheral handle page writes")

      for idx: uint = 0; idx < pageCount; idx += 1 {
        pageAddr: rawptr = memory.writeWatchRequestMem[idx]
        pageOffset := uintptr(pageAddr) - uintptr(memory.base)
        // NOTE: This will get optimized to a right shift
        pageIdx := u32(pageOffset) / u32(mem.PAGE_SIZE)

        memory.handlers[pageIdx](memory, data.simArray[pageIdx].this_ctx)
      }

      spall._buffer_end() // "Peripheral handle page writes"
    }

    spall._buffer_end() // "Peripheral page write watch"

    diff := time.diff(start, time.now())
    if diff < ITERATION_TIME {
      time.sleep(ITERATION_TIME - diff)
    }
  }
}

/* thread procedure for a single board */
board_thread_proc :: proc(rawdata: rawptr)
{
  data := cast(^Board_Thread_Data)rawdata
  memory := data.memory

  if !spall.init_thread() {
    log.errorf("Could not init profiling in %s", #procedure)
    os.exit(1)
  }
  defer spall.deinit_thread()

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
    if (data.max_iterations != 0) && (it > data.max_iterations) {
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

/* Thread procedure for a single usim */
usim_thread_proc :: proc(rawdata: rawptr)
{
  data := cast(^USim_Thread_Data)rawdata

  data.usim_api = load_usim_api(data.usim_dll)
  data.usim_api.event_subscribe = USim_event_subscribe
  data.usim_api.poll_event = USim_poll_event
  data.usim_api.wait_event = USim_wait_event
  data.usim_api.add_event_watch = USim_add_event_watch
  data.usim_api.channel.impl = data.channel.impl

  ctx: rawptr
  init_ok: bool = true
  for i := 0; i < len(data.attached_memories); i += 1 {
    memory := data.attached_memories[i]
    name := data.board_names[i]
    init_ok = init_ok &&
      data.usim_api._init(memory, &data.usim_api, name, data.usim_id, &ctx)
  }

  if !init_ok {
    data.usim_api._deinit(ctx)
    dynlib.unload_library(data.usim_api._library)
    return
  }

  quit: bool
  for !quit && !(data.global_should_quit^) {
    quit = data.usim_api._update(ctx)
    // sleep is expected to be done in update() callback
  }
  data.usim_api._deinit(ctx)

  dynlib.unload_library(data.usim_api._library)
}

/* --------------------------------------------- */

/* Launch simulation on the already initialized board `memory.board_api`
 * global_should_quit is readonly
 */
launch_board :: proc(thread_data_backing: ^FW_Thread_Data, memory: ^peripherals.Memory, global_should_quit: ^bool, max_iterations: int, step_time: time.Duration) -> (board_thread: ^thread.Thread)
{
  td := thread_data_backing
  td.sim = Simulator_Thread_Data {
    memory = memory,
    simArray = &memory.simArray[0],
  }

  td.board = Board_Thread_Data {
    memory = memory,
    global_should_quit = global_should_quit,
    max_iterations = max_iterations,
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

launch_usim :: proc(backing: ^USim_Thread_Data) -> ^thread.Thread
{
  usim_thread := thread.create_and_start_with_data(
    backing,
    usim_thread_proc,
    context,
  )

  return usim_thread
}

/* --------------------------------------------- */

main :: proc()
{
  opt := cmdline_parse()
  defer cmdline_destroy(&opt)

  if !spall.init("trace.spall") {
    fmt.eprint("Could not init profiling")
    os.exit(1)
  }
  defer {
    spall.deinit_thread()
    spall.deinit()
  }

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
  channels := make([]chan.Chan(usim.Event, .Both), len(opt.usim))
  defer {
    for c in channels {
      chan.destroy(c)
    }
    delete(channels)
  }
  usims := make([]USim_Thread_Data, len(opt.usim))
  defer delete(usims)
  usim_threads := make([]^thread.Thread, len(opt.usim))
  defer delete(usim_threads)

  /* --------------------------------------------- */

  for idx := 0; idx < len(channels); idx += 1 {
    chan_err: runtime.Allocator_Error
    channels[idx], chan_err = chan.create_buffered(
      chan.Chan(usim.Event, .Both),
      usim.QUEUE_MAX_SIZE,
      context.allocator,
    )
    if chan_err != nil {
      log.errorf("Could not create event queue channel: %v", chan_err)
      os.exit(1)
    }
  }

  for board, board_idx in opt.board {
    memories[board_idx] = create_board(board, channels)
  }

  global_should_quit: bool
  for u, usim_idx in opt.usim {
    td := &usims[usim_idx]
    td^ = {
      board_names = u.attached_boards,
      usim_dll = u.dll,
      global_should_quit = &global_should_quit,
      usim_id = usim.Id(usim_idx),
    }
    td.channel = chan.as_recv(channels[usim_idx])

    td.attached_memories = make([]^peripherals.Memory, len(u.attached_boards))
    for attached, mem_idx in u.attached_boards {
      board_name := string(attached)
      found := false
      for board, board_idx in opt.board {
        if os.short_stem(board) == board_name {
          td.attached_memories[mem_idx] = memories[board_idx]
          found = true
        }
      }

      if !found {
        log.errorf("board %s requested by usim %s was not found in board array", attached, u.dll)
        os.exit(1)
      }
    }

    usim_threads[usim_idx] = launch_usim(td)
  }

  defer {
    for u in usims {
      delete(u.attached_memories)
    }
  }

  log.infof("Total page count: %v", memories[0].pageCount * len(opt.board))
  log.infof("Total page size: %v", memories[0].totalMem * len(opt.board))
  log.infof("Peripheral count for each board: %v", mcu.PERIPHERAL_COUNT)
  log.infof("Total used memory: %v Bytes",
    (memories[0].arena.total_used + memories[0].totalMem) * len(opt.board),
  )

  spall._buffer_end() // "Startup"

  /* --------------------------------------------- */

  step_time := 10 * time.Microsecond
  thread_data := make([]FW_Thread_Data, len(opt.board))
  defer delete(thread_data)
  board_threads := make([]^thread.Thread, len(opt.board))
  defer delete(board_threads)

  for mem, idx in memories {
    board_threads[idx] = launch_board(&thread_data[idx], mem, &global_should_quit, opt.max_iterations, step_time)
  }

  /* --------------------------------------------- */

  if opt.max_time > 0 {
    time.sleep(opt.max_time)
    global_should_quit = true
    // wait until board_threads quit 'voluntarily'
    thread.join_multiple(..board_threads[:])
  } else {
    // sleep until all board_threads finish
    thread.join_multiple(..board_threads[:])
  }

  // wait until all usim threads quit 'voluntarily'
  global_should_quit = true
  thread.join_multiple(..usim_threads[:])
}
