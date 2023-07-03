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

val backtrace : default:bool -> bool Term.t
(** [--backtrace]: Output a backtrace if an uncaught exception terminated the
    application. [default] is the default value if the parameter is not provided
    on the command-line. *)

val randomize_hashtables : default:bool -> bool Term.t
(** [--randomize-hashtables]: Randomize all hash tables. [default] is the
    default value if the parameter is not provided on the command-line. *)

val gc_control : default:Gc.control -> Gc.control Term.t
(** [gc_control] is a term that evaluates to a value of type [Gc.control].
    [default] is the default value if the parameter is not provided on the
    command-line..

    The OCaml garbage collector can be configured, as described in detail in
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html#TYPEcontrol} GC
      control}. *)

val setup :
  ?backtrace:bool option ->
  ?randomize_hashtables:bool option ->
  ?gc_control:Gc.control option ->
  unit ->
  unit Term.t
(** [setup ?backtrace ?randomize_hashtables ?gc_control ()] is the term that set
    the corresponding OCaml runtime parameters:

    - if [backtrace] is set to [Some d], adding [--backtrace] on the
      command-line will call [Printexc.record_backtrace]. [d] is the default if
      case no parameters are provided. If not set, [backtrace] is [Some false]
      to match the default OCaml runtime behavior.
    - if [randomize_hashtables] is set to [Some d], adding
      [--randomize-hashtables] to the command-line will call
      [Hashtable.randomize ()]. [d] is the default if no paramaters are
      provided. If not set, [randomize_hashtables] is set to [Some false] to
      match the default OCaml runtime behavior.
    - if [gc_control] is set to [Some d], various control parameters are added
      to the command-line options that will cause [Gc.set] with the right
      parameters. [d] is the default if no parameters are provided. If not set,
      [gc_control] is [Some (Gc.get ())]. *)
