let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.10.3-20240111/package-set.dhall sha256:574545c09b6c6acd39abbba555c07f307e3992d003c13b3fa5e9e20c6a1599cd
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [
    {
       name = "StableTrieMap",
       version = "main",
       repo = "https://github.com/NatLabs/StableTrieMap",
       dependencies = ["base"] : List Text
    },
    {
       name = "StableBuffer",
       version = "v0.2.0",
       repo = "https://github.com/canscale/StableBuffer",
       dependencies = ["base"] : List Text
    },
    {
       name = "itertools",
       version = "main",
       repo = "https://github.com/NatLabs/Itertools.mo",
       dependencies = ["base"] : List Text
    }
    ] : List Package

in  upstream # additions # overrides
