#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
#+build windows
package simulator_platform

import "core:os"
import "core:log"

import win "core:sys/windows"

init_memory :: proc(totalMem: uint, pageSize: u32) -> rawptr
{
  MEM_WRITE_WATCH :: 0x00200000

  base := win.VirtualAlloc(nil,
    totalMem,
    win.MEM_COMMIT | win.MEM_RESERVE | MEM_WRITE_WATCH,
    win.PAGE_READWRITE,
  )
  if base == nil {
    log.errorf("[Win32] Could not allocate memory for peripherals: %v", win.GetLastError())
    os.exit(1)
  }

  return base
}

destroy_memory :: proc(base: rawptr)
{
  win.VirtualFree(base, 0, win.MEM_RELEASE)
}

get_page_size :: proc() -> u32
{
  sysInfo: win.SYSTEM_INFO = ---
  win.GetSystemInfo(&sysInfo)

  return sysInfo.dwPageSize
}

get_written_pages :: proc(base: rawptr, reqMem: ^rawptr, pageCount: ^uint, totalMem: uint) -> (pageSize: u32, ok: bool)
{
  WRITE_WATCH_FLAG_RESET :: 0x01

  status := win.GetWriteWatch(
    WRITE_WATCH_FLAG_RESET,
    base,
    totalMem,
    reqMem,
    pageCount,
    &pageSize,
  )

  if !win.SUCCEEDED(status) {
    log.errorf("Could not GetWriteWatch: %v", win.GetLastError())
    return
  }

  ok = true
  return
}
