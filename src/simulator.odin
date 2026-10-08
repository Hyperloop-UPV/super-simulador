#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:time"
import "core:thread"
import "core:reflect"
import win "core:sys/windows"

//import platform "sim_platform"
import peripherals "sim_peripherals"

SIMULATOR_VERSION_MAJOR :: "0"
SIMULATOR_VERSION_MINOR :: "0"
SIMULATOR_VERSION_PATCH :: "0"
SIMULATOR_VERSION :: SIMULATOR_VERSION_MAJOR + "." + SIMULATOR_VERSION_MINOR + "." + SIMULATOR_VERSION_PATCH

PAGE_SIZE :: 4096

Simulator_Thread_Data :: struct {
  mem: ^peripherals.Memory,
  simArray: [^]peripherals.Sim_Data,
}

sim_thread_proc :: proc(rawdata: rawptr)
{
  WRITE_WATCH_FLAG_RESET :: 0x01

  data := cast(^Simulator_Thread_Data)rawdata
  mem := data.mem

  pageCount: uint = mem.platform.pageCount
  pageSize: u32 = ---
  win.GetWriteWatch(
    WRITE_WATCH_FLAG_RESET,
    mem.base,
    mem.platform.totalMem,
    &mem.platform.writeWatchRequestMem[0],
    &pageCount,
    &pageSize,
  )

  for idx: uint = 0; idx < pageCount; idx += 1 {
    pageAddr: rawptr = mem.platform.writeWatchRequestMem[idx]
    pageOffset := uintptr(pageAddr) - uintptr(mem.base)
    // NOTE: This will get optimized to a right shift
    pageIdx := u32(pageOffset) / PAGE_SIZE

    mem.handlers[pageIdx](mem, data.simArray[pageIdx].this_ctx)
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
  mem: peripherals.Memory

  // gather memory info
  for per in peripherals.Types {
    ti := type_info_of(per)
    pageCount := (u32(ti.size - 1) / sysInfo.dwPageSize) + 1
    totalPageCount += pageCount

    memTotalSize += u32(ti.size)
    fmt.printfln("%v size: %v; page count: %v",
      ti.variant.(reflect.Type_Info_Named).name,
      ti.size, pageCount)
  }

  mem.platform.pageCount = uint(totalPageCount)
  mem.platform.totalMem = uint(totalPageCount * sysInfo.dwPageSize)

  MEM_WRITE_WATCH :: 0x00200000

  mem.base = win.VirtualAlloc(nil,
    mem.platform.totalMem,
    win.MEM_COMMIT | win.MEM_RESERVE | MEM_WRITE_WATCH,
    win.PAGE_READWRITE,
  )
  if mem.base == nil {
    fmt.eprintfln("[Win32] Could not allocate memory for peripherals: %v", win.GetLastError())
    os.exit(1)
  }

  fmt.printfln("Total size: %v", memTotalSize)
  fmt.printfln("Total page count: %v", totalPageCount)
  fmt.printfln("Total page size: %v", totalPageCount * sysInfo.dwPageSize)
  fmt.printfln("Peripheral count: %v", len(peripherals.Types))

  simArray := peripherals.SimArray

  // setup peripherals
  for periph, idx in peripherals.Types {
    ti := type_info_of(periph)
    pageCount := (u32(ti.size - 1) / sysInfo.dwPageSize) + 1

    simArray[idx].this_ctx = simArray[idx].setup(&mem)

    for pageIdx: u32 = 0; pageIdx < pageCount; pageIdx += 1 {
      append(&mem.handlers, simArray[idx].handler)
      append(&mem.peripheral_contexts, simArray[idx].this_ctx)
    }
  }

  sim_thread_data := Simulator_Thread_Data {
    mem = &mem,
    simArray = &simArray[0],
  }

  sim_thread := thread.create_and_start_with_data(
    &sim_thread_data,
    sim_thread_proc,
    context,
  )

  step_time := 10 * time.Microsecond

  for {
    for periph in simArray {
      periph.step(&mem, periph.this_ctx, step_time)
    }

    // notify step has been done to someone?
  }

  thread.join(sim_thread)
}
