
type t =
  { dir_portraits : string
  ; dir_portraits_bak : string
  ; file_conf : string
  ; dir_notes : string
  ; dir_root : string
  ; dir_images : string
  ; dir_password : string
  ; dir_cnt : string
  ; file_ts : string
  ; file_ts_visitor : string
  ; file_restrict : string
  ; file_synchro_patches : string
  ; file_cmd : string
  ; file_base : string
  ; file_particles : string
  ; file_base_acc : string
  ; file_strings_inx : string
  ; file_names_inx : string
  ; file_names_acc : string
  ; file_patches : string
  }

let path_from_bname s =
  let bdir =
    if Filename.check_suffix s ".gwb" then s
    else if Filename.check_suffix s ".gwb/" then Filename.chop_suffix s "/"
    else s ^ ".gwb"
  in
  { dir_portraits = List.fold_left Filename.concat bdir [ "documents" ; "portraits" ]
  ; file_conf = List.fold_left Filename.concat bdir [ "etc" ; "config.txt" ]
  ; dir_notes = List.fold_left Filename.concat bdir [ "notes" ]
  ; dir_root = bdir
  ; dir_images = List.fold_left Filename.concat bdir [ "documents" ; "images" ]
  ; dir_portraits_bak = List.fold_left Filename.concat bdir [ "documents" ; "portraits" ; "saved" ]
  ; dir_password = bdir
  ; dir_cnt = List.fold_left Filename.concat bdir [ "etc" ; "cnt" ]
  ; file_ts = Filename.concat bdir "tstab"
  ; file_ts_visitor = Filename.concat bdir "tstab_visitor"
  ; file_restrict = Filename.concat bdir "restrict"
  ; file_synchro_patches = Filename.concat bdir "synchro_patches"
  ; file_cmd = Filename.concat bdir "command.txt"
  ; file_base = Filename.concat bdir "base"
  ; file_particles = Filename.concat bdir "particles.txt"
  ; file_base_acc = Filename.concat bdir "base.acc"
  ; file_strings_inx = Filename.concat bdir "strings.inx"
  ; file_names_inx = Filename.concat bdir "names.inx"
  ; file_names_acc = Filename.concat bdir "names.acc"
  ; file_patches = Filename.concat bdir "patches"
  }
