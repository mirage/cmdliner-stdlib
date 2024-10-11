(*
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Cmdliner

let ocaml_section = "OCAML RUNTIME OPTIONS"

let backtrace ~default =
  let doc =
    "Trigger the printing of a stack backtrace when an uncaught exception \
     aborts the unikernel."
  in
  let doc = Arg.info ~docs:ocaml_section ~docv:"BOOL" ~doc [ "backtrace" ] in
  Arg.(value & opt bool default doc)

let randomize_hashtables ~default =
  let doc = "Turn on randomization of all hash tables by default." in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"BOOL" ~doc [ "randomize-hashtables" ]
  in
  Arg.(value & opt bool default doc)

let policy_of_int = function
  | 0 -> `Next_fit
  | 1 -> `First_fit
  | 2 -> `Best_fit
  | _ -> assert false

let int_of_policy = function `Next_fit -> 0 | `First_fit -> 1 | `Best_fit -> 2

let allocation_policy d =
  let policy =
    Arg.enum
      [
        ("next-fit", `Next_fit);
        ("first-fit", `First_fit);
        ("best-fit", `Best_fit);
      ]
  in
  let doc =
    "The policy used for allocating in the OCaml heap. Possible values are: \
     $(i,next-fit), $(i,first-fit), $(i,best-fit). Best-fit is only supported \
     since OCaml 4.10."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"ALLOCATION" ~doc [ "allocation-policy" ]
  in
  Arg.(value & opt policy (policy_of_int d.Gc.allocation_policy) doc)

let minor_heap_size d =
  let doc = "The size of the minor heap (in words)." in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"WORDS" ~doc [ "minor-heap-size" ]
  in
  Arg.(value & opt int d.Gc.minor_heap_size doc)

let major_heap_increment d =
  let doc =
    "The size increment for the major heap (in words). If less than or equal \
     1000, it is a percentage of the current heap size. If more than 1000, it \
     is a fixed number of words."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"PERCENT/WORDS" ~doc
      [ "major-heap-increment" ]
  in
  Arg.(value & opt int d.Gc.major_heap_increment doc)

let space_overhead d =
  let doc =
    "The percentage of live data of wasted memory, due to GC does not \
     immediately collect unreachable blocks. The major GC speed is computed \
     from this parameter, it will work more if smaller."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"PERCENT" ~doc [ "space-overhead" ]
  in
  Arg.(value & opt int d.Gc.space_overhead doc)

let max_space_overhead d =
  let doc =
    "Heap compaction is triggered when the estimated amount of wasted memory \
     exceeds this (percentage of live data). If above 1000000, compaction is \
     never triggered."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"PERCENT" ~doc [ "max-space-overhead" ]
  in
  Arg.(value & opt int d.Gc.max_overhead doc)

let gc_verbosity d =
  let doc =
    "GC messages on standard error output. Sum of flags. Check GC module \
     documentation for details."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"VERBOSITY" ~doc [ "gc-verbosity" ]
  in
  Arg.(value & opt int d.Gc.verbose doc)

let gc_window_size d =
  let doc =
    "The size of the window used by the major GC for smoothing out variations \
     in its workload. Between 1 and 50."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"INT" ~doc [ "gc-window-size" ]
  in
  Arg.(value & opt int d.Gc.window_size doc)

let custom_major_ratio d =
  let doc =
    "Target ratio of floating garbage to major heap size for out-of-heap \
     memory held by custom values."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"RATIO" ~doc [ "custom-major-ratio" ]
  in
  Arg.(value & opt int d.Gc.custom_minor_ratio doc)

let custom_minor_ratio d =
  let doc =
    "Bound on floating garbage for out-of-heap memory held by custom values in \
     the minor heap."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"RATIO" ~doc [ "custom-minor-ratio" ]
  in
  Arg.(value & opt int d.Gc.custom_minor_ratio doc)

let custom_minor_max_size d =
  let doc =
    "Maximum amount of out-of-heap memory for each custom value allocated in \
     the minor heap."
  in
  let doc =
    Arg.info ~docs:ocaml_section ~docv:"BYTES" ~doc [ "custom-minor-max-size" ]
  in
  Arg.(value & opt int d.Gc.custom_minor_max_size doc)

let stack_limit d =
  let doc = "The maximum size of the fiber stacks (in words)." in
  let doc = Arg.info ~docs:ocaml_section ~docv:"WORDS" ~doc [ "stack-limit" ] in
  Arg.(value & opt int d.Gc.stack_limit doc)

let gc_control ~default =
  let f minor_heap_size major_heap_increment space_overhead verbose max_overhead
      stack_limit allocation_policy window_size custom_major_ratio
      custom_minor_ratio custom_minor_max_size =
    let allocation_policy = int_of_policy allocation_policy in
    {
      Gc.minor_heap_size;
      major_heap_increment;
      space_overhead;
      verbose;
      max_overhead;
      stack_limit;
      allocation_policy;
      window_size;
      custom_major_ratio;
      custom_minor_ratio;
      custom_minor_max_size;
    }
  in
  Term.(
    const f
    $ minor_heap_size default
    $ major_heap_increment default
    $ space_overhead default
    $ gc_verbosity default
    $ max_space_overhead default
    $ stack_limit default
    $ allocation_policy default
    $ gc_window_size default
    $ custom_major_ratio default
    $ custom_minor_ratio default
    $ custom_minor_max_size default)

let setup ?backtrace:(b = Some false) ?randomize_hashtables:(r = Some false)
    ?gc_control:(c = Some (Gc.get ())) () =
  let f backtrace randomize_hashtables gc_control =
    let () =
      match backtrace with None -> () | Some b -> Printexc.record_backtrace b
    in
    let () =
      match randomize_hashtables with
      | None | Some false -> ()
      | Some true -> Hashtbl.randomize ()
    in
    let () = match gc_control with None -> () | Some c -> Gc.set c in
    ()
  in
  let some c = Term.(const Option.some $ c) in
  let none = Term.const None in
  let fold f d = Option.fold ~none ~some:(fun d -> some (f ~default:d)) d in
  let b = fold backtrace b in
  let r = fold randomize_hashtables r in
  let c = fold gc_control c in
  Term.(const f $ b $ r $ c)
