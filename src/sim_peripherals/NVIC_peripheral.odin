#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package peripherals

import "core:time"

NVIC_handler :: proc(rawctx, this_rawctx: rawptr)
{
  
}

NVIC_setup :: proc(rawctx: rawptr) -> rawptr
{
  //mem := cast(^Memory)rawctx
  //nvic := cast(^NVIC)mem.NVIC_base

  return nil
}

NVIC_step :: proc(rawctx, this_rawctx: rawptr, step_time: time.Duration)
{

}
