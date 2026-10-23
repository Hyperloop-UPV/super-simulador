#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:flags"

SIM_CMDLINE_PARSING_STYLE :: flags.Parsing_Style.Unix

Sim_Options :: struct {
  board: [dynamic]string `args:"required" usage:"Board dynamic libraries"`,
  usim: [dynamic]^os.File `args:"file=r" usage:"Micro simulators attached"`,
  max_iterations: int `usage:"Max iterations for the simulator"`,
  max_time: string `usage:"Max time for the simulator, starts counting after initialization"`,
}

cmdline_parse :: proc() -> Sim_Options
{
  opt: Sim_Options
  flags.parse_or_exit(&opt, os.args, SIM_CMDLINE_PARSING_STYLE)

  if len(opt.board) > 1 {
    fmt.eprintln("[ERROR] Only one board supported at once for now")
    os.exit(1)
  }
  if len(opt.usim) > 0 {
    fmt.eprintln("[ERROR] Micro simulators not supported yet")
    os.exit(1)
  }

  return opt
}

cmdline_destroy :: proc(opt: ^Sim_Options)
{
  if opt.board != nil {
    delete(opt.board)
  }
  if opt.usim != nil {
    delete(opt.usim)
  }
}
