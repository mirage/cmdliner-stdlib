# cmdliner-stdlib

The `cmdliner-stdlib` package is a collection of cmdliner terms that
help control OCaml runtime parameters, usually configured through the
`OCAMLRUNPARAM` environment variable. The package provides command-line
options for controlling features like backtrace, hash table
randomization, and garbage collector tuning.

## Installation

You can install the package using `opam`:

```bash
opam install cmdliner-stdlib
```

## Usage

You can use these command-line arguments to:
- enable/disable backtraces;
- enable/disable table randomization, for better security and prevent
  collision attacks; and
- control the OCaml garbage collector as described in detail in the
  [GC
  control](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html#TYPEcontrol)
  documentation.

```ocaml
open Cmdliner

let cmd = Cmd.v (Cmd.info "hello") (Cmdliner_stdlib.setup ())
let () = exit (Cmd.eval cmd)
```

You can then use command-line options to change parameters of the
OCaml runtime. For instance, to enable backtraces and change the GC
allocation policy to "first fit":

```sh
$ dune exec -- ./hello.exe --allocation-policy=first-fit --backtrace=true
```

You can disable some of these arguments. For instance, to disable GC control use:

```ocaml
   Cmdliner_stdlib.setup ~gc_control:None ()
```

Or to change the default allocation policy to be `first-fit`:


```ocaml
  let default = Gc.get () in
  let gc_control = Some { default with allocation_policy = 1 } in
  Cmdliner_stdlib.setup ~gc_control ()
```

## Contributions

We welcome contributions, bug reports, and feature requests. Please
visit our [GitHub
repository](https://github.com/mirage/cmdliner-stdlib) for more
information.
