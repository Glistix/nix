let
  inherit (builtins.import ./gleam.nix) Ok Error toList listIsEmpty;
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
  array_concat = a: b: a ++ b;
  array_from_list = l: if l ? tail then [l.head] ++ array_from_list l.tail else [];
  array_to_list = toList;

  # --- attr sets ---
  attrset_new = {};
  attrset_size = s: builtins.length (builtins.attrNames s);
  attrset_get = s: k: if s ? "${k}" then Ok s."${k}" else Error Nil;
  attrset_set = s: k: v: s // { "${k}" = v; };

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
  system_to_string =
    system:
      let
        tag = system.__gleamTag;
      in
        if tag == "X8664Linux"
        then "x86_64-linux"
        else if tag == "X8664Darwin"
        then "x86_64-darwin"
        else if tag == "Aarch64Linux"
        then "aarch64-linux"
        else if tag == "Aarch64Darwin"
        then "aarch64-darwin"
        else system._0;

  extract_builder_path = builder: builder._0;

  convert_extra_options =
    options:
      let
        tag = options.head.__gleamTag;
      in
        if listIsEmpty options
        then {}
        else if tag == "Outputs"
        then
          { outputs = array_from_list options.head._0; }
            // (convert_extra_options options.tail)
        else throw "Unimplemented";

  derivation_new =
    name: system: builder: args: options:
      let
        convertedSystem = system_to_string system;
        extractedBuilder = extract_builder_path builder;
        convertedArgs = array_from_list args;
        drvOptions = {
          inherit name;
          builder = extractedBuilder;
          system = convertedSystem;
          args = convertedArgs;
        };
        drvExtraOptions = drvOptions // (convert_extra_options options);
      in builtins.derivation drvExtraOptions;

  derivation_from_attrset =
    attrset:
      attrset // { type = "derivation"; };

  # --- builtins ---
  builtins_seq = builtins.seq;
  builtins_deep_seq = builtins.deepSeq;
  builtins_to_string = builtins.toString;
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
      path_from_string
      derivation_new
      derivation_from_attrset
      builtins_seq
      builtins_deep_seq
      builtins_to_string;
  }
