#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package simulator

import "core:os"
import "core:fmt"
import "core:time"
import "core:flags"
import "core:strconv"

SIM_CMDLINE_PARSING_STYLE :: flags.Parsing_Style.Unix

@(private="file")
Sim_Options_SemiParsed :: struct {
  board: [dynamic]string `args:"required" usage:"Board dynamic libraries"`,
  usim: [dynamic]string `usage:"Micro simulators attached"`,
  max_iterations: int `usage:"Max iterations for the simulator"`,
  max_time: string `usage:"Max time for the simulator, starts counting after most of the initialization"`,
}

Sim_Options :: struct {
  board: [dynamic]string,
  usim: [dynamic]string,
  max_iterations: int,
  max_time: time.Duration,
}

@(private="file")
parse_time :: proc(t: string) -> time.Duration
{
  p: int
  n, _ := strconv.parse_i64(t, n = &p)
  if n <= 0 {
    fmt.eprintfln("Could not parse time from max-time argument '%s': not a number or not greater than 0", t)
    os.exit(1)
  }

  tick := time.Duration(n)
  modified := t[p:]
  if len(modified) == 0 {
    fmt.eprintfln("Could not parse time from max-time argument '%s': no modifier, expected one of ['s','ms','us','ns']")
    os.exit(1)
  }

  switch modified {
    case "s":  tick *= 1000_000_000
    case "ms": tick *= 1000_000
    case "us": tick *= 1000
    case "ns": tick *= 1
  }

  return tick
}

cmdline_parse :: proc() -> Sim_Options
{
  opt: Sim_Options_SemiParsed
  flags.parse_or_exit(&opt, os.args, SIM_CMDLINE_PARSING_STYLE)

  if len(opt.usim) > 0 {
    fmt.eprintln("[ERROR] Micro simulators not supported yet")
    os.exit(1)
  }

  opt_result: Sim_Options
  opt_result.board = opt.board
  opt_result.usim = opt.usim
  opt_result.max_iterations = opt.max_iterations
  if opt.max_time != "" {
    opt_result.max_time = parse_time(opt.max_time)
  }
  return opt_result
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
