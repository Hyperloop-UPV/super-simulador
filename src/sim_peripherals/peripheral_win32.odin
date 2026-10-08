#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
#+build windows
package peripherals

Memory_PlatformSpecific :: struct {
  writeWatchRequestMem: [len(Types)]rawptr,
  pageCount: uint,
  totalMem: uint,
}
