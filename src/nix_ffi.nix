let
  inherit (builtins.import ./gleam.nix) Ok Error toList;
  Nil = null;

  # --- internal ---
  foldr = fun: init: lst:
    let
      len = builtins.length lst;
      fold' = index:
        if index == len
        then init
        else fun (builtins.elemAt lst index) (fold' (index + 1));
    in fold' 0;

  # --- arrays ---
  array_fold = arr: init: operator: builtins.foldl' operator init arr;
  array_fold_right = arr: init: operator: builtins.foldr (elem: acc: operator acc elem) init arr;
  array_get = arr: index: if builtins.length arr > index then Ok (builtins.elemAt arr index) else Error Nil;
  array_map = arr: operator: builtins.map operator arr;
  array_size = builtins.length;
  array_concat = a: b: a ++ b;
  array_from_list = l: if l ? tail then [l.head] ++ array_from_list l.tail else [];
  array_to_list = toList;

  # --- attr sets ---
  attrset_new = {};
  attrset_size = s: builtins.length (builtins.attrNames s);
  attrset_get = s: k: if s ? "${k}" then Ok s."${k}" else Error Nil;
  attrset_set = s: k: v: s // { "${k}" = v; };

  # --- builtins ---
  builtins_seq = builtins.seq;
  builtins_deep_seq = builtins.deepSeq;
in
  {
    inherit
      array_fold
      array_fold_right
      array_get
      array_map
      array_size
      array_concat
      array_from_list
      array_to_list
      attrset_new
      attrset_get
      attrset_set
      attrset_size
      builtins_seq
      builtins_deep_seq;
  }
