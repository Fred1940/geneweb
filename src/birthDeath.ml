(* camlp4r ./def.syn.cmo ./pa_html.cmo *)
(* $Id: birthDeath.ml,v 3.4 2000-02-25 15:26:02 ddr Exp $ *)
(* Copyright (c) 2000 INRIA *)

open Def;
open Gutil;
open Util;
open Config;

value before_date (_, d, _) (_, d1, _) =
  if d1.year < d.year then True
  else if d1.year > d.year then False
  else if d1.month < d.month then True
  else if d1.month > d.month then False
  else if d1.day < d.day then True
  else if d1.day > d.day then False
  else if d1.prec < d.prec then True
  else if d1.prec > d.prec then False
  else True
;

module Q =
  Pqueue.Make
    (struct
       type t = (Def.person * Def.dmy * Def.calendar);
       value leq x y = before_date y x;
     end)
;

value select conf base get_date =
  let n =
    match p_getint conf.env "k" with
    [ Some x -> x
    | _ ->
        try int_of_string (List.assoc "latest_event" conf.base_env) with
        [ Not_found | Failure _ -> 10 ] ]
  in
  let n = min (max 0 n) base.data.persons.len in
  loop Q.empty 0 0 where rec loop q len i =
    if i = base.data.persons.len then
      loop [] q where rec loop list q =
        if Q.is_empty q then (list, len)
        else
          let (e, q) = Q.take q in
          loop [e :: list] q
    else
      let p = base.data.persons.get i in
      match get_date p with
      [ Some (Dgreg d cal) ->
          let e = (p, d, cal) in
          if len < n then loop (Q.add e q) (len + 1) (i + 1)
          else loop (snd (Q.take (Q.add e q))) len (i + 1)
      | _ -> loop q len (i + 1) ]
;

value print_birth conf base =
  let (list, len) = select conf base (fun p -> Adef.od_of_codate p.birth) in
  let title _ =
    Wserver.wprint (fcapitale (ftransl conf "the latest %d births")) len
  in
  do header conf title;
     Wserver.wprint "<ul>\n";
     let _ = List.fold_left
       (fun last_month_txt (p, d, cal) ->
          let month_txt =
            let d = {(d) with day = 0} in
            capitale (Date.string_of_date conf (Dgreg d cal))
          in
          do if month_txt <> last_month_txt then
               do if last_month_txt = "" then ()
                  else Wserver.wprint "</ul>\n";
                  Wserver.wprint "<li>%s\n" month_txt;
                  Wserver.wprint "<ul>\n";
               return ()
             else ();
             Wserver.wprint "<li>\n";
             Wserver.wprint "<strong>\n";
             afficher_personne_referencee conf base p;
             Wserver.wprint "</strong>,\n";
             Wserver.wprint "%s <em>%s</em>.\n"
               (transl_nth conf "born" (index_of_sex p.sex))
               (Date.string_of_ondate conf (Dgreg d cal));
          return month_txt)
       "" list
     in ();
     Wserver.wprint "</ul>\n</ul>\n";
     trailer conf;
  return ()
;

value get_death p =
  match p.death with
  [ Death _ cd -> Some (Adef.date_of_cdate cd)
  | _ -> None ]
;

value print_death conf base =
  let (list, len) = select conf base get_death in
  let title _ =
    Wserver.wprint (fcapitale (ftransl conf "the latest %d deaths")) len
  in
  do header conf title;
     Wserver.wprint "<ul>\n";
     let _ = List.fold_left
       (fun last_month_txt (p, d, cal) ->
          let month_txt =
            let d = {(d) with day = 0} in
            capitale (Date.string_of_date conf (Dgreg d cal))
          in
          do if month_txt <> last_month_txt then
               do if last_month_txt = "" then ()
                  else Wserver.wprint "</ul>\n";
                  Wserver.wprint "<li>%s\n" month_txt;
                  Wserver.wprint "<ul>\n";
               return ()
             else ();
             Wserver.wprint "<li>\n";
             Wserver.wprint "<strong>\n";
             afficher_personne_referencee conf base p;
             Wserver.wprint "</strong>,\n";
             Wserver.wprint "%s <em>%s</em>"
               (transl_nth conf "died" (index_of_sex p.sex))
               (Date.string_of_ondate conf (Dgreg d cal));
             let sure d = d.prec = Sure in
             match Adef.od_of_codate p.birth with
             [ Some (Dgreg d1 _) ->
                 if sure d1 && sure d && d1 <> d then
                   let a = temps_ecoule d1 d in
                   do Wserver.wprint " <em>(";
                      Date.print_age conf a;
                      Wserver.wprint ")</em>";
                   return ()
                 else ()
             | _ -> () ];
             Wserver.wprint "\n";
          return month_txt)
       "" list
     in ();
     Wserver.wprint "</ul>\n</ul>\n";
     trailer conf;
  return ()
;
