#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
#+build !windows
package peripherals

Memory_PlatformSpecific :: struct {
  pageCount: u32,
  totalMem: u32,
}
