(*pp camlp4orf *)
(* $Id$ *)

open Printf

open Camlp4.PreCast
open Syntax

open Syntax_common
open Select_lib
open Match

let extend_common () =
EXTEND Gram
  expr: [
    [ "RE_STR"; re = regexp -> 
	Regexp_ast.warnings re;
	let (re_args, re_source, named_groups, postbindings) =
	  Str_lib.lib.process_regexp _loc ~sharing:true re "" in
	
	let re_fragments = Match.get_re_fragments _loc re_source in
	<:expr< ( $re_fragments$, 
		  $pp_named_groups _loc named_groups$ ) >> ]
  ];

  Syntax_common.regexp: LEVEL "simple" [
    [ "_" -> Regexp_ast.Characters (_loc, Charset.full) ]
  ];

END;;

let extend_regular () = extend_common ()
(*
let extend_revised () = extend_common ()
*)

let _ =
  select_lib Str_lib.lib;

  (* Keeping it for backwards compatibility *)
  Camlp4.Options.add "-thread" 
    (Arg.Unit (
       fun () -> 
	 select_lib Str_lib.lib_mt;
	 eprintf "Warning: -thread is deprecated.\n/%!"
     ))
    " Deprecated option that protects access to shared data with a mutex. \
      Currently only patterns containing @ are concerned.";
  
  (* How to test if the current syntax is the regular or revised one? *)
  extend_regular ()
