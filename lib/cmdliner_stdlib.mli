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

(** {2 OCaml runtime keys}

    The OCaml runtime is usually configurable via the [OCAMLRUNPARAM]
    environment variable. We provide boot parameters covering these options. *)

val backtrace : bool Term.t
(** [--backtrace]: Output a backtrace if an uncaught exception terminated the
    application. *)

val randomize_hashtables : bool Term.t
(** [--randomize-hashtables]: Randomize all hash tables. *)

val gc_control : unit -> Gc.control Term.t
(** [gc_control ()] is a term that evaluates to a value of type [Gc.control].
    The default values are from [Gc.get ()] (hence the [()] parameter).

    The OCaml garbage collector can be configured, as described in detail in
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html#TYPEcontrol} GC
      control}. *)

val setup :
  ?backtrace:bool ->
  ?randomize_hashtables:bool ->
  ?gc_control:bool ->
  unit ->
  unit Term.t
(** [setup ?backtrace ?randomize_hashtables ?gc_control ()] is the term that set
    the corresponding OCaml runtime parameters:

    - if [backtrace] is set, adding [--backtrace] on the command-line will call
      [Printexc.record_backtrace true].
    - if [randomize_hashtables] is set, adding [--randomize-hashtables] to the
      command-line will call [Hashtable.randomize ()].
    - if [gc_control] is set, various control parameters are added to the
      command-line options will cause `Gc.set` with the right parameters. *)
