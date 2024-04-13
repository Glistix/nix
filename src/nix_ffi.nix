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

  # Checks if the first string is at the start of the second string.
  strHasPrefix =
    prefix: string:
      prefix == builtins.substring 0 (builtins.stringLength prefix) string;

  # --- arrays ---
  array_fold = arr: init: operator: builtins.foldl' operator init arr;
  array_fold_right = arr: init: operator: foldr (elem: acc: operator acc elem) init arr;
  array_get = arr: index: if builtins.length arr > index then Ok (builtins.elemAt arr index) else Error Nil;
  array_map = arr: operator: builtins.map operator arr;
  array_size = builtins.length;
  array_contains = arr: value: builtins.elem value arr;
  array_concat2 = a: b: a ++ b;
  array_sort = arr: compare: builtins.sort compare arr;
  array_partition =
    arr: categorise:
      let
        partitions = builtins.partition categorise arr;
      in [ partitions.right partitions.wrong ];
  array_all = arr: predicate: builtins.all predicate arr;
  array_any = arr: predicate: builtins.any predicate arr;
  array_from_list = l: if l ? tail then [l.head] ++ array_from_list l.tail else [];
  array_to_list = toList;
  array_generate = length: generator: builtins.genList generator length;

  # --- attr sets ---
  attrset_new = {}: {};
  attrset_size = s: builtins.length (builtins.attrNames s);
  attrset_get = s: k: if s ? "${k}" then Ok s."${k}" else Error Nil;
  attrset_set = s: k: v: s // { "${k}" = v; };
  attrset_map_values = set: fun: builtins.mapAttrs fun set;
  attrset_merge = a: b: a // b;
  attrset_intersect = a: b: builtins.intersectAttrs b a;
  attrset_names = builtins.attrNames;
  attrset_values = builtins.attrValues;
  attrset_from_array =
    attrs:
      let
        pairs = builtins.map (x: { name = builtins.head x; value = builtins.elemAt x 1; }) attrs;
      in builtins.listToAttrs pairs;
  attrset_to_array =
    set:
      let
        pairs = builtins.map (name: [ name set.${name} ]) (builtins.attrNames set);
      in pairs;

  # --- paths ---
  path_from_string =
    string:
      let
        substringAfterChars = n: builtins.substring n (-1);
      in
        if strHasPrefix "/" string
        then /${substringAfterChars 1 string}
        else if strHasPrefix "~/" string
        then ~/${substringAfterChars 2 string}
        else if strHasPrefix "../" string
        then ../${substringAfterChars 3 string}
        else if strHasPrefix "./" string
        then ./${substringAfterChars 2 string}
        else ./${string};

  # --- derivations ---
  derivation_new =
    name: system: builder: args: options:
      let
        drvOptions = { inherit name system builder args; };
        drvExtraOptions = drvOptions // options;
      in builtins.derivation drvExtraOptions;

  derivation_from_attrset =
    attrset:
      attrset // { type = "derivation"; };

  # --- environment ---
  current_system =
    {}:
      if builtins.isString (builtins.currentSystem or null)
      then Ok builtins.currentSystem
      else Error Nil;

  current_time =
    {}:
      if builtins.isInt (builtins.currentTime or null)
      then Ok builtins.currentTime
      else Error Nil;

  get_env =
    name:
      if builtins.isFunction (builtins.getEnv or null)
      then
        let
          value = builtins.getEnv name;
        in if value == "" then Error Nil else Ok value
      else Error Nil;

  # --- builtins ---
  deep_eval = x: builtins.deepSeq x x;
  builtins_to_string = builtins.toString;
  builtins_typeof = builtins.typeOf;
in
  {
    inherit
      array_fold
      array_fold_right
      array_get
      array_map
      array_size
      array_contains
      array_concat2
      array_sort
      array_partition
      array_all
      array_any
      array_from_list
      array_to_list
      array_generate
      attrset_new
      attrset_size
      attrset_get
      attrset_set
      attrset_map_values
      attrset_merge
      attrset_intersect
      attrset_names
      attrset_values
      attrset_from_array
      attrset_to_array
      path_from_string
      derivation_new
      derivation_from_attrset
      current_system
      current_time
      get_env
      deep_eval
      builtins_to_string
      builtins_typeof;
  }
